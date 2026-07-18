import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_router.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/auth_viewmodel.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus the hidden input field on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: Colors.white, size: 20),
          onPressed: () {
            viewModel.resetState();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Verify your email',
                style: context.typography.displayMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Spaced text showing target email
              Wrap(
                children: [
                  Text(
                    'Enter the 6-digit code sent to ',
                    style: context.typography.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    state.email,
                    style: context.typography.body.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Spaced 6-digit OTP fields
              GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Completely invisible TextField that handles keyboards and copy-pastes
                    Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          autofillHints: const [AutofillHints.oneTimeCode],
                          cursorWidth: 0,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          onChanged: (val) async {
                            viewModel.updateOtp(val);
                            if (val.length == 6) {
                              _focusNode.unfocus();
                              final response = await viewModel.verifyOtp();
                              if (response.isSuccess) {
                                if (mounted) {
                                  if (!context.mounted) return;
                                  // Refresh router status
                                  routerConfigNotifier.completeInitialization();
                                  
                                  if (response.isOnboardingCompleted) {
                                    context.go('/swipe');
                                  } else {
                                    context.go('/onboarding');
                                  }
                                }
                              } else {
                                // Error handling - clear local input so user can try again
                                _textController.clear();
                                viewModel.updateOtp('');
                                _focusNode.requestFocus();
                                HapticFeedback.heavyImpact();
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    // 2. Custom visual representation of the 6 digits
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final String char = _textController.text.length > index 
                            ? _textController.text[index] 
                            : '';
                        final bool isFocused = _focusNode.hasFocus && _textController.text.length == index;

                        return Container(
                          width: (context.screenWidth - 48 - 50) / 6, // dynamic layout
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: context.radius.borderLg,
                            border: Border.all(
                              color: state.otpError != null
                                  ? context.colors.error
                                  : (isFocused ? context.colors.primary : context.colors.divider),
                              width: isFocused ? 1.5 : 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            char,
                            style: context.typography.headline.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Error Text
              if (state.otpError != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    state.otpError!,
                    style: context.typography.caption.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Resend code countdown
              Center(
                child: state.canResend
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          _textController.clear();
                          viewModel.updateOtp('');
                          await viewModel.sendOtp();
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Resend code',
                          style: context.typography.button.copyWith(
                            color: context.colors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        'Resend code in 0:${state.resendCountdown.toString().padLeft(2, '0')}',
                        style: context.typography.caption.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
              ),

              const Spacer(),

              // Loader Indicator overlay if OTP checking is active
              if (state.isOtpLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
