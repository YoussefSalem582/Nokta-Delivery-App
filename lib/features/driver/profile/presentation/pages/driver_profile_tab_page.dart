import 'package:delivery_app/features/auth/shared/presentation/utils/app_logout.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/feedback/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_app_bar.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_scaffold.dart';
import 'package:delivery_app/shared/widgets/profile/app_mode_switch_tile.dart';
import 'package:delivery_app/shared/widgets/profile/logout_button.dart';
import 'package:delivery_app/shared/widgets/profile/profile_user_card.dart';
import 'package:delivery_app/shared/widgets/profile/stat_summary_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverProfileTabPage extends StatelessWidget {
  const DriverProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return ShellTabScaffold(
            appBar: ShellTabAppBar(title: Text('profile_title'.tr())),
            body: EmptyStateView(
              icon: Icons.lock_outline,
              title: 'auth_required'.tr(),
            ),
          );
        }

        final user = authState.user;
        final trips = sl<TripRepository>().getCachedTrips();
        final stats = _DriverStats.fromTrips(trips, user.id);

        return ShellTabScaffold(
          appBar: ShellTabAppBar(title: Text('driver_profile_title'.tr())),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ProfileUserCard(user: user),
              const SizedBox(height: AppSpacing.lg),
              StatSummaryCard(
                icon: Icons.payments_outlined,
                label: 'driver_total_earnings'.tr(),
                amountText: _money(stats.totalEarnings),
                trailing:
                    stats.rating != null ? _RatingPill(rating: stats.rating!) : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'driver_performance'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.check_circle_outline,
                      label: 'driver_trips_completed'.tr(),
                      value: '${stats.tripCount}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.trending_up,
                      label: 'driver_avg_fare'.tr(),
                      value: _money(stats.averageFare),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.today_outlined,
                      label: 'driver_earnings_today'.tr(),
                      value: _money(stats.earningsToday),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.date_range_outlined,
                      label: 'driver_earnings_week'.tr(),
                      value: _money(stats.earningsThisWeek),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (user.driverProfile != null) ...[
                _InfoTile(
                  icon: Icons.directions_car_outlined,
                  label: 'driver_vehicle'.tr(),
                  value: user.driverProfile!.vehicleMakeModel,
                ),
                _InfoTile(
                  icon: Icons.confirmation_number_outlined,
                  label: 'driver_onboarding_plate'.tr(),
                  value: user.driverProfile!.licensePlate,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              const AppModeSwitchTile.driver(),
              const SizedBox(height: AppSpacing.lg),
              LogoutButton(onPressed: () => performAppLogout(context)),
            ],
          ),
        );
      },
    );
  }
}

String _money(double value) => '${value.toStringAsFixed(2)} EGP';

/// Presentation-side rollup of the driver's earnings/performance, derived from
/// the cached trips. Pure aggregates come from [TripQuery]; the today/this-week
/// boundaries are computed here from the current time.
class _DriverStats {
  const _DriverStats({
    required this.totalEarnings,
    required this.tripCount,
    required this.averageFare,
    required this.earningsToday,
    required this.earningsThisWeek,
    this.rating,
  });

  final double totalEarnings;
  final int tripCount;
  final double averageFare;
  final double earningsToday;
  final double earningsThisWeek;
  final double? rating;

  factory _DriverStats.fromTrips(List<TripEntity> trips, String driverId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));

    double? rating;
    for (final trip in trips) {
      if (trip.driverId == driverId && trip.driverRating != null) {
        rating = trip.driverRating;
        break;
      }
    }

    return _DriverStats(
      totalEarnings: TripQuery.completedDriverEarnings(trips, driverId),
      tripCount: TripQuery.completedDriverTripCount(trips, driverId),
      averageFare: TripQuery.driverAverageFare(trips, driverId),
      earningsToday:
          TripQuery.driverEarningsSince(trips, driverId, startOfToday),
      earningsThisWeek:
          TripQuery.driverEarningsSince(trips, driverId, startOfWeek),
      rating: rating,
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: scheme.tertiary, size: 20),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
