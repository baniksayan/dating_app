import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../models/resend_otp_model.dart';
import '../repositories/auth_repository.dart';

import '../models/verify_otp_model.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  Timer? _timer;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      clearEmailError: true,
    );
  }

  void updateOtp(String otp) {
    state = state.copyWith(
      otp: otp,
      clearOtpError: true,
    );
  }

  bool get isEmailValid {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(state.email.trim());
  }

  Future<bool> sendOtp() async {
    if (!isEmailValid) {
      state = state.copyWith(emailError: 'Please enter a valid email address.');
      return false;
    }

    state = state.copyWith(isEmailLoading: true, clearEmailError: true);

    try {
      final response = await _authRepository.sendOtp(state.email.trim());

      if (response.status == 'success') {
        state = state.copyWith(isEmailLoading: false);
        startResendTimer(60);
        return true;
      } else {
        state = state.copyWith(
          isEmailLoading: false,
          emailError: response.message ?? 'Failed to send verification code. Please try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isEmailLoading: false,
        emailError: 'Failed to send verification code. Please check connection.',
      );
      return false;
    }
  }

  Future<ResendOtp> resendOtp() async {
    state = state.copyWith(isOtpLoading: true, clearOtpError: true);

    try {
      final response = await _authRepository.resendOtp(state.email.trim());
      state = state.copyWith(isOtpLoading: false);

      // Dynamically extract waiting seconds from backend response message (e.g. "Please wait 57 seconds...")
      int countdownSeconds = 60; // static default 60 seconds
      if (response.message != null) {
        final RegExp secondsRegex = RegExp(r'(\d+)\s*second');
        final match = secondsRegex.firstMatch(response.message!);
        if (match != null && match.group(1) != null) {
          countdownSeconds = int.tryParse(match.group(1)!) ?? 60;
        }
      }

      if (response.status == 'success') {
        startResendTimer(countdownSeconds);
      } else {
        // Status is error or rate-limited (e.g. "Please wait 57 seconds before requesting a new OTP.")
        state = state.copyWith(
          otpError: response.message ?? 'Please wait before requesting a new OTP.',
        );
        startResendTimer(countdownSeconds);
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        isOtpLoading: false,
        otpError: 'Failed to resend code. Please check connection.',
      );
      return ResendOtp(status: 'error', message: 'Failed to resend code.');
    }
  }

  Future<VerifyOtp> verifyOtp() async {
    if (state.otp.length != 6) {
      const errorMsg = 'Please enter all 6 digits.';
      state = state.copyWith(otpError: errorMsg);
      return VerifyOtp(status: 'error', message: errorMsg);
    }

    state = state.copyWith(isOtpLoading: true, clearOtpError: true);

    try {
      final response = await _authRepository.verifyOtp(
        state.email.trim(),
        state.otp.trim(),
      );

      if (response.status == 'success') {
        state = state.copyWith(
          isOtpLoading: false,
          mockVerificationToken: response.data?.registrationToken,
        );
      } else {
        state = state.copyWith(
          isOtpLoading: false,
          otpError: response.message ?? 'Incorrect code. Please try again.',
        );
      }
      return response;
    } catch (e) {
      const errorMsg = 'Verification failed. Please check connection.';
      state = state.copyWith(
        isOtpLoading: false,
        otpError: errorMsg,
      );
      return VerifyOtp(status: 'error', message: errorMsg);
    }
  }

  void startResendTimer([int seconds = 60]) {
    _timer?.cancel();
    state = state.copyWith(resendCountdown: seconds, canResend: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 1) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(resendCountdown: 0, canResend: true);
      }
    });
  }

  void resetState() {
    _timer?.cancel();
    state = const AuthState();
  }
}

// Riverpod Provider for AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository: repository);
});
