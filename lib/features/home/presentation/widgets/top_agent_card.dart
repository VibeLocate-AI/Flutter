import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/top_agent_model.dart';

class TopAgentCard extends StatelessWidget {
  const TopAgentCard({
    super.key,
    required this.agent,
  });

  final TopAgentModel agent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.white;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.grayBorderLight;

    final primaryColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.navyDark;

    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.grayTextSub;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          _AgentAvatar(
            avatarUrl: agent.avatarUrl,
            name: agent.name,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        agent.name.isEmpty
                            ? 'Agent'
                            : agent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (agent.isManager) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppColors.blueAccent,
                      ),
                    ],
                  ],
                ),

                if (agent.agencyName.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    agent.agencyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ],

                if (agent.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    agent.phone,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.blueAccent.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentAvatar extends StatelessWidget {
  const _AgentAvatar({
    required this.avatarUrl,
    required this.name,
  });

  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? 'A'
        : name.trim().substring(0, 1).toUpperCase();

    final hasAvatar =
        avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _FallbackAvatar(
            initial: initial,
          );
        },
      )
          : _FallbackAvatar(
        initial: initial,
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.initial,
  });

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.headingMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}