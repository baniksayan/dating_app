import '../../../core/storage/hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/helpers/logger_helper.dart';

class AuthResponse {
  final bool isSuccess;
  final bool isOnboardingCompleted;
  final String? errorMessage;
  final String? token;

  const AuthResponse({
    required this.isSuccess,
    required this.isOnboardingCompleted,
    this.errorMessage,
    this.token,
  });
}

abstract class AuthRepository {
  /// Request an OTP to be sent to the email address
  Future<void> sendOtp(String email);

  /// Verify the OTP code sent to the email address
  Future<AuthResponse> verifyOtp(String email, String code);

  /// Clear the authentication session
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  final HiveService _hiveService;

  MockAuthRepository({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  // Development OTP constant
  static const String _mockOtp = '123456';

  // Seeded mock emails representing returning users
  static const Set<String> _returningUserEmails = {
    'aurelia@example.com',
    'sebastian@example.com',
    'isabella@example.com',
    'julian@example.com',
    'seraphina@example.com',
  };

  @override
  Future<void> sendOtp(String email) async {
    Logger.info('[MockAuth] Requesting OTP code to be sent to: $email', 'MockAuthRepository');
    // Simulate backend API latency
    await Future.delayed(const Duration(milliseconds: 1000));
    Logger.info('[MockAuth] OTP code sent successfully. Use code: $_mockOtp', 'MockAuthRepository');
  }

  @override
  Future<AuthResponse> verifyOtp(String email, String code) async {
    Logger.info('[MockAuth] Verifying OTP code: "$code" for email: $email', 'MockAuthRepository');
    // Simulate backend API latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Verify OTP code
    if (code != _mockOtp) {
      Logger.warning('[MockAuth] Verification failed. Invalid code "$code" entered for $email', 'MockAuthRepository');
      return const AuthResponse(
        isSuccess: false,
        isOnboardingCompleted: false,
        errorMessage: 'Invalid verification code. Please try again.',
      );
    }

    Logger.info('[MockAuth] Verification successful for $email', 'MockAuthRepository');

    // Check if the user is a returning user (registered profile already in database)
    final bool isReturningUser = _returningUserEmails.contains(email.trim().toLowerCase());

    // Update local Hive storage
    await _hiveService.settingsBox.put('is_authenticated', true);
    await _hiveService.settingsBox.put('auth_token', 'mock_token_xyz_123');
    await _hiveService.settingsBox.put('auth_user_email', email);

    if (isReturningUser) {
      await _hiveService.settingsBox.put('is_onboarding_completed', true);
      Logger.info('[MockAuth] Returning user detected. Redirecting to Swipe screen.', 'MockAuthRepository');
      return const AuthResponse(
        isSuccess: true,
        isOnboardingCompleted: true,
        token: 'mock_token_xyz_123',
      );
    } else {
      await _hiveService.settingsBox.put('is_onboarding_completed', false);
      Logger.info('[MockAuth] New user detected. Redirecting to Onboarding wizard.', 'MockAuthRepository');
      return const AuthResponse(
        isSuccess: true,
        isOnboardingCompleted: false,
        token: 'mock_token_xyz_123',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _hiveService.settingsBox.put('is_authenticated', false);
    await _hiveService.settingsBox.put('is_onboarding_completed', false);
    await _hiveService.settingsBox.delete('auth_token');
    await _hiveService.settingsBox.delete('auth_user_email');
    // Clear onboarding draft if any
    await _hiveService.settingsBox.delete('onboarding_draft');
  }
}

// Riverpod Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});
