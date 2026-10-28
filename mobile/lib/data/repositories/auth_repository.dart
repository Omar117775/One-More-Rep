import 'package:mobile/core/api_client.dart';
import 'package:mobile/data/models/user.dart';

/// Abstraction so UI/tests can fake auth without live network.
abstract class AuthRepository {
  Future<LoginResult> login({
    required String email,
    required String password,
    String deviceName = 'One More Rep Trainee App',
  });

  Future<User> me();

  Future<void> logout();
}

/// Laravel-backed auth; stores the token in-memory on the ApiClient only.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String deviceName = 'One More Rep Trainee App',
  }) async {
    final body = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });
    final result = parseLoginResponse(body);
    _client.authToken = result.token;
    return result;
  }

  @override
  Future<User> me() async {
    final body = await _client.get('/auth/me');
    final data = body is Map ? body['data'] : null;
    return User.fromJson(data);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      _client.authToken = null;
    }
  }
}
