import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PlaceSuggestionsList extends StatelessWidget {
  const PlaceSuggestionsList({
    super.key,
    required this.state,
    required this.hasQuery,
    required this.onSelect,
  });

  final LocationSearchState state;
  final bool hasQuery;
  final ValueChanged<PlaceSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (state.status == LocationSearchStatus.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    if (state.status == LocationSearchStatus.offline) {
      return _MessageText(
        icon: Icons.wifi_off,
        text: 'location_search_offline'.tr(),
        color: scheme.error,
      );
    }

    if (state.status == LocationSearchStatus.error) {
      return _MessageText(
        icon: Icons.error_outline,
        text: 'location_search_error'.tr(),
        color: scheme.error,
      );
    }

    if (!hasQuery) {
      return _MessageText(
        icon: Icons.search,
        text: 'location_search_type_hint'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    if (state.status == LocationSearchStatus.empty || state.suggestions.isEmpty) {
      return _MessageText(
        icon: Icons.location_off_outlined,
        text: 'destination_no_results'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: scheme.shadow.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: state.suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 56,
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final place = state.suggestions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    leading: CircleAvatar(
                      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      place.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: place.subtitle.isNotEmpty
                        ? Text(
                            place.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          )
                        : null,
                    onTap: () => onSelect(place),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: scheme.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                'location_osm_attribution'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
