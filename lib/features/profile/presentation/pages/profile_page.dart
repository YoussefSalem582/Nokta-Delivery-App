import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/theme/theme_cubit.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/profile/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<OrderBloc>()..add(const OrderLoadRequested())),
      ],
      child: FutureBuilder(
        future: sl<AuthRepository>().getProfile(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final scheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(
              backgroundColor: scheme.surface,
              title: Text('profile_title'.tr()),
              leading: IconButton(
                icon: Icon(Icons.menu, color: scheme.onSurfaceVariant),
                onPressed: () {},
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: NoktaSpacing.sm),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.surfaceContainerHigh,
                    child: Text(
                      (user?.name ?? 'D')[0].toUpperCase(),
                      style: TextStyle(color: scheme.primary, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(NoktaSpacing.md),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: NoktaSpacing.lg),
                _WalletCard(balance: user?.walletBalance ?? 0),
                const SizedBox(height: NoktaSpacing.lg),
                _TabBar(
                  selectedIndex: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
                const SizedBox(height: NoktaSpacing.md),
                if (_tabIndex == 0)
                  _OrdersTab()
                else
                  _SettingsTab(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: scheme.surfaceContainerHigh,
              child: Text(
                (user?.name ?? 'D')[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 16, color: scheme.onPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: NoktaSpacing.sm),
        Text(user?.name ?? 'demo_user'.tr(), style: Theme.of(context).textTheme.titleLarge),
        Text(user?.email ?? 'demo@delivery.app', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surface, scheme.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('balance'.tr(), style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: NoktaSpacing.xs),
                Text(
                  '${balance.toStringAsFixed(2)} EGP',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: Text('top_up'.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'orders'.tr(),
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        _TabButton(
          label: 'settings'.tr(),
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ].map((tab) => Expanded(child: tab)).toList(),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const SizedBox(
            height: 200,
            child: LoadingView(message: 'loading'),
          );
        }
        if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(NoktaSpacing.lg),
              child: Center(child: Text('no_orders'.tr())),
            );
          }
          return Column(
            children: state.orders
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: NoktaSpacing.sm),
                    child: _OrderTile(order: order),
                  ),
                )
                .toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'dark_mode'.tr(),
          trailing: Switch(
            value: context.watch<ThemeCubit>().state == ThemeMode.dark,
            onChanged: (v) => context.read<ThemeCubit>().toggleDark(v),
          ),
        ),
        _SettingsTile(
          icon: Icons.language,
          title: 'language'.tr(),
          trailing: DropdownButton<String>(
            value: context.watch<LocaleCubit>().state,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
            ],
            onChanged: (code) {
              if (code == null) return;
              context.read<LocaleCubit>().setLocale(code);
              context.setLocale(Locale(code));
            },
          ),
        ),
        _SettingsTile(
          icon: Icons.bug_report_outlined,
          title: 'open_talker'.tr(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TalkerScreen(talker: sl()),
              ),
            );
          },
        ),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaPrimaryButton(
          label: 'logout'.tr(),
          icon: Icons.logout,
          onPressed: () {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
            context.router.replaceAll([const LoginRoute()]);
          },
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: NoktaSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderEntity order;

  String _statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => 'order_delivered'.tr(),
      OrderStatus.pending => 'order_pending'.tr(),
      OrderStatus.inTransit => 'order_inTransit'.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.title, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                    )),
                Text(_statusLabel(order.status), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            '${order.amount.toStringAsFixed(2)} EGP',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
