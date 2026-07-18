import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

class EmailEntryScreen extends ConsumerStatefulWidget {
  final bool isSignUp;

  const EmailEntryScreen({
    super.key,
    required this.isSignUp,
  });

  @override
  ConsumerState<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends ConsumerState<EmailEntryScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final currentEmail = ref.read(authViewModelProvider).email;
    _controller = TextEditingController(text: currentEmail);
    _focusNode = FocusNode();

    // Auto focus on field startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);
    final bool canContinue = viewModel.isEmailValid;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // Animated Title & Subtitle for Premium feel
              Text(
                widget.isSignUp ? 'Create account' : 'Welcome back',
                style: context.typography.displayMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email to receive a 6-digit verification code.',
                style: context.typography.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Email Input Field
              Text(
                'EMAIL ADDRESS',
                style: context.typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: state.emailError != null ? context.colors.error : context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Custom Text Field container with glassmorphic borders
              Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: context.radius.borderLg,
                  border: Border.all(
                    color: state.emailError != null 
                        ? context.colors.error
                        : (_focusNode.hasFocus ? context.colors.primary : context.colors.divider),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        cursorColor: context.colors.primary,
                        style: context.typography.body.copyWith(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) {
                          viewModel.updateEmail(val);
                          setState(() {}); // trigger rebuild to update button active state
                        },
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          viewModel.updateEmail('');
                          setState(() {});
                        },
                        child: Icon(
                          AppIcons.close,
                          color: context.colors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Error Banner
              if (state.emailError != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.emailError!,
                  style: context.typography.caption.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ],

              const Spacer(),

              // Submit Button
              PrimaryButton(
                text: 'Continue',
                isDisabled: !canContinue,
                isLoading: state.isEmailLoading,
                onTap: () async {
                  // Resign keyboard focus
                  _focusNode.unfocus();
                  
                  final bool success = await viewModel.sendOtp();
                  if (success && mounted) {
                    if (!context.mounted) return;
                    context.go('/auth/otp');
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
