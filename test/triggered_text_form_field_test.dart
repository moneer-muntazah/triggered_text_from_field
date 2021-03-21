import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

const errorColor = Colors.red;
const warningColor = Colors.amber;
const labelText = 'Label Text';
const initialValue1 = '96325';
const triggerMessage1 = 'triggerMessage1';
const triggerMessage2 = 'triggerMessage2';
const validatorMessage1 = 'validatorMessage1';
const input1 = '01234';
const input2 = '98765';

extension CopyWith on TriggeredTextFormField {
  TriggeredTextFormField copyWith(
      {String initialValue,
      Trigger trigger,
      TriggerPredicate predicate,
      onLoadingNotifier onLoading,
      TextInputType keyboardType,
      int maxLength,
      String labelText,
      FormFieldValidator<String> validator,
      FormFieldSetter<String> onSaved}) {
    return TriggeredTextFormField(
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

extension TriggeredTextFormFieldTester on WidgetTester {
  bool get isValidForm => state<FormState>(find.byType(Form)).validate();

  String get fieldValue =>
      state<FormFieldState>(find.byType(TriggeredTextFormField)).value;

  Color textColor(String text) => widget<Text>(find.text(text)).style.color;
}

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
        body: Form(child: field),
      ),
    );

void main() {
  group('initialValue does not cause any trigger behavior', () {
    final triggeredField = TriggeredTextFormField(
        initialValue: initialValue1,
        trigger: (value) => TriggerResponse(triggerMessage1),
        predicate: (value) => value == initialValue1);
    testWidgets('when it is unchanged with useForValidation being true',
        (tester) async {
      final app = createApp(
        triggeredField.copyWith(
            trigger: (value) =>
                TriggerResponse(triggerMessage1, useForValidation: true),
            validator: (value) => value == input1 ? validatorMessage1 : null),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggerMessage1Finder = find.text(triggerMessage1);
      expect(triggerMessage1Finder, findsNothing);

      expect(tester.isValidForm, true);
      expect(tester.fieldValue, initialValue1);
    });
    testWidgets(
        'when it is edited, attempted to be submitted, then entered '
        'again with useForValidation being true', (tester) async {
      final app = createApp(
        triggeredField.copyWith(
            trigger: (value) =>
                TriggerResponse(triggerMessage1, useForValidation: true),
            validator: (value) => value == input1 ? validatorMessage1 : null),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggerMessage1Finder = find.text(triggerMessage1);
      expect(triggerMessage1Finder, findsNothing);
      expect(tester.fieldValue, initialValue1);
      await tester.enterText(field, input1);
      expect(tester.isValidForm, false);
      await tester.pump();
      expect(tester.fieldValue, input1);
      final validatorMessage1Finder = find.text(validatorMessage1);
      expect(validatorMessage1Finder, findsOneWidget);
      expect(tester.textColor(validatorMessage1), errorColor);
      await tester.enterText(field, initialValue1);
      await tester.pump();
      expect(tester.isValidForm, true);
      expect(tester.fieldValue, initialValue1);
    });
    testWidgets('when it is unchanged with useForValidation being false',
        (tester) async {
      final app = createApp(triggeredField);
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggerMessage1Finder = find.text(triggerMessage1);
      expect(triggerMessage1Finder, findsNothing);

      expect(tester.isValidForm, true);
      expect(tester.fieldValue, initialValue1);
    });
  });

  group(
      'Given some value that satisfies the predicate, trigger behavior is as '
      'expected', () {
    final triggeredField = TriggeredTextFormField(
        trigger: (value) => TriggerResponse(triggerMessage1),
        predicate: (value) => value == input1);

    group('when that value is entered', () {
      testWidgets(
          ', attempted to be submitted, edited, and entered again with '
          'useForValidation being true', (tester) async {
        final app = createApp(
          triggeredField.copyWith(
            trigger: (value) =>
                TriggerResponse(triggerMessage1, useForValidation: true),
          ),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        expect(tester.isValidForm, false);
        expect(tester.fieldValue, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        final newInput = input1.substring(0, input1.length - 1);
        await tester.enterText(field, newInput);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(find.text(input1), findsOneWidget);
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
      });

      testWidgets('and submitted with useForValidation being false',
          (tester) async {
        final app = createApp(triggeredField);
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        expect(tester.isValidForm, true);
        expect(tester.fieldValue, input1);
      });

      testWidgets(
          'and attempted to be submitted then a validation is invoked with '
          'useForValidation being true', (tester) async {
        final app = createApp(
          triggeredField.copyWith(
              trigger: (value) => TriggerResponse(triggerMessage1,
                  useForValidation: true, color: warningColor),
              validator: (value) => value == input2 ? validatorMessage1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
        expect(tester.isValidForm, false);
        await tester.pump();
        expect(tester.fieldValue, input1);
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
        await tester.enterText(field, input2);
        await tester.pump();
        const whyTriggerMessage1StillAround = 'Since input2 does not satisfy '
            'the predicate in this case, triggerMessage1 will remain along '
            'with its color';
        expect(triggerMessage1Finder, findsOneWidget,
            reason: whyTriggerMessage1StillAround);
        expect(tester.textColor(triggerMessage1), warningColor,
            reason: whyTriggerMessage1StillAround);
        expect(tester.isValidForm, false);
        await tester.pump();
        final validatorMessage1Finder = find.text(validatorMessage1);
        expect(validatorMessage1Finder, findsOneWidget);
        expect(tester.textColor(validatorMessage1), errorColor);
      });
    });

    group('when a validation is first invoked then that value is entered ', () {
      testWidgets(
          'and attempted to be submitted with useForValidation being true',
          (tester) async {
        final app = createApp(
          triggeredField.copyWith(
              trigger: (value) => TriggerResponse(triggerMessage1,
                  useForValidation: true, color: warningColor),
              validator: (value) => value.isEmpty ? validatorMessage1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        final validatorMessage1Finder = find.text(validatorMessage1);
        expect(validatorMessage1Finder, findsNothing);
        expect(tester.isValidForm, false);
        await tester.pump();
        expect(validatorMessage1Finder, findsOneWidget);
        expect(tester.textColor(validatorMessage1), errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
        expect(tester.isValidForm, false);
        await tester.pump();
        expect(tester.fieldValue, input1);
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
      });
      testWidgets('and submitted with useForValidation being false',
          (tester) async {
        final app = createApp(
          triggeredField.copyWith(
              trigger: (value) =>
                  TriggerResponse(triggerMessage1, color: warningColor),
              validator: (value) => value.isEmpty ? validatorMessage1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        final validatorMessage1Finder = find.text(validatorMessage1);
        expect(validatorMessage1Finder, findsNothing);
        expect(tester.isValidForm, false);
        await tester.pump();
        expect(validatorMessage1Finder, findsOneWidget);
        expect(tester.textColor(validatorMessage1), errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
        expect(tester.isValidForm, true);
        expect(tester.fieldValue, input1);
      });
    });
  });

  group(
      'Given two values that satisfy the predicate, trigger behavior is as '
      'expected', () {
    final triggeredField = TriggeredTextFormField(
        trigger: (value) => value == input1
            ? TriggerResponse(triggerMessage1, useForValidation: true)
            : TriggerResponse(triggerMessage2,
                color: warningColor, useForValidation: false),
        predicate: (value) => value == input1 || value == input2);
    group('when the first value is entered, attempted to be submitted ', () {
      testWidgets(
          'second value is entered and submitted with useForValidation being '
          'true to the first value, but false to the second', (tester) async {
        final app = createApp(triggeredField);
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        expect(tester.isValidForm, false);
        expect(tester.fieldValue, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), errorColor);
        await tester.enterText(field, input2);
        await tester.pump();
        final triggeredMessage2Finder = find.text(triggerMessage2);
        expect(triggeredMessage2Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage2), warningColor);
        expect(tester.isValidForm, true);
        expect(tester.fieldValue, input2);
      });
      testWidgets(
          ', a validation is invoked then the second value is entered and '
          'submitted with useForValidation being false for both values',
          (tester) async {
        final app = createApp(
          triggeredField.copyWith(
            validator: (value) => value == input1 ? validatorMessage1 : null,
            trigger: (value) => value == input1
                ? TriggerResponse(triggerMessage1, color: warningColor)
                : TriggerResponse(triggerMessage2, color: warningColor),
          ),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggerMessage1Finder = find.text(triggerMessage1);
        expect(triggerMessage1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggerMessage1Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage1), warningColor);
        expect(tester.isValidForm, false);
        await tester.pump();
        expect(tester.fieldValue, input1);
        final validationMessage1Finder = find.text(validatorMessage1);
        expect(validationMessage1Finder, findsOneWidget);
        expect(tester.textColor(validatorMessage1), errorColor);
        await tester.enterText(field, input2);
        await tester.pump();
        final triggerMessage2Finder = find.text(input2);
        expect(triggerMessage2Finder, findsOneWidget);
        expect(tester.textColor(triggerMessage2), warningColor);
        expect(tester.isValidForm, true);
        await tester.pump();
        expect(tester.fieldValue, input2);
      });
    });
  });
}
