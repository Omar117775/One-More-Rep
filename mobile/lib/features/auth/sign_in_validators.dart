/// Sign-in validators kept pure for unit testing.
String? validateEmailField(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'empty';
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(email)) return 'format';
  return null;
}

String? validatePasswordField(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'empty';
  if (password.length < 6) return 'short';
  return null;
}
