class AuthState {
  final String email;
  final String otp;
  final bool isEmailLoading;
  final bool isOtpLoading;
  final String? emailError;
  final String? otpError;
  final int resendCountdown;
  final bool canResend;
  final String? mockVerificationToken; // returned from MockAuthRepository on verification success

  const AuthState({
    this.email = '',
    this.otp = '',
    this.isEmailLoading = false,
    this.isOtpLoading = false,
    this.emailError,
    this.otpError,
    this.resendCountdown = 60,
    this.canResend = false,
    this.mockVerificationToken,
  });

  AuthState copyWith({
    String? email,
    String? otp,
    bool? isEmailLoading,
    bool? isOtpLoading,
    String? emailError,
    bool clearEmailError = false,
    String? otpError,
    bool clearOtpError = false,
    int? resendCountdown,
    bool? canResend,
    String? mockVerificationToken,
    bool clearToken = false,
  }) {
    return AuthState(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      isOtpLoading: isOtpLoading ?? this.isOtpLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      resendCountdown: resendCountdown ?? this.resendCountdown,
      canResend: canResend ?? this.canResend,
      mockVerificationToken: clearToken ? null : (mockVerificationToken ?? this.mockVerificationToken),
    );
  }
}
