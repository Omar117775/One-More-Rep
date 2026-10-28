import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/analytics_summary.dart';

/// Abstraction over aggregate analytics (/trainee/analytics).
abstract class AnalyticsRepository {
  Future<AnalyticsSummary> fetch({required DateTime from, required DateTime to});
}

class ApiAnalyticsRepository implements AnalyticsRepository {
  ApiAnalyticsRepository(this._client);

  final ApiClient _client;

  @override
  Future<AnalyticsSummary> fetch({required DateTime from, required DateTime to}) async {
    final body = await _client.get('/trainee/analytics', query: {
      'from': formatDateYdm(from) ?? '',
      'to': formatDateYdm(to) ?? '',
    });
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    return AnalyticsSummary.fromJson(data);
  }
}
