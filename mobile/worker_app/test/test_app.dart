import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:worker_app/app/app_theme.dart';
import 'package:worker_app/app/router/app_router.dart';
import 'package:worker_app/core/utils/clock.dart';
import 'package:worker_app/features/auth/data/session.dart';
import 'package:worker_app/features/onboarding/data/kyc_store.dart';

/// A fixed Thursday, so dates on screen never change between runs.
final testToday = DateTime(2026, 11, 26);

bool _fontLoaded = false;

/// Loads Figtree so text is measured like it is on a phone.
Future<void> _loadFont() async {
  if (_fontLoaded) return;
  final bytes = File('assets/fonts/Figtree.ttf').readAsBytesSync();
  final loader = FontLoader('Figtree')
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
  _fontLoaded = true;
}

ProviderContainer testContainer() =>
    ProviderContainer(overrides: [todayProvider.overrideWithValue(testToday)]);

/// Signs the demo expert in without going through the sign-in screens.
ProviderContainer signedInContainer() {
  final c = testContainer();
  c
      .read(sessionProvider.notifier)
      .signIn(phone: '9876543210', name: 'Lakshmi Pawar', area: 'Thane West');
  c.read(kycProvider.notifier).seedVerified();
  return c;
}

/// Opens the real route table at [location] on a phone-sized screen.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  String location, {
  ProviderContainer? container,
  Size physicalSize = const Size(1170, 2532),
}) async {
  await tester.runAsync(() async {
    await _loadFont();
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });
  await tester.pump();
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = container ?? testContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: buildRouter(initialLocation: location),
      ),
    ),
  );
  await pumpFor(tester, 800);
  return c;
}

/// Advances time in small steps (looping animations never settle).
Future<void> pumpFor(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
