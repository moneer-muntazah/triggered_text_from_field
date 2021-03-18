import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

const labelText = 'Label Text';
const message1 = 'message1';
const input1 = '12345';
GlobalKey<FormState> formKey;

MaterialApp createApp(TriggeredTextFormField field) => MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: field,
        ),
      ),
    );

void main() {
  setUp(() {
    formKey = GlobalKey<FormState>();
  });

  group('When initialValue != null, and predicate(initialValue) == true', () {
    const initialValue = '123456';
    testWidgets('initially (on screen first load) trigger is not called',
        (tester) async {
      final app1 = createApp(
        TriggeredTextFormField(
            initialValue: initialValue,
            trigger: (value) =>
                TriggerResponse(message1, useForValidation: true),
            predicate: (value) => value == initialValue),
      );
      await tester.pumpWidget(app1);
      expect(formKey.currentState.validate(), true);
      final app2 = createApp(
        TriggeredTextFormField(
            initialValue: initialValue,
            trigger: (value) async =>
                TriggerResponse(message1, useForValidation: false),
            predicate: (value) => value == initialValue),
      );
      await tester.pumpWidget(app2);
      final message = find.text(message1);
      expect(message, findsNothing);
    });
  });

  testWidgets('When predicate(value) == true, trigger is called',
      (tester) async {
    final app1 = createApp(
      TriggeredTextFormField(
          trigger: (value) => TriggerResponse(message1, useForValidation: true),
          predicate: (value) => value == input1),
    );
    await tester.pumpWidget(app1);
    final field1 = find.byType(TriggeredTextFormField);
    expect(field1, findsOneWidget);
    await tester.enterText(field1, input1);
    await tester.pump();
    expect(formKey.currentState.validate(), false);

    final app2 = createApp(
      TriggeredTextFormField(
          labelText: labelText,
          trigger: (value) =>
              TriggerResponse(message1, useForValidation: false),
          predicate: (value) => value == input1),
    );
    await tester.pumpWidget(app2);
    final field2 = find.byType(TriggeredTextFormField);
    expect(field2, findsOneWidget);
    await tester.enterText(field2, input1);
    await tester.pump();
    final message = find.text(message1);
    expect(message, findsOneWidget);
  });
}
