import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'
    show Colors, Icons; // Standard for color translucency helpers
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/zoomable_image_viewer.dart';

class ProfileDetailsSection extends StatelessWidget {
  final UserModel user;

  const ProfileDetailsSection({super.key, required this.user});

  /// Dynamically generates premium metadata fields based on user attributes
  Map<String, String> _getBasics() {
    // Deterministic mock data based on user id hash
    final int hash = user.id.hashCode;
    final heights = ['5\'5"', '5\'7"', '5\'9"', '5\'11"', '6\'1"'];
    final languages = [
      'English & French',
      'English & Spanish',
      'English & German',
      'English & Italian',
    ];
    final education = [
      'Master\'s Degree',
      'Bachelor\'s Degree',
      'PhD Candidate',
      'Self-Taught',
    ];
    final zodiacs = [
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
    ];

    return {
      'Height': heights[hash % heights.length],
      'Languages': languages[hash % languages.length],
      'Education': education[hash % education.length],
      'Zodiac': zodiacs[hash % zodiacs.length],
    };
  }

  List<String> _getLifestyle() {
    final int hash = user.id.hashCode;

    // Profession
    final String professionTag;
    if (user.jobTitle.isNotEmpty) {
      professionTag = user.company.isNotEmpty
          ? '💼 ${user.jobTitle} at ${user.company}'
          : '💼 ${user.jobTitle}';
    } else {
      final defaultJobs = [
        '💻 Software Engineer',
        '🎨 Product Designer',
        '🩺 Resident Physician',
        '🚀 Founder',
      ];
      professionTag = defaultJobs[hash % defaultJobs.length];
    }

    final lookingFor = [
      '🔍 Looking for: Marriage',
      '🔍 Looking for: A relationship',
      '🔍 Looking for: Open relationship',
      '🔍 Looking for: Friends first',
    ];
    final drinking = ['🍷 Social drinker', '🙅 No alcohol', '🍷 Socially'];
    final smoking = ['🚭 Non-smoker', '🚭 Non-smoker', '💨 Occasional smoker'];
    final workout = [
      '🏃 Active workout',
      '🧘 Yoga & Pilates',
      '🏃 Running & Gym',
      '🧗 Climbing',
    ];
    final pets = [
      '🐕 Dog lover',
      '🐈 Cat lover',
      '🐕 Dog & Cat lover',
      '🦜 Bird watcher',
    ];
    final travel = [
      '✈️ Travel enthusiast',
      '🌍 Globetrotter',
      '🏖️ Beach lover',
      '🌲 Camper',
    ];

    return [
      professionTag,
      lookingFor[hash % lookingFor.length],
      drinking[hash % drinking.length],
      smoking[hash % smoking.length],
      workout[hash % workout.length],
      pets[hash % pets.length],
      travel[hash % travel.length],
    ];
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'Relationship Goals':
        return Icons.favorite_rounded;
      case 'Height':
        return Icons.height_rounded;
      case 'Languages':
        return Icons.translate_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Zodiac':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final basics = _getBasics();
    final lifestyle = _getLifestyle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        context.spacing.spaceLg,

        // 1. Basics Grid Layout
        Text(
          'The Basics',
          style: context.typography.label.copyWith(
            color: context.colors.accent,
            letterSpacing: 1.0,
          ),
        ),
        context.spacing.spaceSm,
        _buildBasicsGrid(context, basics),

        context.spacing.spaceMd, // Reduced gap between Basics and Lifestyle
        // 2. Lifestyle Tags List
        Text(
          'Lifestyle',
          style: context.typography.label.copyWith(
            color: context.colors.accent,
            letterSpacing: 1.0,
          ),
        ),
        context.spacing.spaceSm,
        _buildLifestyleChips(context, lifestyle),

        context.spacing.spaceLg,

        // 3. Complete Interests list
        if (user.interests.isNotEmpty) ...[
          Text(
            'Interests',
            style: context.typography.label.copyWith(
              color: context.colors.accent,
              letterSpacing: 1.0,
            ),
          ),
          context.spacing.spaceSm,
          _buildInterestsChips(context, user.interests),
          context.spacing.spaceLg,
        ],

        // 4. Additional Photos Horizontal Gallery
        Text(
          'Photos by ${user.displayName}',
          style: context.typography.label.copyWith(
            color: context.colors.accent,
            letterSpacing: 1.0,
          ),
        ),
        context.spacing.spaceSm,
        _buildAdditionalPhotos(context),
      ],
    );
  }

  Widget _buildBasicsGrid(BuildContext context, Map<String, String> basics) {
    return GridView.builder(
      padding: EdgeInsets.zero, // Reset default vertical grid paddings
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio:
            3.6, // Shorter, tighter cell height (reduced empty spaces)
      ),
      itemCount: basics.length,
      itemBuilder: (context, index) {
        final key = basics.keys.elementAt(index);
        final val = basics.values.elementAt(index);

        IconData icon = _getIconForKey(key);
        Color iconColor = const Color(
          0xFF79A3C3,
        ); // Soft Classic Blue brand color

        if (key == 'Relationship Goals') {
          switch (val) {
            case 'Long-term relationship':
              icon = Icons.diamond_rounded;
              iconColor = const Color(0xFFEF9A9A);
              break;
            case 'Life partner':
              icon = Icons.diversity_3_rounded;
              iconColor = const Color(0xFFF48FB1);
              break;
            case 'Open to short-term':
              icon = Icons.local_cafe_rounded;
              iconColor = const Color(0xFFFFCC80);
              break;
            case 'Figuring it out':
              icon = Icons.explore_rounded;
              iconColor = const Color(0xFF80CBC4);
              break;
          }
        }

        return GlassCard(
          blurAmount: AppBlur.subtle,
          borderRadius: context.radius.borderMd,
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key,
                      style: context.typography.caption.copyWith(
                        fontSize: 9.5,
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      val,
                      style: context.typography.label.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 11.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLifestyleChips(BuildContext context, List<String> lifestyle) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lifestyle.map((tag) {
        return GlassCard(
          blurAmount: AppBlur.subtle,
          borderRadius: AppRadius.borderPill,
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            tag,
            style: context.typography.caption.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterestsChips(BuildContext context, List<String> interests) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) {
        return GlassCard(
          blurAmount: AppBlur.subtle,
          borderRadius: context.radius.borderSm,
          backgroundColor: context.colors.primary.withValues(alpha: 0.12),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.20),
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            interest,
            style: context.typography.caption.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalPhotos(BuildContext context) {
    final int hash = user.id.hashCode;

    // Fallback Unsplash portraits matching brand aesthetic if user only has 1 photo
    final defaultPhotos = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop&q=80',
    ];

    // Get the photos: skip the active/first photo if there are multiple.
    final List<String> list;
    if (user.photos.length > 1) {
      list = user.photos;
    } else {
      list = [
        user.photos.isNotEmpty
            ? user.photos.first
            : defaultPhotos[hash % defaultPhotos.length],
        defaultPhotos[(hash + 1) % defaultPhotos.length],
        defaultPhotos[(hash + 2) % defaultPhotos.length],
      ];
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final imageUrl = list[index];
          final heroTag = 'gallery_photo_${user.id}_$index';

          return GestureDetector(
            onTap: () {
              openZoomableImage(
                context,
                NetworkImage(imageUrl),
                heroTag: heroTag,
              );
            },
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: context.radius.borderMd,
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
