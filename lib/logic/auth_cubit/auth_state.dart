abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String role;
  AuthAuthenticated({required this.role});
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}