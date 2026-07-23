import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/helpers/logger_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/hive_service.dart';
import '../models/send_otp_model.dart';
import '../models/resend_otp_model.dart';
import '../models/verify_otp_model.dart';

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
  Future<SendOtp> sendOtp(String email);

  /// Resend an OTP code to the email address
  Future<ResendOtp> resendOtp(String email);

  /// Verify the OTP code sent to the email address
  Future<VerifyOtp> verifyOtp(String email, String code);

  /// Clear the authentication session
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final HiveService _hiveService;

  AuthRepositoryImpl({DioClient? dioClient, HiveService? hiveService})
      : _dioClient = dioClient ?? DioClient(baseUrl: 'https://dating-app-qdx5.onrender.com/api'),
        _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<SendOtp> sendOtp(String email) async {
    const String endpoint = '/send-otp.php';
    final Map<String, dynamic> payload = {'email': email};

    Logger.info('🚀 [POST REQUEST] Endpoint: https://dating-app-qdx5.onrender.com/api$endpoint', 'AuthRepository');
    Logger.info('📦 Request Data: $payload', 'AuthRepository');

    try {
      final response = await _dioClient.post(
        endpoint,
        data: payload,
      );

      Logger.info('✅ [API RESPONSE] Status: ${response.statusCode}', 'AuthRepository');
      Logger.info('📄 Raw Response Body: ${response.data}', 'AuthRepository');

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      }

      final sendOtpResponse = SendOtp.fromJson(jsonMap);
      Logger.info('✨ Parsed SendOtp Model -> status: "${sendOtpResponse.status}", message: "${sendOtpResponse.message}"', 'AuthRepository');

      return sendOtpResponse;
    } on ApiException catch (e) {
      Logger.error('❌ [API ERROR - ApiException] Status: ${e.statusCode}', e.message, null, 'AuthRepository');
      if (e.errorData != null) {
        Logger.error('📄 Error Data: ${e.errorData}', null, null, 'AuthRepository');
        if (e.errorData is Map<String, dynamic>) {
          return SendOtp.fromJson(e.errorData as Map<String, dynamic>);
        } else if (e.errorData is String) {
          try {
            final jsonMap = jsonDecode(e.errorData as String) as Map<String, dynamic>;
            return SendOtp.fromJson(jsonMap);
          } catch (_) {}
        }
      }
      return SendOtp(status: 'error', message: e.message);
    } catch (e, stackTrace) {
      Logger.error('💥 [API UNEXPECTED ERROR]', e, stackTrace, 'AuthRepository');
      return SendOtp(status: 'error', message: e.toString());
    }
  }

  @override
  Future<ResendOtp> resendOtp(String email) async {
    const String endpoint = '/resend-otp.php';
    final Map<String, dynamic> payload = {'email': email};

    Logger.info('🚀 [POST REQUEST] Endpoint: https://dating-app-qdx5.onrender.com/api$endpoint', 'AuthRepository');
    Logger.info('📦 Request Data: $payload', 'AuthRepository');

    try {
      final response = await _dioClient.post(
        endpoint,
        data: payload,
      );

      Logger.info('✅ [API RESPONSE] Status: ${response.statusCode}', 'AuthRepository');
      Logger.info('📄 Raw Response Body: ${response.data}', 'AuthRepository');

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      }

      final resendOtpResponse = ResendOtp.fromJson(jsonMap);
      Logger.info('✨ Parsed ResendOtp Model -> status: "${resendOtpResponse.status}", message: "${resendOtpResponse.message}"', 'AuthRepository');

      return resendOtpResponse;
    } on ApiException catch (e) {
      Logger.error('❌ [API ERROR - ApiException] Status: ${e.statusCode}', e.message, null, 'AuthRepository');
      if (e.errorData != null) {
        Logger.error('📄 Error Data: ${e.errorData}', null, null, 'AuthRepository');
        if (e.errorData is Map<String, dynamic>) {
          return ResendOtp.fromJson(e.errorData as Map<String, dynamic>);
        } else if (e.errorData is String) {
          try {
            final jsonMap = jsonDecode(e.errorData as String) as Map<String, dynamic>;
            return ResendOtp.fromJson(jsonMap);
          } catch (_) {}
        }
      }
      return ResendOtp(status: 'error', message: e.message);
    } catch (e, stackTrace) {
      Logger.error('💥 [API UNEXPECTED ERROR]', e, stackTrace, 'AuthRepository');
      return ResendOtp(status: 'error', message: e.toString());
    }
  }

  @override
  Future<VerifyOtp> verifyOtp(String email, String code) async {
    const String endpoint = '/verify-otp.php';
    final Map<String, dynamic> payload = {
      'email': email,
      'otp': code,
    };

    Logger.info('🚀 [POST REQUEST] Endpoint: https://dating-app-qdx5.onrender.com/api$endpoint', 'AuthRepository');
    Logger.info('📦 Request Data: $payload', 'AuthRepository');

    try {
      final response = await _dioClient.post(
        endpoint,
        data: payload,
      );

      Logger.info('✅ [API RESPONSE] Status: ${response.statusCode}', 'AuthRepository');
      Logger.info('📄 Raw Response Body: ${response.data}', 'AuthRepository');

      Map<String, dynamic> jsonMap;
      if (response.data is Map<String, dynamic>) {
        jsonMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = Map<String, dynamic>.from(response.data as Map);
      }

      final verifyOtpResponse = VerifyOtp.fromJson(jsonMap);
      Logger.info('✨ Parsed VerifyOtp Model -> status: "${verifyOtpResponse.status}", message: "${verifyOtpResponse.message}", registration_token: "${verifyOtpResponse.data?.registrationToken}"', 'AuthRepository');

      if (verifyOtpResponse.status == 'success') {
        final token = verifyOtpResponse.data?.registrationToken ?? '';
        await _hiveService.settingsBox.put('is_authenticated', true);
        await _hiveService.settingsBox.put('registration_token', token);
        await _hiveService.settingsBox.put('auth_token', token);
        await _hiveService.settingsBox.put('auth_user_email', email);
        Logger.info('🔒 Securely stored registration_token in local Hive storage: "$token"', 'AuthRepository');
      }

      return verifyOtpResponse;
    } on ApiException catch (e) {
      Logger.error('❌ [API ERROR - ApiException] Status: ${e.statusCode}', e.message, null, 'AuthRepository');
      if (e.errorData != null) {
        Logger.error('📄 Error Data: ${e.errorData}', null, null, 'AuthRepository');
        if (e.errorData is Map<String, dynamic>) {
          return VerifyOtp.fromJson(e.errorData as Map<String, dynamic>);
        } else if (e.errorData is String) {
          try {
            final jsonMap = jsonDecode(e.errorData as String) as Map<String, dynamic>;
            return VerifyOtp.fromJson(jsonMap);
          } catch (_) {}
        }
      }
      return VerifyOtp(status: 'error', message: e.message);
    } catch (e, stackTrace) {
      Logger.error('💥 [API UNEXPECTED ERROR]', e, stackTrace, 'AuthRepository');
      return VerifyOtp(status: 'error', message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _hiveService.settingsBox.put('is_authenticated', false);
    await _hiveService.settingsBox.put('is_onboarding_completed', false);
    await _hiveService.settingsBox.delete('auth_token');
    await _hiveService.settingsBox.delete('registration_token');
    await _hiveService.settingsBox.delete('auth_user_email');
    await _hiveService.settingsBox.delete('onboarding_draft');
  }
}

class MockAuthRepository implements AuthRepository {
  final HiveService _hiveService;

  MockAuthRepository({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  static const String _mockOtp = '123456';

  @override
  Future<SendOtp> sendOtp(String email) async {
    Logger.info('[MockAuth] Requesting OTP code to be sent to: $email', 'MockAuthRepository');
    await Future.delayed(const Duration(milliseconds: 1000));
    Logger.info('[MockAuth] OTP code sent successfully. Use code: $_mockOtp', 'MockAuthRepository');
    return SendOtp(status: 'success', message: 'OTP sent successfully.');
  }

  @override
  Future<ResendOtp> resendOtp(String email) async {
    Logger.info('[MockAuth] Resending OTP code to: $email', 'MockAuthRepository');
    await Future.delayed(const Duration(milliseconds: 1000));
    Logger.info('[MockAuth] OTP code resent successfully. Use code: $_mockOtp', 'MockAuthRepository');
    return ResendOtp(status: 'success', message: 'OTP resent successfully.');
  }

  @override
  Future<VerifyOtp> verifyOtp(String email, String code) async {
    Logger.info('[MockAuth] Verifying OTP code: "$code" for email: $email', 'MockAuthRepository');
    await Future.delayed(const Duration(milliseconds: 1200));

    if (code != _mockOtp) {
      Logger.warning('[MockAuth] Verification failed. Invalid code "$code" entered for $email', 'MockAuthRepository');
      return VerifyOtp(status: 'error', message: 'Invalid verification code. Please try again.');
    }

    Logger.info('[MockAuth] Verification successful for $email', 'MockAuthRepository');
    const mockToken = 'mock_reg_token_xyz_123';
    await _hiveService.settingsBox.put('is_authenticated', true);
    await _hiveService.settingsBox.put('registration_token', mockToken);
    await _hiveService.settingsBox.put('auth_token', mockToken);
    await _hiveService.settingsBox.put('auth_user_email', email);

    return VerifyOtp(
      status: 'success',
      message: 'OTP verified successfully.',
      data: Data(registrationToken: mockToken),
    );
  }

  @override
  Future<void> logout() async {
    await _hiveService.settingsBox.put('is_authenticated', false);
    await _hiveService.settingsBox.put('is_onboarding_completed', false);
    await _hiveService.settingsBox.delete('auth_token');
    await _hiveService.settingsBox.delete('registration_token');
    await _hiveService.settingsBox.delete('auth_user_email');
    await _hiveService.settingsBox.delete('onboarding_draft');
  }
}

// Riverpod Provider for AuthRepository pointing to AuthRepositoryImpl
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
