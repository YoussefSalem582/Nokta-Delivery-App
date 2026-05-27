import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/features/auth/presentation/pages/login_page.dart';
import 'package:delivery_app/features/home/presentation/pages/home_map_page.dart';
import 'package:delivery_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:delivery_app/features/profile/presentation/pages/profile_page.dart';
import 'package:delivery_app/features/splash/presentation/pages/splash_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/tracking_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/trip_detail_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/trip_list_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(
          page: MainShellRoute.page,
          children: [
            AutoRoute(page: HomeMapRoute.page),
            AutoRoute(page: TripListRoute.page),
            AutoRoute(page: NotificationsRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
        AutoRoute(page: TripDetailRoute.page, path: '/trips/:tripId'),
        AutoRoute(page: TrackingRoute.page, path: '/trips/:tripId/track'),
      ];
}

@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeMapRoute(),
        TripListRoute(),
        NotificationsRoute(),
        ProfileRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: 'home_tab'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.history),
                selectedIcon: const Icon(Icons.history),
                label: 'trips_tab'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.notifications_outlined),
                selectedIcon: const Icon(Icons.notifications),
                label: 'notifications_tab'.tr(),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: 'profile_tab'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}
