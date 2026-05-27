import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Parses [AppBrandIcon.assetPath] once at startup for smoother first paint.
Future<void> precacheAppLogo() async {
  final loader = SvgAssetLoader(AppBrandIcon.assetPath);
  await svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}
