import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user.dart';
import '../data/repositories/analytics_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/cardio_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/train_repository.dart';
import '../localization/app_strings.dart';
import 'api_client.dart';

const _tokenKey = 'omr_auth_token';

/// Application-wide controller: session state, API client and repositories.
///
/// Token is persisted to [SharedPreferences] so the session survives
/// app restarts. On cold start, call [tryRestoreSession] to rehydrate.
class AppController extends ChangeNotifier {
  AppController({
    http.Client? httpClient,
    AuthRepository? auth,
    TrainRepository? train,
    CardioRepository? cardio,
    ProgressRepository? progress,
    AnalyticsRepository? analytics,
  }) : api = ApiClient(client: httpClient) {
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
    final next =
        supportedLocales.any((l) => l.languageCode == locale.languageCode)
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

  // ---------------------------------------------------------------------------
  // Token persistence
  // ---------------------------------------------------------------------------

  /// Persists the current auth token to local storage.
  Future<void> _persistToken(String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 400),
      );
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_tokenKey, token);
      } else {
        await prefs.remove(_tokenKey);
      }
    } catch (_) {
      // Storage failures must not break auth flow.
    }
  }

  /// Attempts to restore a previous session from persisted token.
  /// Returns `true` if session was restored successfully.
  Future<bool> tryRestoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 400),
      );
      final token = prefs.getString(_tokenKey);
      if (token == null || token.isEmpty) return false;

      api.authToken = token;
      final fresh = await auth.me();
      user = fresh;
      notifyListeners();
      return true;
    } catch (_) {
      // Token expired or invalid — clear it.
      api.authToken = null;
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Signs in and refreshes the profile via /auth/me (falls back to the
  /// login payload user if /auth/me fails).
  Future<User> signIn({required String email, required String password}) async {
    final result = await auth.login(email: email, password: password);
    api.authToken = result.token;
    await _persistToken(result.token);
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

  /// Registers a new trainee via the real API.
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? gender,
  }) async {
    final result = await auth.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    api.authToken = result.token;
    await _persistToken(result.token);
    user = result.user;
    notifyListeners();
    return result.user;
  }

  /// Guest / Instant demo entry for standalone mock operation without backend.
  void enterAsGuestMock() {
    api.authToken = 'mock-demo-token';
    user = const User(
      id: 1,
      name: 'Leonidas',
      email: 'spartan@onemorerep.fit',
      roles: ['trainee'],
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await auth.logout();
    } catch (_) {
      // Local session discard must succeed regardless of the network result.
    }
    api.authToken = null;
    await _persistToken(null);
    user = null;
    notifyListeners();
  }
}
