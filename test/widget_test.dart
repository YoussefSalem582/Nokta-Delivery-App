import 'package:delivery_app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Responsive helpers detect mobile layout', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(Responsive.isMobile(context), isTrue);
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
