import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/api_exception.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

void main() {
  group('login API parsing and error mapping', () {
    test(
      'parses token/user from /auth/login and sends required body',
      () async {
        http.Request? capturedRequest;
        final client = ApiClient(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'data': {
                  'token': 'tok123',
                  'token_type': 'Bearer',
                  'expires_at': '2026-12-31T00:00:00Z',
                  'user': {
                    'id': 7,
                    'name': 'Leonidas',
                    'email': 'l@example.com',
                    'roles': ['trainee'],
                  },
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        final repo = ApiAuthRepository(client);

        final result = await repo.login(
          email: 'l@example.com',
          password: 'secret',
        );

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.url.path.endsWith('/auth/login'), isTrue);
        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body['email'], 'l@example.com');
        expect(body['password'], 'secret');
        expect(body['device_name'], isNotNull);

        expect(result.token, 'tok123');
        expect(result.user.name, 'Leonidas');
        expect(result.user.isTrainee, isTrue);
        expect(client.authToken, 'tok123');
      },
    );

    test('maps 422 field errors into ApiException', () async {
      final repo = ApiAuthRepository(
        ApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'message': 'The email field is required.',
                'errors': {
                  'email': ['The email field is required.'],
                },
              }),
              422,
            ),
          ),
        ),
      );

      expect(
        () => repo.login(email: '', password: 'x'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.isValidation, 'isValidation', isTrue)
              .having((e) => e.fieldErrors['email'], 'emailErrors', isNotEmpty),
        ),
      );
    });

    test('maps 401 invalid credentials message and non-JSON body', () async {
      final repo = ApiAuthRepository(
        ApiClient(
          client: MockClient(
            (_) async => http.Response('<html>Server Error</html>', 401),
          ),
        ),
      );

      try {
        await repo.login(email: 'l@example.com', password: 'wrong');
        fail('expected ApiException');
      } on ApiException catch (error) {
        expect(error.statusCode, 401);
        expect(error.message, contains('401'));
      }
    });

    test('maps transport failure to network ApiException', () async {
      final repo = ApiAuthRepository(
        ApiClient(client: MockClient((_) async => throw Exception('socket'))),
      );

      await expectLater(
        repo.login(email: 'l@example.com', password: 'x'),
        throwsA(
          isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue),
        ),
      );
    });

    test('me() unwraps data and logout clears the in-memory token', () async {
      var meCalled = false;
      final client = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/auth/me')) {
            meCalled = true;
            if (request.headers['Authorization'] != 'Bearer tok123') {
              return http.Response('unauthorized', 401);
            }
            return http.Response(
              jsonEncode({
                'data': {'id': 7, 'name': 'Leonidas', 'email': 'l@example.com'},
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/auth/logout')) {
            return http.Response(jsonEncode({'data': null}), 200);
          }
          return http.Response('not found', 404);
        }),
      );
      client.authToken = 'tok123';
      final repo = ApiAuthRepository(client);

      final user = await repo.me();
      expect(meCalled, isTrue);
      expect(user, isA<User>());
      expect(user.email, 'l@example.com');

      await repo.logout();
      expect(client.authToken, isNull);
    });
  });
}
