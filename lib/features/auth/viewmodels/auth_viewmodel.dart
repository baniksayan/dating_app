import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

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
      await _authRepository.sendOtp(state.email.trim());
      state = state.copyWith(isEmailLoading: false);
      startResendTimer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isEmailLoading: false,
        emailError: 'Failed to send verification code. Please check connection.',
      );
      return false;
    }
  }

  Future<AuthResponse> verifyOtp() async {
    if (state.otp.length != 6) {
      state = state.copyWith(otpError: 'Please enter all 6 digits.');
      return const AuthResponse(isSuccess: false, isOnboardingCompleted: false);
    }

    state = state.copyWith(isOtpLoading: true, clearOtpError: true);

    try {
      final response = await _authRepository.verifyOtp(
        state.email.trim(),
        state.otp.trim(),
      );

      if (response.isSuccess) {
        state = state.copyWith(
          isOtpLoading: false,
          mockVerificationToken: response.token,
        );
      } else {
        state = state.copyWith(
          isOtpLoading: false,
          otpError: response.errorMessage ?? 'Incorrect code. Please try again.',
        );
      }
      return response;
    } catch (e) {
      state = state.copyWith(
        isOtpLoading: false,
        otpError: 'Verification failed. Please try again.',
      );
      return const AuthResponse(isSuccess: false, isOnboardingCompleted: false);
    }
  }

  void startResendTimer() {
    _timer?.cancel();
    state = state.copyWith(resendCountdown: 30, canResend: false);

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
