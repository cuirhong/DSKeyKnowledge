import 'package:flutter/material.dart';
import 'package:flutter_project/test/contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Test Contacts Widget", (WidgetTester tester) async {
    //注入Widget
    await tester.pumpWidget(MaterialApp(home: HYContacts(["abc", "cdb", "dis"])));
    // 在HYContacts中查找Widget/Text
    final abcText = find.text("abc");
    final cdbText = find.text("cdb");
    final icons = find.byIcon(Icons.people);

    expect(abcText, findsOneWidget);
    expect(cdbText, findsOneWidget);
    expect(icons, findsNWidgets(3));
  });

}
