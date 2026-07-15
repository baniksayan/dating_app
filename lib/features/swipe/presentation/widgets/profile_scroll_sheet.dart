import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/glass_card.dart';
import 'floating_expand_button.dart';
import 'profile_details_section.dart';
import 'animated_profile_section.dart';

class ProfileScrollSheet extends StatefulWidget {
  final UserModel user;
  final bool isExpanded;
  final ScrollController scrollController;
  final VoidCallback onExpandTap;

  const ProfileScrollSheet({
    super.key,
    required this.user,
    required this.isExpanded,
    required this.scrollController,
    required this.onExpandTap,
  });

  @override
  State<ProfileScrollSheet> createState() => _ProfileScrollSheetState();
}

class _ProfileScrollSheetState extends State<ProfileScrollSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: widget.isExpanded
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Name, Age, Badges, Occupation, Location)
          _buildProfileHeader(context),
          const SizedBox(height: 12),

          // 2. Bio Preview / Expanded Details
          if (!widget.isExpanded) ...[
            if (widget.user.bio.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.user.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingExpandButton(
                    isExpanded: false,
                    onTap: widget.onExpandTap,
                  ),
                ],
              ),
          ] else ...[
            AnimatedProfileSection(
              index: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: context.typography.label.copyWith(
                      color: context.colors.textSecondary,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.bio,
                    style: context.typography.body.copyWith(
                      color: const Color(0xD9FFFFFF),
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedProfileSection(
              index: 1,
              child: ProfileDetailsSection(user: widget.user),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final int hash = widget.user.id.hashCode;
    final goals = [
      'Long-term relationship',
      'Life partner',
      'Open to short-term',
      'Figuring it out',
    ];
    final String relationshipGoal = goals[hash % goals.length];

    IconData goalIcon;
    Color goalColor;
    switch (relationshipGoal) {
      case 'Long-term relationship':
        goalIcon = Icons.diamond_rounded;
        goalColor = const Color(0xFFEF9A9A);
        break;
      case 'Life partner':
        goalIcon = Icons.diversity_3_rounded;
        goalColor = const Color(0xFFF48FB1);
        break;
      case 'Open to short-term':
        goalIcon = Icons.local_cafe_rounded;
        goalColor = const Color(0xFFFFCC80);
        break;
      case 'Figuring it out':
        goalIcon = Icons.explore_rounded;
        goalColor = const Color(0xFF80CBC4);
        break;
      default:
        goalIcon = Icons.favorite_rounded;
        goalColor = const Color(0xFF79A3C3);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name, Age, Badge & Relationship Goal capsule
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.user.name}, ${widget.user.age}',
                      style: context.typography.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                        fontSize: 25,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.user.isVerified) ...[
                    const SizedBox(width: 6),
                    const InteractiveBadge(
                      tooltipText: 'Verified Profile',
                      tooltipIcon: Icons.verified_user_rounded,
                      child: VerifiedBadge(size: 20),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Glassmorphic capsule for Relationship Goal on the right side
            GlassCard(
              blurAmount: AppBlur.subtle,
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12), width: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(goalIcon, color: goalColor, size: 11),
                  const SizedBox(width: 4),
                  Text(
                    relationshipGoal,
                    style: context.typography.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Occupation / Job Title
        if (widget.user.jobTitle.isNotEmpty) ...[
          Text(
            '${widget.user.jobTitle}${widget.user.company.isNotEmpty ? ' at ${widget.user.company}' : ''}',
            style: context.typography.label.copyWith(
              color: context.colors.accent,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
        ],

        // Location & Distance Info
        Row(
          children: [
            Icon(
              AppIcons.location,
              size: 14,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.user.locationName} • ${widget.user.distance.toStringAsFixed(1)} miles away',
              style: context.typography.caption.copyWith(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
