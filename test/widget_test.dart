import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stitch_color_app/main.dart';
import 'package:stitch_color_app/services/app_settings_service.dart';

void main() {
  testWidgets('App navigation and tabs smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettingsService().init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify BottomNavigationBar exists with tabs
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Tô màu'), findsOneWidget);
    expect(find.text('Phép màu AI'), findsOneWidget);
    expect(find.text('Tranh bé'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);

    // Tap 'Cài đặt' tab
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();

    // Tap 'Trang chủ' tab
    await tester.tap(find.text('Trang chủ').last);
    await tester.pumpAndSettle();

    // Verify language change updates bottom navigation items
    await AppSettingsService().setSelectedLanguage('ko');
    await tester.pumpAndSettle();
    expect(find.text('홈'), findsWidgets);
    expect(find.text('색칠하기'), findsOneWidget);
    expect(find.text('AI 마법'), findsOneWidget);
    expect(find.text('작품 보관함'), findsWidgets);
    expect(find.text('설정'), findsOneWidget);
  });
}


