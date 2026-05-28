import 'dart:async';

import 'package:delivery_app/shared/assets/app_assets.dart';
import 'package:flutter/painting.dart';

/// Decodes both theme wordmarks once at startup for smoother first paint.
Future<void> precacheAppLogo() async {
  await Future.wait([
    _precacheAssetImage(AppAssets.logoLightTheme),
    _precacheAssetImage(AppAssets.logoDarkTheme),
  ]);
}

Future<void> _precacheAssetImage(String assetPath) async {
  final stream = AssetImage(assetPath).resolve(const ImageConfiguration());
  final completer = Completer<void>();
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      stream.removeListener(listener);
      completer.complete();
    },
    onError: (Object error, StackTrace? stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
