import 'package:mobile/core/api_exception.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

import 'fakes.dart';

/// Fake auth repository; no network, tokens decided by the test.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failLogin = false});

  bool failLogin;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String deviceName = 'One More Rep Trainee App',
  }) async {
    if (failLogin) {
      throw const ApiException(message: 'Invalid credentials.', kind: ApiExceptionKind.server, statusCode: 401);
    }
    return LoginResult(
      token: 'test-token',
      tokenType: 'Bearer',
      user: User(id: 7, name: 'Leonidas', email: email, roles: const ['trainee']),
    );
  }

  @override
  Future<User> me() async => testUser();

  @override
  Future<void> logout() async {}
}
