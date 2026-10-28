import 'package:mobile/core/api_exception.dart';
import '../../core/parsing.dart';

/// Authenticated trainee profile.
class User {
  const User({
    required this.id,
    this.name = '',
    required this.email,
    this.roles = const [],
  });

  final Object? id;
  final String name;
  final String email;
  final List<String> roles;

  String get displayName {
    final n = name.trim();
    return n.isEmpty ? email : n;
  }

  bool get isTrainee => roles.any((r) => r == 'trainee');

  factory User.fromJson(dynamic raw) {
    if (raw is! Map) return const User(id: null, email: '');
    final rolesRaw = raw['roles'];
    return User(
      id: raw['id'],
      name: raw['name']?.toString() ?? '',
      email: raw['email']?.toString() ?? '',
      roles: rolesRaw is List ? rolesRaw.map((r) => r.toString()).toList() : const [],
    );
  }

  factory User.fromDynamic(dynamic raw) => User.fromJson(raw);
}

/// Login result: token + fresh user.
class LoginResult {
  const LoginResult({required this.token, required this.tokenType, this.expiresAt, required this.user});

  final String token;
  final String tokenType;
  final DateTime? expiresAt;
  final User user;
}

/// Decodes a login payload of shape `{data:{token,token_type,expires_at,user}}`.
LoginResult parseLoginResponse(dynamic body) {
  if (body is! Map || body['data'] is! Map) {
    throw const ApiException(message: 'malformed', kind: ApiExceptionKind.server, statusCode: 500);
  }
  final data = body['data'] as Map;
  final token = data['token'];
  if (token is! String || token.isEmpty) {
    throw const ApiException(message: 'missing token', kind: ApiExceptionKind.server, statusCode: 500);
  }
  return LoginResult(
    token: token,
    tokenType: (data['token_type'] ?? 'Bearer').toString(),
    expiresAt: parseDate(data['expires_at']),
    user: User.fromJson(data['user']),
  );
}
