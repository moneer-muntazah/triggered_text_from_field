import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

const errorColor = Colors.red;
const warningColor = Colors.amber;
const labelText = 'Label Text';
const initialValue1 = '01234';
const triggerMessage1 = 'triggerMessage1';
const triggerMessage2 = 'triggerMessage2';
const validationMessage1 = 'validationMessage1';
const input1 = '01234';
const input2 = '0123456789';

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

extension FindStateByType on WidgetTester {
  S stateByType<S extends State<StatefulWidget>, T>() =>
      state<S>(find.byType(T));
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
  // Not yet done with this test. It is only true on initial screen load.
  group(
      'initialValue does not cause any trigger behavior when the initialValue'
      'is submitted', () {
    final triggeredField = TriggeredTextFormField(
        initialValue: initialValue1,
        trigger: (value) => TriggerResponse(triggerMessage1),
        predicate: (value) => value == initialValue1);
    testWidgets('with useForValidation being true', (tester) async {
      final app = createApp(
        triggeredField.copyWith(
          trigger: (value) =>
              TriggerResponse(triggerMessage1, useForValidation: true),
        ),
      );
      await tester.pumpWidget(app);
      expect(find.text(triggerMessage1), findsNothing);
      expect(tester.stateByType<FormState, Form>().validate(), true);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          initialValue1);
    });

    testWidgets('with useForValidation being false', (tester) async {
      final app = createApp(triggeredField);
      await tester.pumpWidget(app);
      expect(find.text(triggerMessage1), findsNothing);
      expect(tester.stateByType<FormState, Form>().validate(), true);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          initialValue1);
    });
  });

  group(
      'Given some value that satisfies the predicate trigger behavior is as '
      'expected', () {
    final triggeredField = TriggeredTextFormField(
        trigger: (value) => TriggerResponse(triggerMessage1),
        predicate: (value) => value == input1);
    testWidgets(
        'when that value is entered, attempted to be submitted, edited, and '
        'entered again with useForValidation being true', (tester) async {
      final app = createApp(
        triggeredField.copyWith(
          trigger: (value) =>
              TriggerResponse(triggerMessage1, useForValidation: true),
        ),
      );
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggeredMessage1Finder = find.text(triggerMessage1);
      expect(triggeredMessage1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      expect(tester.stateByType<FormState, Form>().validate(), false);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          input1);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      final newInput = input1.substring(0, input1.length - 1);
      await tester.enterText(field, newInput);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(find.text(input1), findsOneWidget);
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
    });

    testWidgets(
        'when that value is entered and submitted with useForValidation being '
        'false', (tester) async {
      final app = createApp(triggeredField);
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggeredMessage1Finder = find.text(triggerMessage1);
      expect(triggeredMessage1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      expect(tester.stateByType<FormState, Form>().validate(), true);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          input1);
    });

    group('when a validation is first invoked then that value is entered ', () {
      testWidgets(
          'and attempted to be submitted with useForValidation being true',
          (tester) async {
        final app = createApp(
          triggeredField.copyWith(
              trigger: (value) => TriggerResponse(triggerMessage1,
                  useForValidation: true, color: warningColor),
              validator: (value) => value.isEmpty ? validationMessage1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggeredMessage1Finder = find.text(triggerMessage1);
        expect(triggeredMessage1Finder, findsNothing);
        final validationMessage1Finder = find.text(validationMessage1);
        expect(validationMessage1Finder, findsNothing);
        expect(tester.stateByType<FormState, Form>().validate(), false);
        await tester.pump();
        expect(validationMessage1Finder, findsOneWidget);
        expect(tester.widget<Text>(validationMessage1Finder).style.color,
            errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggeredMessage1Finder, findsOneWidget);
        expect(tester.widget<Text>(triggeredMessage1Finder).style.color,
            warningColor);
        expect(tester.stateByType<FormState, Form>().validate(), false);
        await tester.pump();
        expect(
            tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
            input1);
        expect(triggeredMessage1Finder, findsOneWidget);
        expect(tester.widget<Text>(triggeredMessage1Finder).style.color,
            warningColor);
      });
      testWidgets('and submitted with useForValidation being false',
          (tester) async {
        final app = createApp(
          triggeredField.copyWith(
              trigger: (value) =>
                  TriggerResponse(triggerMessage1, color: warningColor),
              validator: (value) => value.isEmpty ? validationMessage1 : null),
        );
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final triggeredMessage1Finder = find.text(triggerMessage1);
        expect(triggeredMessage1Finder, findsNothing);
        final validationMessage1Finder = find.text(validationMessage1);
        expect(validationMessage1Finder, findsNothing);
        expect(tester.stateByType<FormState, Form>().validate(), false);
        await tester.pump();
        expect(validationMessage1Finder, findsOneWidget);
        expect(tester.widget<Text>(validationMessage1Finder).style.color,
            errorColor);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(triggeredMessage1Finder, findsOneWidget);
        expect(tester.widget<Text>(triggeredMessage1Finder).style.color,
            warningColor);
        expect(tester.stateByType<FormState, Form>().validate(), true);
        expect(
            tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
            input1);
      });
    });
  });

  group(
      'Given two values that satisfy the predicate trigger behavior is as '
      'expected', () {
    final triggeredField = TriggeredTextFormField(
        trigger: (value) => value == input1
            ? TriggerResponse(triggerMessage1, useForValidation: true)
            : TriggerResponse(triggerMessage2,
                color: warningColor, useForValidation: false),
        predicate: (value) => value == input1 || value == input2);
    testWidgets(
        'when the first value is entered, attempted to be submitted then the '
        'second value is entered and submitted with useForValidation being true '
        'to the first value, but false to the second', (tester) async {
      final app = createApp(triggeredField);
      await tester.pumpWidget(app);
      final field = find.byType(TriggeredTextFormField);
      expect(field, findsOneWidget);
      final triggeredMessage1Finder = find.text(triggerMessage1);
      expect(triggeredMessage1Finder, findsNothing);
      await tester.enterText(field, input1);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      expect(tester.stateByType<FormState, Form>().validate(), false);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          input1);
      await tester.pump();
      expect(triggeredMessage1Finder, findsOneWidget);
      expect(
          tester.widget<Text>(triggeredMessage1Finder).style.color, errorColor);
      await tester.enterText(field, input2);
      await tester.pump();
      final triggeredMessage2Finder = find.text(triggerMessage2);
      expect(triggeredMessage2Finder, findsOneWidget);
      expect(tester.widget<Text>(triggeredMessage2Finder).style.color,
          warningColor);
      expect(tester.stateByType<FormState, Form>().validate(), true);
      expect(tester.stateByType<FormFieldState, TriggeredTextFormField>().value,
          input2);
    });
  });
}
