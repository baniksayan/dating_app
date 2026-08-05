import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/config/app_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/storage/hive_service.dart';
import '../../models/onboarding_state.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_photo_grid.dart';
import '../widgets/onboarding_photo_tips_modal.dart';
import '../widgets/why_we_ask_sheet.dart';
import '../widgets/age_confirmation_dialog.dart';
import '../../repositories/location_repository.dart';
import '../../../../core/helpers/debouncer.dart';
import '../../../../core/config/languages_data.dart';
import '../../repositories/career_repository.dart';
import '../../repositories/master_data_repository.dart';
import '../../models/all_master_data_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hometownController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  // Suggestions state for Hometown input
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;
  final _debouncer = Debouncer(milliseconds: 500);
  final List<String> _customAddedLanguages = [];
  bool _isLoadingLocation = false;

  // Occupation / Job suggestions state
  List<String> _jobSuggestions = [];
  bool _isLoadingJobs = false;
  final _jobDebouncer = Debouncer(milliseconds: 300);
  final FocusNode _jobFocusNode = FocusNode();

  // Company suggestions state
  List<CompanySuggestion> _companySuggestions = [];
  bool _isLoadingCompanies = false;
  final _companyDebouncer = Debouncer(milliseconds: 500);
  final FocusNode _companyFocusNode = FocusNode();

  // Prompts and Opening Moves
  final List<String> _promptQuestions = [
    'A perfect Sunday looks like...',
    'I\'m looking for a partner who...',
    'My ideal travel companion is...',
    'Let\'s debate this topic...',
    'Most people don\'t know that I...',
  ];

  // Selected questions for step 13 prompts
  String _promptQ1 = 'A perfect Sunday looks like...';
  String _promptQ2 = 'I\'m looking for a partner who...';
  final TextEditingController _promptA1Controller = TextEditingController();
  final TextEditingController _promptA2Controller = TextEditingController();

  String _openingQ = 'Would you rather travel to the future or the past?';
  final TextEditingController _openingAController = TextEditingController();
  final TextEditingController _customOpeningQController =
      TextEditingController();
  bool _useCustomOpeningQ = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _jobFocusNode.addListener(() {
      if (!_jobFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _jobSuggestions = [];
            });
          }
        });
      }
    });

    _companyFocusNode.addListener(() {
      if (!_companyFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _companySuggestions = [];
            });
          }
        });
      }
    });

    // Listen to changes in onboarding state to update controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingViewModelProvider);
      _nameController.text = state.firstName;
      _hometownController.text = state.hometown ?? '';
      _jobController.text = state.jobTitle ?? '';
      _companyController.text = state.company ?? '';

      final prompts = state.personalityPrompts;
      if (prompts.length >= 2) {
        final entries = prompts.entries.toList();
        _promptQ1 = entries[0].key;
        _promptA1Controller.text = entries[0].value;
        _promptQ2 = entries[1].key;
        _promptA2Controller.text = entries[1].value;
      }

      if (state.openingQuestion != null) {
        _openingQ = state.openingQuestion!;
      }
      _openingAController.text = state.openingAnswer ?? '';

      if (state.currentStep > 1 && _pageController.hasClients) {
        _pageController.jumpToPage(state.currentStep - 1);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _hometownController.dispose();
    _jobController.dispose();
    _companyController.dispose();
    _promptA1Controller.dispose();
    _promptA2Controller.dispose();
    _openingAController.dispose();
    _customOpeningQController.dispose();
    _debouncer.dispose();
    _jobFocusNode.dispose();
    _companyFocusNode.dispose();
    _jobDebouncer.dispose();
    _companyDebouncer.dispose();
    super.dispose();
  }

  void _handleStepTransition(int targetPage) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPage,
        duration: AppDurations.medium,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  String _getEmojiForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('female') || l.contains('woman') || l.contains('women')) {
      return '👩';
    }
    if (l.contains('male') || l.contains('man') || l.contains('men')) {
      return '👨';
    }
    if (l.contains('non-binary') || l.contains('everyone')) {
      return '✨';
    }
    if (l.contains('long-term')) {
      return '💎';
    }
    if (l.contains('life partner') || l.contains('marriage')) {
      return '👥';
    }
    if (l.contains('short-term') ||
        l.contains('casual') ||
        l.contains('dates') ||
        l.contains('coffee')) {
      return '☕';
    }
    if (l.contains('figuring') || l.contains('open')) {
      return '🧭';
    }
    if (l.contains('high school')) {
      return '🎓';
    }
    if (l.contains('bachelor')) {
      return '📜';
    }
    if (l.contains('master')) {
      return '📚';
    }
    if (l.contains('phd') || l.contains('doctorate')) {
      return '🔬';
    }
    if (l.contains('never')) {
      return '🙅';
    }
    if (l.contains('social')) {
      return '🍷';
    }
    if (l.contains('occasion')) {
      return '🍸';
    }
    if (l.contains('regular')) {
      return '🍻';
    }
    if (l.contains('quit') || l.contains('trying')) {
      return '⏳';
    }
    if (l.contains('smoke') || l.contains('smoking')) {
      return '🚬';
    }
    if (l.contains('active') || l.contains('daily')) {
      return '⚡';
    }
    if (l.contains('often') || l.contains('run')) {
      return '🏃';
    }
    if (l.contains('sometimes') || l.contains('walk')) {
      return '🚶';
    }
    if (l.contains('relax') || l.contains('couch')) {
      return '🛋️';
    }
    if (l.contains('early') || l.contains('bird') || l.contains('morning')) {
      return '🌅';
    }
    if (l.contains('night') || l.contains('owl')) {
      return '🦉';
    }
    if (l.contains('irregular')) {
      return '🌀';
    }
    if (l.contains('everything') || l.contains('omnivore')) {
      return '🍽️';
    }
    if (l.contains('veg') && !l.contains('vegan')) {
      return '🥗';
    }
    if (l.contains('vegan')) {
      return '🌱';
    }
    if (l.contains('gluten')) {
      return '🌾';
    }
    if (l.contains('halal')) {
      return '☪️';
    }
    if (l.contains('kosher')) {
      return '✡️';
    }
    if (l.contains('have children') || l.contains('have kids')) {
      return '👶';
    }
    if (l.contains('want children') || l.contains('want kids')) {
      return '🍼';
    }
    if (l.contains('don\'t want children') || l.contains('no kids')) {
      return '🙅';
    }
    if (l.contains('dog')) {
      return '🐶';
    }
    if (l.contains('cat')) {
      return '🐱';
    }
    if (l.contains('other pets') || l.contains('fish')) {
      return '🐠';
    }
    if (l.contains('love them')) {
      return '🐾';
    }
    if (l.contains('no pets')) {
      return '🚫';
    }
    if (l.contains('text')) {
      return '📱';
    }
    if (l.contains('call') || l.contains('phone')) {
      return '📞';
    }
    if (l.contains('person') || l.contains('face')) {
      return '🤝';
    }
    if (l.contains('video')) {
      return '📹';
    }
    if (l.contains('words') || l.contains('affirmation')) {
      return '💬';
    }
    if (l.contains('quality') || l.contains('time')) {
      return '⏰';
    }
    if (l.contains('gift')) {
      return '🎁';
    }
    if (l.contains('service')) {
      return '🛠️';
    }
    if (l.contains('touch')) {
      return '🤝';
    }
    if (l.contains('liberal')) {
      return '🗽';
    }
    if (l.contains('conservative')) {
      return '🦅';
    }
    if (l.contains('moderate')) {
      return '⚖️';
    }
    if (l.contains('independent')) {
      return '🌀';
    }
    return '✨';
  }

  void _fetchSuggestions(String query) {
    if (query.trim().isEmpty) {
      _debouncer.dispose();
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    _debouncer.run(() async {
      if (!mounted) return;
      setState(() => _isLoadingSuggestions = true);

      try {
        final results = await ref
            .read(locationRepositoryProvider)
            .getCitySuggestions(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoadingSuggestions = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoadingSuggestions = false;
          });
        }
      }
    });
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Material(
        color: context.colors.card,
        borderRadius: context.radius.borderLg,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: context.radius.borderLg,
            border: Border.all(color: context.colors.divider),
          ),
          child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.colors.divider, height: 1),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            title: Text(
              suggestion,
              style: context.typography.body.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            dense: true,
            trailing: Icon(
              CupertinoIcons.location_fill,
              color: context.colors.accent,
              size: 14,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              _hometownController.text = suggestion;
              viewModel.updateHometown(suggestion);
              setState(() {
                _suggestions = [];
              });
            },
          );
        },
      ),
    ),
  ),
);
}

  void _showLanguageSearchBottomSheet(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _LanguageSearchWidget(
          selectedLanguages: state.languages,
          onLanguageSelected: (lang) {
            if (!_customAddedLanguages.contains(lang)) {
              setState(() {
                _customAddedLanguages.add(lang);
              });
            }
            final updated = List<String>.from(state.languages);
            if (!updated.contains(lang)) {
              updated.add(lang);
              viewModel.updateLanguages(updated);
            }
          },
        );
      },
    );
  }

  void _fetchJobSuggestions(String query) {
    if (query.trim().isEmpty) {
      _jobDebouncer.dispose();
      setState(() {
        _jobSuggestions = [];
        _isLoadingJobs = false;
      });
      return;
    }

    _jobDebouncer.run(() async {
      if (!mounted) return;
      setState(() => _isLoadingJobs = true);
      try {
        final results = await ref
            .read(careerRepositoryProvider)
            .getJobSuggestions(query);
        if (mounted) {
          setState(() {
            _jobSuggestions = results;
            _isLoadingJobs = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _jobSuggestions = [];
            _isLoadingJobs = false;
          });
        }
      }
    });
  }

  void _fetchCompanySuggestions(String query) {
    if (query.trim().isEmpty) {
      _companyDebouncer.dispose();
      setState(() {
        _companySuggestions = [];
        _isLoadingCompanies = false;
      });
      return;
    }

    _companyDebouncer.run(() async {
      if (!mounted) return;
      setState(() => _isLoadingCompanies = true);
      try {
        final results = await ref
            .read(careerRepositoryProvider)
            .getCompanySuggestions(query);
        if (mounted) {
          setState(() {
            _companySuggestions = results;
            _isLoadingCompanies = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _companySuggestions = [];
            _isLoadingCompanies = false;
          });
        }
      }
    });
  }

  Widget _buildJobSuggestionsList(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Material(
        color: context.colors.card,
        borderRadius: context.radius.borderLg,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: context.radius.borderLg,
            border: Border.all(color: context.colors.divider),
          ),
          child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _jobSuggestions.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.colors.divider, height: 1),
        itemBuilder: (context, index) {
          final suggestion = _jobSuggestions[index];
          return ListTile(
            title: Text(
              suggestion,
              style: context.typography.body.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            dense: true,
            onTap: () {
              HapticFeedback.lightImpact();
              _jobController.text = suggestion;
              viewModel.updateJobTitle(suggestion);
              setState(() {
                _jobSuggestions = [];
              });
            },
          );
        },
      ),
    ),
  ),
);
}

  Widget _buildCompanySuggestionsList(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Material(
        color: context.colors.card,
        borderRadius: context.radius.borderLg,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: context.radius.borderLg,
            border: Border.all(color: context.colors.divider),
          ),
          child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _companySuggestions.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.colors.divider, height: 1),
        itemBuilder: (context, index) {
          final suggestion = _companySuggestions[index];
          return ListTile(
            leading: suggestion.logoUrl != null
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      suggestion.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.business,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ),
                  )
                : const Icon(Icons.business, color: Colors.white30, size: 16),
            title: Text(
              suggestion.name,
              style: context.typography.body.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            dense: true,
            onTap: () {
              HapticFeedback.lightImpact();
              _companyController.text = suggestion.name;
              viewModel.updateCompany(suggestion.name);
              setState(() {
                _companySuggestions = [];
              });
            },
          );
        },
      ),
    ),
  ),
);
}

  String _formatHeight(int cm) {
    final double inchesTotal = cm / 2.54;
    final int feet = inchesTotal ~/ 12;
    final int inches = (inchesTotal % 12).round();
    return "$cm cm ($feet'$inches\")";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final masterDataAsync = ref.watch(masterDataProvider);
    final AllMasterData? masterData = masterDataAsync.value;

    final double progress = state.currentStep / 15.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (state.currentStep >= 13) {
          SystemNavigator.pop();
        } else if (state.currentStep > 1) {
          viewModel.prevStep();
          _handleStepTransition(state.currentStep - 2);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: (state.currentStep > 1 && state.currentStep < 13)
              ? IconButton(
                  icon: const Icon(AppIcons.back, color: Colors.white, size: 20),
                  onPressed: () {
                    viewModel.prevStep();
                    _handleStepTransition(state.currentStep - 2);
                  },
                )
              : null,
          title: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              width: 140,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                color: context.colors.primary,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            if (state.currentStep == 12)
              IconButton(
                icon: Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: context.colors.accent,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const OnboardingPhotoTipsModal(),
                  );
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // API Loading / Error Banner
              if (masterDataAsync.isLoading)
                LinearProgressIndicator(
                  color: context.colors.primary,
                  backgroundColor: Colors.transparent,
                  minHeight: 2,
                ),
              if (masterDataAsync.hasError)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load dynamic options. Using local defaults.',
                          style: context.typography.caption.copyWith(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(masterDataProvider),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildNameStep(context, state, viewModel),
                    _buildBirthdayStep(context, state, viewModel, masterData),
                    _buildGenderStep(context, state, viewModel, masterData),
                    _buildIntentionStep(context, state, viewModel, masterData),
                    _buildBackgroundStep(context, state, viewModel, masterData),
                    _buildCareerStep(context, state, viewModel, masterData),
                    _buildHabitsStep(context, state, viewModel, masterData),
                    _buildFamilyStep(context, state, viewModel, masterData),
                    _buildPersonalityStyleStep(
                      context,
                      state,
                      viewModel,
                      masterData,
                    ),
                    _buildFaithStep(context, state, viewModel, masterData),
                    _buildInterestsStep(context, state, viewModel),
                    _buildPhotosStep(context, state, viewModel),
                    _buildPromptsStep(context, state, viewModel),
                    _buildOpeningMoveStep(context, state, viewModel, masterData),
                    _buildPreviewStep(context, state, viewModel),
                  ],
                ),
              ),

              if (state.currentStep < 15)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: PrimaryButton(
                    text: 'Continue',
                    isLoading: state.isLoading,
                    isDisabled: !viewModel.isStepValid(
                      state.currentStep,
                      masterData?.data?.ageRange?.min ?? 18,
                      masterData?.data?.ageRange?.max ?? 100,
                    ),
                    onTap: () async {
                      if (state.currentStep == 2) {
                        final confirmed = await AgeConfirmationDialog.show(
                          context,
                          age: viewModel.calculatedAge,
                        );
                        if (confirmed != true) return;
                      }

                      if (state.currentStep == 12) {
                        // Call /upload-photo.php when user taps Continue on Step 12
                        final uploadRes = await viewModel.uploadPhotos();
                        if (uploadRes.status != 'success') {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(uploadRes.message ?? 'Photo upload failed. Please try again.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                      }

                      viewModel.nextStep();
                      _handleStepTransition(state.currentStep);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 1: Name
  Widget _buildNameStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What is your name?',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how you will appear on your profile. Name must be at least 2 characters.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'FULL NAME',
            style: context.typography.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: context.radius.borderLg,
              border: Border.all(color: context.colors.divider),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameController,
              cursorColor: context.colors.primary,
              style: context.typography.body.copyWith(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                viewModel.updateFirstName(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Birthday & Zodiac
  Widget _buildBirthdayStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final DateTime now = DateTime.now();
    final apiAgeRange = masterData?.data?.ageRange;
    final int minAge = apiAgeRange?.min ?? 18;
    final int maxAge = apiAgeRange?.max ?? 100;

    final DateTime initialDate =
        state.dateOfBirth ??
        DateTime(now.year - (minAge + 2), now.month, now.day);

    final bool isAgeValid = viewModel.isAgeValid(minAge, maxAge);
    final int calculatedAge = viewModel.calculatedAge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'When is your birthday?',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            maxAge < 100
                ? 'You must be between $minAge and $maxAge years old to join.'
                : 'You must be $minAge or older to join.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: context.colors.surface,
                builder: (BuildContext context) {
                  return Container(
                    height: 260,
                    padding: const EdgeInsets.only(top: 6),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate,
                      maximumDate: now,
                      minimumYear: now.year - maxAge,
                      maximumYear: now.year,
                      onDateTimeChanged: (DateTime date) {
                        viewModel.updateDateOfBirth(date);
                      },
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.radius.borderLg,
                border: Border.all(
                  color: state.dateOfBirth != null && !isAgeValid
                      ? context.colors.error
                      : context.colors.divider,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.dateOfBirth != null
                        ? '${state.dateOfBirth!.day.toString().padLeft(2, '0')} / ${state.dateOfBirth!.month.toString().padLeft(2, '0')} / ${state.dateOfBirth!.year}'
                        : 'Select birthdate',
                    style: context.typography.body.copyWith(
                      color: state.dateOfBirth != null
                          ? Colors.white
                          : Colors.white30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.calendar,
                    color: context.colors.accent,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (state.dateOfBirth != null && !isAgeValid) ...[
            const SizedBox(height: 16),
            Text(
              calculatedAge < minAge
                  ? 'You must be at least $minAge years old to join.'
                  : 'Age must not exceed $maxAge years.',
              style: context.typography.caption.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 3: Gender & Preferences
  Widget _buildGenderStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiGenders = masterData?.data?.genders ?? [];
    final genders = apiGenders.isNotEmpty
        ? apiGenders.map((g) => g.displayText).toList()
        : ['Female', 'Male', 'Non-binary'];

    final apiShowMe = masterData?.data?.showMe ?? [];
    final preferences = apiShowMe.isNotEmpty
        ? apiShowMe.map((p) => p.displayText).toList()
        : ['Men', 'Women', 'Everyone'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Who are you?',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'GENDER IDENTITY',
            style: context.typography.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: genders.map((g) {
              final isSel = state.gender == g.toLowerCase();
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.updateGender(g.toLowerCase());
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSel
                          ? context.colors.primary
                          : context.colors.surface,
                      borderRadius: context.radius.borderMd,
                      border: Border.all(
                        color: isSel
                            ? context.colors.primary
                            : context.colors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g,
                      style: context.typography.label.copyWith(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 36),
          Text(
            'SHOW ME',
            style: context.typography.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: preferences.map((p) {
              final isSel = state.interestedIn == p.toLowerCase();
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.updateInterestedIn(p.toLowerCase());
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSel
                          ? context.colors.primary
                          : context.colors.surface,
                      borderRadius: context.radius.borderMd,
                      border: Border.all(
                        color: isSel
                            ? context.colors.primary
                            : context.colors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p,
                      style: context.typography.label.copyWith(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 4: Relationship Goals
  Widget _buildIntentionStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiGoals = masterData?.data?.relationshipGoals ?? [];
    final colors = [
      const Color(0xFFEF9A9A),
      const Color(0xFFF48FB1),
      const Color(0xFFFFCC80),
      const Color(0xFF80CBC4),
      const Color(0xFFCE93D8),
    ];

    final intentions = apiGoals.isNotEmpty
        ? apiGoals.asMap().entries.map((entry) {
            final idx = entry.key;
            final g = entry.value;
            final title = g.displayText;
            final emoji = g.emoji ?? _getEmojiForLabel(title);
            final color = colors[idx % colors.length];
            return {'title': title, 'emoji': emoji, 'color': color};
          }).toList()
        : [
            {
              'title': 'Long-term relationship',
              'emoji': '💎',
              'color': const Color(0xFFEF9A9A),
            },
            {
              'title': 'Life partner',
              'emoji': '👥',
              'color': const Color(0xFFF48FB1),
            },
            {
              'title': 'Open to short-term',
              'emoji': '☕',
              'color': const Color(0xFFFFCC80),
            },
            {
              'title': 'Figuring it out',
              'emoji': '🧭',
              'color': const Color(0xFF80CBC4),
            },
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Relationship Goals',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Honesty is key. This helps us match you with users seeking the same goals.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: intentions.length,
              itemBuilder: (context, index) {
                final item = intentions[index];
                final title = item['title'] as String;
                final emoji = item['emoji'] as String;
                final iconColor = item['color'] as Color;
                final bool isSel = state.intention == title;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.updateIntention(title);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel
                            ? context.colors.primary
                            : context.colors.divider,
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconColor.withValues(alpha: 0.15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: context.typography.title.copyWith(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isSel)
                          Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: context.colors.primary,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 5: Background & Origin (Height, Hometown, Languages)
  Widget _buildBackgroundStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final minH = (masterData?.data?.heightRange?.min ?? 140).toDouble();
    final maxH = (masterData?.data?.heightRange?.max ?? 210).toDouble();
    double currentHeight = (state.height ?? 170).toDouble();
    if (currentHeight < minH) currentHeight = minH;
    if (currentHeight > maxH) currentHeight = maxH;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'About you',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help matches learn about your origin and background. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Height Slider
                Text(
                  'HEIGHT: ${_formatHeight(currentHeight.toInt())}',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Slider(
                  value: currentHeight,
                  min: minH,
                  max: maxH,
                  activeColor: context.colors.primary,
                  inactiveColor: context.colors.divider,
                  onChanged: (val) {
                    viewModel.updateHeight(val.round());
                  },
                ),
                const SizedBox(height: 24),

                // Hometown field
                Text(
                  'HOMETOWN',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: context.radius.borderLg,
                    border: Border.all(color: context.colors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hometownController,
                          style: context.typography.body.copyWith(
                            color: Colors.white,
                          ),
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'e.g. San Francisco, CA',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            viewModel.updateHometown(val);
                            _fetchSuggestions(val);
                          },
                        ),
                      ),
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.location_fill,
                            color: context.colors.primary,
                            size: 20,
                          ),
                          tooltip: 'Detect My Location',
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _isLoadingLocation = true);
                            try {
                              final position = await viewModel
                                  .detectUserLocation();
                              if (position != null) {
                                final city = await ref
                                    .read(locationRepositoryProvider)
                                    .getCityFromCoordinates(
                                      position.latitude,
                                      position.longitude,
                                    );
                                if (city != null && mounted) {
                                  _hometownController.text = city;
                                  viewModel.updateHometown(city);
                                }
                              } else {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not detect location. Please enter manually.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (_) {
                              // Fallback to manual entry silently
                            } finally {
                              if (mounted) {
                                setState(() => _isLoadingLocation = false);
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
                if (_isLoadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 16),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else if (_suggestions.isNotEmpty)
                  _buildSuggestionsList(context, viewModel),
                const SizedBox(height: 28),

                // Languages
                Text(
                  'LANGUAGES SPOKEN (MAX 5)',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    const defaultTopLanguages = [
                      'English',
                      'Spanish',
                      'French',
                      'German',
                      'Italian',
                      'Chinese',
                      'Japanese',
                      'Hindi',
                    ];
                    for (final lang in state.languages) {
                      if (!defaultTopLanguages.contains(lang) &&
                          !_customAddedLanguages.contains(lang)) {
                        _customAddedLanguages.add(lang);
                      }
                    }

                    final visibleLanguages = <String>{
                      ...defaultTopLanguages,
                      ..._customAddedLanguages,
                    }.toList();
                    final isMaxReached = state.languages.length >= 5;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...visibleLanguages.map((lang) {
                          final isSel = state.languages.contains(lang);
                          final isEnabled = isSel || !isMaxReached;

                          return Opacity(
                            opacity: isEnabled ? 1.0 : 0.4,
                            child: ChoiceChip(
                              label: Text(lang),
                              selected: isSel,
                              onSelected: isEnabled
                                  ? (selected) {
                                      HapticFeedback.lightImpact();
                                      final list = List<String>.from(
                                        state.languages,
                                      );
                                      if (selected) {
                                        list.add(lang);
                                      } else {
                                        list.remove(lang);
                                      }
                                      viewModel.updateLanguages(list);
                                    }
                                  : null,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.black : Colors.white,
                              ),
                              selectedColor: context.colors.primary,
                              backgroundColor: context.colors.surface,
                            ),
                          );
                        }),

                        if (state.languages.length < 5)
                          ChoiceChip(
                            label: const Text('+ More'),
                            selected: false,
                            onSelected: (_) {
                              HapticFeedback.lightImpact();
                              _showLanguageSearchBottomSheet(
                                context,
                                state,
                                viewModel,
                              );
                            },
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: context.colors.surface,
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 6: Education & Career
  Widget _buildCareerStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiEdu = masterData?.data?.educationLevels ?? [];
    final educationOptions = apiEdu.isNotEmpty
        ? apiEdu
              .map(
                (e) => {
                  'label': e.displayText,
                  'emoji': e.emoji ?? _getEmojiForLabel(e.displayText),
                },
              )
              .toList()
        : [
            {'label': 'High School', 'emoji': '🎓'},
            {'label': 'Bachelors Degree', 'emoji': '📜'},
            {'label': 'Masters Degree', 'emoji': '📚'},
            {'label': 'PhD / Doctorate', 'emoji': '🔬'},
            {'label': 'Other', 'emoji': '📝'},
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Education & Career',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your professional and educational goals. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Text(
                  'EDUCATION LEVEL',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                ChoiceGrid(
                  options: educationOptions,
                  selectedValue: state.education,
                  onSelected: viewModel.updateEducation,
                ),
                const SizedBox(height: 28),

                Text(
                  'OCCUPATION / JOB TITLE',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: context.radius.borderLg,
                    border: Border.all(color: context.colors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _jobController,
                    focusNode: _jobFocusNode,
                    style: context.typography.body.copyWith(
                      color: Colors.white,
                    ),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Design Director',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      viewModel.updateJobTitle(val);
                      _fetchJobSuggestions(val);
                    },
                  ),
                ),
                if (_isLoadingJobs)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 16),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else if (_jobSuggestions.isNotEmpty)
                  _buildJobSuggestionsList(context, viewModel),
                const SizedBox(height: 24),

                Text(
                  'COMPANY / WORKPLACE',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: context.radius.borderLg,
                    border: Border.all(color: context.colors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _companyController,
                    focusNode: _companyFocusNode,
                    style: context.typography.body.copyWith(
                      color: Colors.white,
                    ),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Google',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      viewModel.updateCompany(val);
                      _fetchCompanySuggestions(val);
                    },
                  ),
                ),
                if (_isLoadingCompanies)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 16),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else if (_companySuggestions.isNotEmpty)
                  _buildCompanySuggestionsList(context, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 7: Lifestyle Choices (Drinking, Smoking, Diet, Exercise, Sleep)
  Widget _buildHabitsStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiSmoking = masterData?.data?.smokingHabits ?? [];
    final smokingOptions = apiSmoking.isNotEmpty
        ? apiSmoking
              .map(
                (s) => {
                  'label': s.displayText,
                  'emoji': s.emoji ?? _getEmojiForLabel(s.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Never', 'emoji': '🚭'},
            {'label': 'Social smoker', 'emoji': '💨'},
            {'label': 'Occasional smoker', 'emoji': '🚬'},
            {'label': 'Regular smoker', 'emoji': '🔥'},
            {'label': 'Trying to quit', 'emoji': '⏳'},
            {'label': 'Prefer not to say', 'emoji': '🤫'},
          ];

    final apiDrinking = masterData?.data?.drinkingHabits ?? [];
    final drinkingOptions = apiDrinking.isNotEmpty
        ? apiDrinking
              .map(
                (d) => {
                  'label': d.displayText,
                  'emoji': d.emoji ?? _getEmojiForLabel(d.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Never', 'emoji': '🙅'},
            {'label': 'Socially', 'emoji': '🍷'},
            {'label': 'Occasional', 'emoji': '🍸'},
            {'label': 'Regularly', 'emoji': '🍻'},
            {'label': 'Prefer not to say', 'emoji': '🤫'},
          ];

    final apiFitness = masterData?.data?.fitnessLevels ?? [];
    final exerciseOptions = apiFitness.isNotEmpty
        ? apiFitness
              .map(
                (f) => {
                  'label': f.displayText,
                  'emoji': f.emoji ?? _getEmojiForLabel(f.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Active daily', 'emoji': '⚡'},
            {'label': 'Often', 'emoji': '🏃'},
            {'label': 'Sometimes', 'emoji': '🚶'},
            {'label': 'Never', 'emoji': '🛋️'},
          ];

    final apiSleep = masterData?.data?.sleepSchedules ?? [];
    final sleepOptions = apiSleep.isNotEmpty
        ? apiSleep
              .map(
                (s) => {
                  'label': s.displayText,
                  'emoji': s.emoji ?? _getEmojiForLabel(s.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Early bird', 'emoji': '🌅'},
            {'label': 'Night owl', 'emoji': '🦉'},
            {'label': 'Irregular', 'emoji': '🌀'},
          ];

    final apiDiet = masterData?.data?.dietaryPreferences ?? [];
    final dietOptions = apiDiet.isNotEmpty
        ? apiDiet
              .map(
                (d) => {
                  'label': d.displayText,
                  'emoji': d.emoji ?? _getEmojiForLabel(d.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Everything', 'emoji': '🍽️'},
            {'label': 'Vegetarian', 'emoji': '🥗'},
            {'label': 'Vegan', 'emoji': '🌱'},
            {'label': 'Gluten-free', 'emoji': '🌾'},
            {'label': 'Halal', 'emoji': '☪️'},
            {'label': 'Kosher', 'emoji': '✡️'},
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Lifestyle Habits',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visual visual indicators represent choices. Tap help if needed. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildOptionSectionHeader(
                  context,
                  'SMOKING HABITS',
                  'Habit detail',
                  'We support a clean taxonomy for smoking habits. Social smokers smoke primarily in social venues, while occasional smokers smoke infrequently generally.',
                ),
                ChoiceGrid(
                  options: smokingOptions,
                  selectedValue: state.smoking,
                  onSelected: viewModel.updateSmoking,
                ),
                const SizedBox(height: 28),

                _buildOptionSectionHeader(
                  context,
                  'DRINKING HABITS',
                  'Alcohol choice',
                  'Share how frequently you enjoy a drink. This helps set compatibility preferences.',
                ),
                ChoiceGrid(
                  options: drinkingOptions,
                  selectedValue: state.drinking,
                  onSelected: viewModel.updateDrinking,
                ),
                const SizedBox(height: 28),

                _buildOptionSectionHeader(
                  context,
                  'FITNESS & EXERCISE',
                  'Activity',
                  'Are you active daily, often, sometimes, or do you prefer relaxing?',
                ),
                ChoiceGrid(
                  options: exerciseOptions,
                  selectedValue: state.exercise,
                  onSelected: viewModel.updateExercise,
                ),
                const SizedBox(height: 28),

                _buildOptionSectionHeader(
                  context,
                  'SLEEP SCHEDULE',
                  'Chronotype',
                  'Are you an early-bird rising with the sun, or a night-owl active in the evenings?',
                ),
                ChoiceGrid(
                  options: sleepOptions,
                  selectedValue: state.sleepSchedule,
                  onSelected: viewModel.updateSleepSchedule,
                ),
                const SizedBox(height: 28),

                _buildOptionSectionHeader(
                  context,
                  'DIETARY PREFERENCES',
                  'Diet type',
                  'Select what best describes your typical daily dietary values.',
                ),
                ChoiceGrid(
                  options: dietOptions,
                  selectedValue: state.diet,
                  onSelected: viewModel.updateDiet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSectionHeader(
    BuildContext context,
    String title,
    String helpTitle,
    String explanation,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: context.typography.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    WhyWeAskSheet(title: helpTitle, explanation: explanation),
              );
            },
            child: Icon(
              CupertinoIcons.question_circle,
              color: context.colors.accent,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // STEP 8: Family Plans & Pets
  Widget _buildFamilyStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiFamily = masterData?.data?.familyPlans ?? [];
    final familyOptions = apiFamily.isNotEmpty
        ? apiFamily
              .map(
                (f) => {
                  'label': f.displayText,
                  'emoji': f.emoji ?? _getEmojiForLabel(f.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Have children', 'emoji': '👶'},
            {'label': 'Want children', 'emoji': '🍼'},
            {'label': 'Don\'t want children', 'emoji': '🙅'},
            {'label': 'Open / Not sure', 'emoji': '🤷'},
          ];

    final apiPets = masterData?.data?.petPreferences ?? [];
    final petOptions = apiPets.isNotEmpty
        ? apiPets
              .map(
                (p) => {
                  'label': p.displayText,
                  'emoji': p.emoji ?? _getEmojiForLabel(p.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Dog owner', 'emoji': '🐶'},
            {'label': 'Cat owner', 'emoji': '🐱'},
            {'label': 'Have other pets', 'emoji': '🐠'},
            {'label': 'Love them but none', 'emoji': '🐾'},
            {'label': 'No pets', 'emoji': '🚫'},
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Family & Pets',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell matches about your kids, family desires, and pet preferences. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Text(
                  'FAMILY PLANS',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ChoiceGrid(
                  options: familyOptions,
                  selectedValue: state.familyPlans,
                  onSelected: viewModel.updateFamilyPlans,
                ),
                const SizedBox(height: 32),

                Text(
                  'PETS IN YOUR LIFE',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: petOptions.map((opt) {
                    final label = opt['label']!;
                    final emoji = opt['emoji']!;
                    final isSel = state.pets.contains(label);
                    return ChoiceChip(
                      label: Text('$emoji $label'),
                      selected: isSel,
                      onSelected: (selected) {
                        HapticFeedback.lightImpact();
                        final list = List<String>.from(state.pets);
                        if (selected) {
                          list.add(label);
                        } else {
                          list.remove(label);
                        }
                        viewModel.updatePets(list);
                      },
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                      ),
                      selectedColor: context.colors.primary,
                      backgroundColor: context.colors.surface,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 9: Communication & Love Language
  Widget _buildPersonalityStyleStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiComm = masterData?.data?.communicationStyles ?? [];
    final commOptions = apiComm.isNotEmpty
        ? apiComm
              .map(
                (c) => {
                  'label': c.displayText,
                  'emoji': c.emoji ?? _getEmojiForLabel(c.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Texter', 'emoji': '📱'},
            {'label': 'Caller', 'emoji': '📞'},
            {'label': 'In-person', 'emoji': '🤝'},
            {'label': 'Video chat', 'emoji': '📹'},
          ];

    final apiLove = masterData?.data?.loveLanguages ?? [];
    final loveOptions = apiLove.isNotEmpty
        ? apiLove
              .map(
                (l) => {
                  'label': l.displayText,
                  'emoji': l.emoji ?? _getEmojiForLabel(l.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Words of affirmation', 'emoji': '💬'},
            {'label': 'Quality time', 'emoji': '⏰'},
            {'label': 'Receiving gifts', 'emoji': '🎁'},
            {'label': 'Acts of service', 'emoji': '🛠️'},
            {'label': 'Physical touch', 'emoji': '🤝'},
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Connection style',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share how you best express affection and stay in touch. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Text(
                  'COMMUNICATION STYLE',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ChoiceGrid(
                  options: commOptions,
                  selectedValue: state.communicationStyle,
                  onSelected: viewModel.updateCommunicationStyle,
                ),
                const SizedBox(height: 32),

                Text(
                  'PRIMARY LOVE LANGUAGE',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ChoiceGrid(
                  options: loveOptions,
                  selectedValue: state.loveLanguage,
                  onSelected: viewModel.updateLoveLanguage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 10: Faith & Values (Religion, Politics)
  Widget _buildFaithStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiReligions = masterData?.data?.religions ?? [];
    final religions = apiReligions.isNotEmpty
        ? apiReligions.map((r) => r.displayText).toList()
        : [
            'Christian',
            'Jewish',
            'Muslim',
            'Buddhist',
            'Hindu',
            'Atheist',
            'Spiritual',
            'Agnostic',
          ];

    final apiPolitics = masterData?.data?.politicalViews ?? [];
    final politics = apiPolitics.isNotEmpty
        ? apiPolitics
              .map(
                (p) => {
                  'label': p.displayText,
                  'emoji': p.emoji ?? _getEmojiForLabel(p.displayText),
                },
              )
              .toList()
        : [
            {'label': 'Liberal', 'emoji': '🗽'},
            {'label': 'Conservative', 'emoji': '🦅'},
            {'label': 'Moderate', 'emoji': '⚖️'},
            {'label': 'Independent', 'emoji': '🌀'},
            {'label': 'Other', 'emoji': '🗳️'},
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Faith & Values',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These fields are sensitive and completely optional. Skip if preferred.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Text(
                  'RELIGION / SPIRITUALITY',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: religions.map((opt) {
                    final isSel = state.religion == opt;
                    return ChoiceChip(
                      label: Text(opt),
                      selected: isSel,
                      onSelected: (selected) {
                        HapticFeedback.lightImpact();
                        viewModel.updateReligion(selected ? opt : null);
                      },
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                      ),
                      selectedColor: context.colors.primary,
                      backgroundColor: context.colors.surface,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                Text(
                  'POLITICAL VIEWS',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                ChoiceGrid(
                  options: politics,
                  selectedValue: state.politics,
                  onSelected: viewModel.updatePolitics,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 11: Interests
  Widget _buildInterestsStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    final list = [
      'Art',
      'Design',
      'Architecture',
      'Travel',
      'Espresso',
      'Sketching',
      'Jazz Piano',
      'Brutalism',
      'Vinyl',
      'Sailing',
      'Violin',
      'Human Behavior',
      'Indie Rock',
      'Hike',
      'Matcha',
      'Aviation',
      'Deep House',
      'Fitness',
      'Fashion',
      'Film Photography',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Select your interests',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose at least 3 interests to display on your profile (${state.interests.length} selected).',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: list.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final item = list[index];
                final isSel = state.interests.contains(item);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    viewModel.toggleInterest(item);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel
                          ? context.colors.primary
                          : context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel
                            ? context.colors.primary
                            : context.colors.divider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item,
                      style: context.typography.label.copyWith(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 12: Photos Grid
  Widget _buildPhotosStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Upload profile photos',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add at least 4 photos to continue. Long press and drag to reorder. The first slot represents your main profile image.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: OnboardingPhotoGrid(
              photos: state.photos,
              onPhotoAdded: viewModel.addPhoto,
              onPhotoRemoved: viewModel.removePhoto,
              onPhotosReordered: viewModel.reorderPhotos,
            ),
          ),
        ],
      ),
    );
  }

  // STEP 13: Personality Prompts
  Widget _buildPromptsStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Profile Prompts',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Answer at least 2 prompts to show matches your unique personality. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildPromptSelector(context, 'PROMPT QUESTION 1', _promptQ1, (
                  val,
                ) {
                  setState(() => _promptQ1 = val);
                  viewModel.updatePersonalityPrompt(
                    val,
                    _promptA1Controller.text,
                  );
                }),
                const SizedBox(height: 8),
                _buildPromptInput(context, _promptA1Controller, (val) {
                  viewModel.updatePersonalityPrompt(_promptQ1, val);
                }),

                const SizedBox(height: 32),

                _buildPromptSelector(context, 'PROMPT QUESTION 2', _promptQ2, (
                  val,
                ) {
                  setState(() => _promptQ2 = val);
                  viewModel.updatePersonalityPrompt(
                    val,
                    _promptA2Controller.text,
                  );
                }),
                const SizedBox(height: 8),
                _buildPromptInput(context, _promptA2Controller, (val) {
                  viewModel.updatePersonalityPrompt(_promptQ2, val);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptSelector(
    BuildContext context,
    String header,
    String currentQuestion,
    ValueChanged<String> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: context.typography.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: context.colors.surface,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _promptQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _promptQuestions[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(
                            question,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            onSelected(question);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: context.radius.borderLg,
              border: Border.all(color: context.colors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentQuestion,
                    style: context.typography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  color: context.colors.accent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput(
    BuildContext context,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.borderLg,
        border: Border.all(color: context.colors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 120,
            cursorColor: context.colors.primary,
            style: context.typography.body.copyWith(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(color: Colors.white30),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (val) {
              onChanged(val);
              setState(() {});
            },
          ),
          Text(
            '${controller.text.length} / 120',
            style: context.typography.caption.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // STEP 14: Opening Move
  Widget _buildOpeningMoveStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
    AllMasterData? masterData,
  ) {
    final apiOpening = masterData?.data?.openingMoves ?? [];
    final openingQuestions = apiOpening.isNotEmpty
        ? apiOpening
              .map((m) => m.displayText)
              .where((s) => s.isNotEmpty)
              .toList()
        : [
            'Would you rather travel to the future or the past?',
            'What\'s your go-to weekend morning routine?',
            'What\'s the most adventurous thing you\'ve ever done?',
            'What\'s a controversial opinion you hold?',
            'Describe your perfect first date in three words.',
          ];

    if (openingQuestions.isNotEmpty &&
        !_useCustomOpeningQ &&
        !openingQuestions.contains(_openingQ)) {
      _openingQ = openingQuestions.first;
    }

    final String currentQ = _useCustomOpeningQ
        ? _customOpeningQController.text
        : _openingQ;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Choose Opening Move',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matches must answer this question to message you first. (Optional)',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Curated Question'),
                      selected: !_useCustomOpeningQ,
                      onSelected: (selected) {
                        setState(() => _useCustomOpeningQ = false);
                        viewModel.updateOpeningMove(
                          _openingQ,
                          _openingAController.text,
                        );
                      },
                      labelStyle: TextStyle(
                        color: !_useCustomOpeningQ
                            ? Colors.black
                            : Colors.white,
                      ),
                      selectedColor: context.colors.primary,
                      backgroundColor: context.colors.surface,
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Custom Question'),
                      selected: _useCustomOpeningQ,
                      onSelected: (selected) {
                        setState(() => _useCustomOpeningQ = true);
                        viewModel.updateOpeningMove(
                          _customOpeningQController.text,
                          _openingAController.text,
                        );
                      },
                      labelStyle: TextStyle(
                        color: _useCustomOpeningQ ? Colors.black : Colors.white,
                      ),
                      selectedColor: context.colors.primary,
                      backgroundColor: context.colors.surface,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (!_useCustomOpeningQ) ...[
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: context.colors.surface,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: openingQuestions.length,
                              itemBuilder: (context, index) {
                                final question = openingQuestions[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      question,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {
                                      setState(() => _openingQ = question);
                                      viewModel.updateOpeningMove(
                                        question,
                                        _openingAController.text,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: context.radius.borderLg,
                        border: Border.all(color: context.colors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _openingQ,
                              style: context.typography.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: context.colors.accent,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: context.radius.borderLg,
                      border: Border.all(color: context.colors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _customOpeningQController,
                      style: context.typography.body.copyWith(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter your custom opening question...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        viewModel.updateOpeningMove(
                          val,
                          _openingAController.text,
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                Text(
                  'YOUR ANSWER PREVIEW',
                  style: context.typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: context.radius.borderLg,
                    border: Border.all(color: context.colors.divider),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _openingAController,
                    maxLines: 3,
                    style: context.typography.body.copyWith(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Type your response...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      viewModel.updateOpeningMove(currentQ, val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 15: Preview & Summary
  Widget _buildPreviewStep(
    BuildContext context,
    OnboardingState state,
    OnboardingViewModel viewModel,
  ) {
    final double completeness = viewModel.profileCompleteness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'Your Profile is Ready',
            style: context.typography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here is a preview of how you will appear to matches. Complete details will make discovery easier.',
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFILE COMPLETENESS',
                style: context.typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${(completeness * 100).toInt()}%',
                style: context.typography.caption.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completeness,
              color: context.colors.primary,
              backgroundColor: context.colors.divider,
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 20),

          GlassCard(
            blurAmount: AppBlur.medium,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.divider),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (state.photos.isNotEmpty && File(state.photos.first).existsSync())
                          ? Image.file(
                              File(state.photos.first),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: context.colors.surface,
                              child: const Icon(CupertinoIcons.person_fill, color: Colors.white30),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${state.firstName}, ${viewModel.calculatedAge}',
                                  style: context.typography.title.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (state.zodiac != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  state.zodiac!
                                      .substring(state.zodiac!.length - 2)
                                      .trim(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.jobTitle?.isNotEmpty == true
                                ? (state.company?.isNotEmpty == true
                                      ? '${state.jobTitle} at ${state.company}'
                                      : state.jobTitle!)
                                : (state.company?.isNotEmpty == true
                                      ? 'Works at ${state.company}'
                                      : 'Member'),
                            style: context.typography.caption.copyWith(
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (state.intention != null)
                      _buildPreviewPill(context, '🎯 ${state.intention}'),
                    if (state.height != null)
                      _buildPreviewPill(context, '📏 ${state.height} cm'),
                    if (state.education != null)
                      _buildPreviewPill(context, '🎓 ${state.education}'),
                    if (state.hometown?.isNotEmpty == true)
                      _buildPreviewPill(context, '📍 ${state.hometown}'),
                    if (state.languages.isNotEmpty)
                      _buildPreviewPill(
                        context,
                        '🗣️ ${state.languages.join(', ')}',
                      ),
                    if (state.religion != null)
                      _buildPreviewPill(context, '🙏 ${state.religion}'),
                    if (state.smoking != null)
                      _buildPreviewPill(context, '🚬 ${state.smoking}'),
                    if (state.drinking != null)
                      _buildPreviewPill(context, '🍷 ${state.drinking}'),
                    if (state.sleepSchedule != null)
                      _buildPreviewPill(context, '😴 ${state.sleepSchedule}'),
                    if (state.diet != null)
                      _buildPreviewPill(context, '🥗 ${state.diet}'),
                    if (state.exercise != null)
                      _buildPreviewPill(context, '🏋️ ${state.exercise}'),
                    if (state.interests.isNotEmpty)
                      ...state.interests.map(
                        (interest) => _buildPreviewPill(context, '✨ $interest'),
                      ),
                  ],
                ),

                if (state.personalityPrompts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.personalityPrompts.keys.first,
                          style: context.typography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${state.personalityPrompts.values.first}"',
                          style: context.typography.body.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),
          PrimaryButton(
            text: 'Start discovering',
            isLoading: state.isLoading,
            onTap: () async {
              final result = await viewModel.completeOnboarding();
              if (!context.mounted) return;

              if (result.isSuccess) {
                // Verify auth_token is securely saved in Hive before completing route initialization & navigating
                final String? storedToken = HiveService.instance.settingsBox.get('auth_token');
                final bool isCompleted = HiveService.instance.settingsBox.get('is_onboarding_completed', defaultValue: false);

                if (storedToken != null && storedToken.isNotEmpty && isCompleted) {
                  HapticFeedback.mediumImpact();
                  routerConfigNotifier.completeInitialization();
                  context.go('/swipe');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save session token locally. Please try again.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } else {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.errorMessage ?? 'Registration failed. Please check your connection and try again.',
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPreviewPill(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        text,
        style: context.typography.caption.copyWith(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}

// Choice Grid Helper Widget
class ChoiceGrid extends StatelessWidget {
  final List<Map<String, String>> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const ChoiceGrid({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final label = opt['label']!;
        final emoji = opt['emoji']!;
        final bool isSel = selectedValue == label;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSelected(isSel ? null : label);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSel ? context.colors.primary : context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? context.colors.primary : context.colors.divider,
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: context.typography.label.copyWith(
                      color: isSel ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageSearchWidget extends StatefulWidget {
  final List<String> selectedLanguages;
  final ValueChanged<String> onLanguageSelected;

  const _LanguageSearchWidget({
    required this.selectedLanguages,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageSearchWidget> createState() => _LanguageSearchWidgetState();
}

class _LanguageSearchWidgetState extends State<_LanguageSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = List.from(worldLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredLanguages = List.from(worldLanguages);
      } else {
        _filteredLanguages = worldLanguages
            .where((lang) => lang.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Languages',
            style: context.typography.title.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.divider),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    color: Colors.white30,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search languages...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: const Icon(
                        CupertinoIcons.clear_circled_solid,
                        color: Colors.white30,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredLanguages.length,
              separatorBuilder: (context, index) =>
                  Divider(color: context.colors.divider, height: 1),
              itemBuilder: (context, index) {
                final lang = _filteredLanguages[index];
                final isSelected = widget.selectedLanguages.contains(lang);
                final isMaxReached = widget.selectedLanguages.length >= 5;
                final isEnabled = isSelected || !isMaxReached;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        color: isEnabled ? Colors.white : Colors.white30,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: context.colors.primary,
                            size: 22,
                          )
                        : null,
                    onTap: isEnabled
                        ? () {
                            HapticFeedback.lightImpact();
                            widget.onLanguageSelected(lang);
                            Navigator.pop(context);
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You can select a maximum of 5 languages.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
