class ApiConfig {
  ApiConfig._();

  /// Centralized Base API URL for all backend services
  static const String baseUrl = 'http://13.51.193.37/api';

  /// Endpoints
  static const String masterAllData = '/master/all-master-data.php';
  static const String sendOtp = '/send-otp.php';
  static const String verifyOtp = '/verify-otp.php';
  static const String loginSendOtp = '/login-send-otp.php';
  static const String loginVerifyOtp = '/login-verify-otp.php';
  static const String resendOtp = '/resend-otp.php';
}
