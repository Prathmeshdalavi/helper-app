import 'dart:io';

import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/app/router/app_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

bool _fontLoaded = false;

/// Loads Figtree so text is measured like it is on a phone.
Future<void> loadAppFont() async {
  if (_fontLoaded) return;
  final bytes = File('assets/fonts/Figtree.ttf').readAsBytesSync();
  final loader = FontLoader('Figtree')
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
  _fontLoaded = true;
}

/// Opens the real route table at [location] with a phone-sized screen.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  String location, {
  ProviderContainer? container,
}) async {
  await tester.runAsync(() async {
    await loadAppFont();
    // Let the font-change message reach the engine before the first frame.
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });
  await tester.pump();
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = container ?? ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: buildRouter(initialLocation: location),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return c;
}

/// Advances time in small steps (looping animations never settle).
Future<void> pumpFor(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
