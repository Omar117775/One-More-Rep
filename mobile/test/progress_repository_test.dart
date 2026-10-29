import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/data/repositories/progress_repository.dart';

void main() {
  test(
    'progress update sends explicit nulls so fields can be cleared',
    () async {
      http.Request? captured;
      final repo = ApiProgressRepository(
        ApiClient(
          baseUrl: 'https://example.test/api/v1',
          client: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'data': {
                  'id': 4,
                  'weight_kg': null,
                  'body_fat_percentage': 18,
                  'waist_cm': null,
                  'chest_cm': null,
                  'arm_cm': null,
                  'measured_on': '2026-05-01',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      await repo.update(
        4,
        measuredOn: DateTime(2026, 5, 1),
        bodyFatPercentage: 18,
      );

      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body.containsKey('weight_kg'), isTrue);
      expect(body['weight_kg'], isNull);
      expect(body['body_fat_percentage'], 18);
      expect(body['measured_on'], '2026-05-01');
    },
  );

  test('progress update keeps calendar dates from shifting', () async {
    http.Request? captured;
    final repo = ApiProgressRepository(
      ApiClient(
        baseUrl: 'https://example.test/api/v1',
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'data': {'id': 4, 'measured_on': '2026-01-01'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      ),
    );

    await repo.update(4, measuredOn: DateTime(2026, 1, 1), weightKg: 80);

    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['measured_on'], '2026-01-01');
  });
}
