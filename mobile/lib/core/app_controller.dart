import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../data/models/user.dart';
import '../data/repositories/analytics_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/cardio_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/train_repository.dart';
import '../localization/app_strings.dart';
import 'api_client.dart';

/// Application-wide controller: session state, API client and repositories.
/// The token lives in-memory only (no persistence in P5); full auth/profile
/// UX arrives with P7.
class AppController extends ChangeNotifier {
  AppController({
    http.Client? httpClient,
    AuthRepository? auth,
    TrainRepository? train,
    CardioRepository? cardio,
    ProgressRepository? progress,
    AnalyticsRepository? analytics,
  })  : api = ApiClient(client: httpClient) {
    this.auth = auth ?? ApiAuthRepository(api);
    this.train = train ?? ApiTrainRepository(api);
    this.cardio = cardio ?? ApiCardioRepository(api);
    this.progress = progress ?? ApiProgressRepository(api);
    this.analytics = analytics ?? ApiAnalyticsRepository(api);
  }

  final ApiClient api;
  late final AuthRepository auth;
  late final TrainRepository train;
  late final CardioRepository cardio;
  late final ProgressRepository progress;
  late final AnalyticsRepository analytics;

  User? user;
  Locale _locale = supportedLocales.first;

  Locale get locale => _locale;

  bool get isSignedIn => user != null && api.hasToken;

  bool get isArabic => _locale.languageCode == 'ar';

  AppStrings get strings => isArabic ? AppStrings.arabic : AppStrings.english;

  void setLocale(Locale locale) {
    final next = supportedLocales.any((l) => l.languageCode == locale.languageCode)
        ? locale
        : supportedLocales.first;
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
  }

  String get apiBaseUrl => api.baseUrl;

  void setApiBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final normalized = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    if (api.baseUrl == normalized) return;
    api.baseUrl = normalized;
    notifyListeners();
  }

  /// Signs in and refreshes the profile via /auth/me (falls back to the
  /// login payload user if /auth/me fails — P5 fallback, P7 hardens).
  Future<User> signIn({required String email, required String password}) async {
    final result = await auth.login(email: email, password: password);
    api.authToken = result.token;
    User fresh;
    try {
      fresh = await auth.me();
    } catch (_) {
      fresh = result.user;
    }
    user = fresh;
    notifyListeners();
    return fresh;
  }

  Future<void> signOut() async {
    try {
      await auth.logout();
    } catch (_) {
      // Local session discard must succeed regardless of the network result.
    }
    api.authToken = null;
    user = null;
    notifyListeners();
  }
}
