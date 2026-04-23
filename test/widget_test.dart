import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:issk/main.dart';

void main() {
  testWidgets('تطبيق يبني شاشة البداية', (WidgetTester tester) async {
    await tester.pumpWidget(const IsskApp());
    expect(find.textContaining('درع'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
