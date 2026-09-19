import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onAvatarTap,
    required this.enabled,
  });

  final ProfileModel profile;
  final VoidCallback onAvatarTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final width =
        MediaQuery.sizeOf(context).width;

    final avatarRadius =
    width < 360 ? 48.0 : 56.0;

    final initial =
    profile.fullName.trim().isEmpty
        ? 'U'
        : profile.fullName
        .trim()
        .substring(0, 1)
        .toUpperCase();

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width:
                avatarRadius * 2,
                height:
                avatarRadius * 2,
                decoration:
                const BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                  AppColors.navyPrimary,
                ),
                clipBehavior:
                Clip.antiAlias,
                child:
                profile.avatarUrl !=
                    null &&
                    profile.avatarUrl!
                        .trim()
                        .isNotEmpty
                    ? Image.network(
                  profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                      _,
                      _,
                      _,
                      ) {
                    return _FallbackAvatar(
                      initial:
                      initial,
                    );
                  },
                )
                    : _FallbackAvatar(
                  initial:
                  initial,
                ),
              ),
              PositionedDirectional(
                end: -2,
                bottom: -2,
                child: Material(
                  color:
                  theme.colorScheme.primary,
                  shape:
                  const CircleBorder(),
                  child: InkWell(
                    onTap:
                    enabled
                        ? onAvatarTap
                        : null,
                    customBorder:
                    const CircleBorder(),
                    child:
                    const Padding(
                      padding:
                      EdgeInsets.all(
                        10,
                      ),
                      child: Icon(
                        Icons
                            .camera_alt_rounded,
                        size: 18,
                        color:
                        AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName.trim().isEmpty
                ? 'User'
                : profile.fullName,
            textAlign:
            TextAlign.center,
            style:
            AppTextStyles.headingMedium
                .copyWith(
              color: theme
                  .colorScheme
                  .onSurface,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          if (profile.email
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              profile.email,
              textAlign:
              TextAlign.center,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              AppTextStyles.bodyMedium
                  .copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
          if (profile.role
              .trim()
              .isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primary
                    .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(
                  999,
                ),
              ),
              child: Text(
                profile.role,
                style:
                AppTextStyles.labelSmall
                    .copyWith(
                  color: theme
                      .colorScheme
                      .primary,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FallbackAvatar
    extends StatelessWidget {
  const _FallbackAvatar({
    required this.initial,
  });

  final String initial;

  @override
  Widget build(
      BuildContext context,
      ) {
    return ColoredBox(
      color:
      AppColors.navyPrimary,
      child: Center(
        child: Text(
          initial,
          style:
          AppTextStyles.displayMedium
              .copyWith(
            color:
            AppColors.white,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }
}