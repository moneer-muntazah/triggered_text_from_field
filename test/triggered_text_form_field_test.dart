import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

const errorColor = Colors.red;
const warningColor = Colors.amber;
const labelText = 'Label Text';
const initialValue1 = '01234';

/// Use [message1], and [message2] for for trigger returns.
const message1 = 'message1';
const message2 = 'message2';

/// Use [validation1] for validator returns.
const validation1 = 'validation1';
const input1 = '01234';
const input2 = '0123456789';

extension CopyWith on TriggeredTextFormField {
  TriggeredTextFormField copyWith(
      {Key key,
      String initialValue,
      Trigger trigger,
      TriggerPredicate predicate,
      onLoadingNotifier onLoading,
      TextInputType keyboardType,
      int maxLength,
      String labelText,
      FormFieldValidator<String> validator,
      FormFieldSetter<String> onSaved}) {
    return TriggeredTextFormField(
      key: key ?? this.key,
      initialValue: initialValue ?? this.initialValue,
      trigger: trigger ?? this.trigger,
      predicate: predicate ?? this.predicate,
      onLoading: onLoading ?? this.onLoading,
      keyboardType: keyboardType,
      maxLength: maxLength,
      labelText: labelText,
      validator: validator ?? this.validator,
      onSaved: onSaved ?? this.onSaved,
    );
  }
}

void main() {
  GlobalKey<FormState> formKey;
  GlobalKey<FormFieldState> fieldKey;

  setUp(() {
    formKey = GlobalKey<FormState>();
    fieldKey = GlobalKey<FormFieldState>();
  });

  MaterialApp createApp(TriggeredTextFormField field) => MaterialApp(
        theme: ThemeData(
          errorColor: errorColor,
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(fontSize: 15),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
            ),
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.all(15),
          ),
        ),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: field,
          ),
        ),
      );

  // Not yet done with this test. It is only true on initial screen load.
  group(
      'initialValue does not cause any trigger behavior when the initialValue'
      'is submitted', () {
    final triggerTextFormField = TriggeredTextFormField(
        initialValue: initialValue1,
        trigger: (value) => TriggerResponse(message1),
        predicate: (value) => value == initialValue1);
    testWidgets('with useForValidation being true', (tester) async {
      final app = createApp(
        triggerTextFormField.copyWith(
          key: fieldKey,
          trigger: (value) => TriggerResponse(message1, useForValidation: true),
        ),
      );
      await tester.pumpWidget(app);
      expect(find.text(message1), findsNothing);
      expect(formKey.currentState.validate(), true);
      expect(fieldKey.currentState.value, initialValue1);
    });

    testWidgets('with useForValidation being false', (tester) async {
      final app = createApp(
        triggerTextFormField.copyWith(key: fieldKey),
      );
      await tester.pumpWidget(app);
      expect(find.text(message1), findsNothing);
      expect(formKey.currentState.validate(), true);
      expect(fieldKey.currentState.value, initialValue1);
    });
  });

  group(
      'Given some value that satisfies the predicate trigger behavior is as '
      'expected', () {
    final triggerTextFormField = TriggeredTextFormField(
        trigger: (value) => TriggerResponse(message1),
        predicate: (value) => value == input1);
    testWidgets(
        'when that value is entered, attempted to be submitted, edited, and '
        'entered again with useForValidation being true', (tester) async {
      final app = createApp(
        triggerTextFormField.copyWith(
          key: fieldKey,
          trigger: (value) => TriggerResponse(message1, useForValidation: true),
        ),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final message1Finder = find.text(message1);
      expect(message1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      expect(formKey.currentState.validate(), false);
      expect(fieldKey.currentState.value, input1);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      final newInput = input1.substring(0, input1.length - 1);
      await tester.enterText(field, newInput);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(find.text(input1), findsOneWidget);
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
    });

    testWidgets(
        'when that value is entered and submitted with useForValidation being '
        'false', (tester) async {
      final app = createApp(
        triggerTextFormField.copyWith(key: fieldKey),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final message1Finder = find.text(message1);
      expect(message1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      expect(formKey.currentState.validate(), true);
      expect(fieldKey.currentState.value, input1);
    });

    group('when a validation is first invoked then that value is entered ', () {
      testWidgets(
          'and attempted to be submitted with useForValidation being true',
          (tester) async {
        final app = createApp(
          triggerTextFormField.copyWith(
              key: fieldKey,
              trigger: (value) => TriggerResponse(message1,
                  useForValidation: true, color: warningColor),
              validator: (value) => value.isEmpty ? validation1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final message1Finder = find.text(message1);
        expect(message1Finder, findsNothing);
        final validation1Finder = find.text(validation1);
        expect(validation1Finder, findsNothing);
        expect(formKey.currentState.validate(), false);
        await tester.pump();
        expect(validation1Finder, findsOneWidget);
        expect(tester.widget<Text>(validation1Finder).style.color, errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(message1Finder, findsOneWidget);
        expect(tester.widget<Text>(message1Finder).style.color, warningColor);
        expect(formKey.currentState.validate(), false);
        await tester.pump();
        expect(fieldKey.currentState.value, input1);
        expect(message1Finder, findsOneWidget);
        expect(tester.widget<Text>(message1Finder).style.color, warningColor);
      });
      testWidgets('and submitted with useForValidation being false',
          (tester) async {
        final app = createApp(
          triggerTextFormField.copyWith(
              key: fieldKey,
              trigger: (value) =>
                  TriggerResponse(message1, color: warningColor),
              validator: (value) => value.isEmpty ? validation1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final message1Finder = find.text(message1);
        expect(message1Finder, findsNothing);
        final validation1Finder = find.text(validation1);
        expect(validation1Finder, findsNothing);
        expect(formKey.currentState.validate(), false);
        await tester.pump();
        expect(validation1Finder, findsOneWidget);
        expect(tester.widget<Text>(validation1Finder).style.color, errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(message1Finder, findsOneWidget);
        expect(tester.widget<Text>(message1Finder).style.color, warningColor);
        expect(formKey.currentState.validate(), true);
        expect(fieldKey.currentState.value, input1);
      });
    });
  });

  group(
      'Given two values that satisfy the predicate trigger behavior is as '
      'expected', () {
    final triggerTextFormField = TriggeredTextFormField(
        trigger: (value) => value == input1
            ? TriggerResponse(message1, useForValidation: true)
            : TriggerResponse(message2,
                color: warningColor, useForValidation: false),
        predicate: (value) => value == input1 || value == input2);
    testWidgets(
        'when the first value is entered, attempted to be submitted then the '
        'second value is entered and submitted with useForValidation being true '
        'to the first value, but false to the second', (tester) async {
      final app = createApp(
        triggerTextFormField.copyWith(key: fieldKey),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final message1Finder = find.text(message1);
      expect(message1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      expect(formKey.currentState.validate(), false);
      expect(fieldKey.currentState.value, input1);
      await tester.pump();
      expect(message1Finder, findsOneWidget);
      expect(tester.widget<Text>(message1Finder).style.color, errorColor);
      await tester.enterText(field, input2);
      await tester.pump();
      final message2Finder = find.text(message2);
      expect(message2Finder, findsOneWidget);
      expect(tester.widget<Text>(message2Finder).style.color, warningColor);
      expect(formKey.currentState.validate(), true);
      expect(fieldKey.currentState.value, input2);
    });
  });
}
