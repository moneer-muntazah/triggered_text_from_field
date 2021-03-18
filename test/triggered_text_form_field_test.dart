import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

const labelText = 'Label Text';
const initialValue1 = '01234';
const message1 = 'message1';
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
      FormFieldSetter<String> onSaved,
      InputBorder border = const OutlineInputBorder()}) {
    return TriggeredTextFormField(
      key: key,
      initialValue: initialValue ?? this.initialValue,
      trigger: trigger ?? this.trigger,
      predicate: predicate ?? this.predicate,
      onLoading: onLoading ?? this.onLoading,
      keyboardType: keyboardType,
      maxLength: maxLength,
      labelText: labelText,
      validator: validator ?? this.validator,
      onSaved: onSaved ?? this.onSaved,
      border: border,
    );
  }
}

extension EdgeCharater on String {
  String get first => this[0];

  String get last => this[length - 1];
}

void main() {
  GlobalKey<FormState> formKey;

  setUp(() {
    formKey = GlobalKey<FormState>();
  });

  MaterialApp createApp(TriggeredTextFormField field) => MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: field,
          ),
        ),
      );

  group('When initialValue != null, and predicate(initialValue) == true', () {
    final triggerTextFormField = TriggeredTextFormField(
        initialValue: initialValue1,
        trigger: (value) => TriggerResponse(message1),
        predicate: (value) => value == initialValue1);
    group('initially (on screen first load) trigger is not called', () {
      testWidgets('with useForValidation == true', (tester) async {
        final app = createApp(
          triggerTextFormField.copyWith(
            trigger: (value) =>
                TriggerResponse(message1, useForValidation: true),
          ),
        );
        await tester.pumpWidget(app);
        expect(find.text(message1), findsNothing);
        expect(formKey.currentState.validate(), true);
      });

      testWidgets('with useForValidation == false', (tester) async {
        final app = createApp(triggerTextFormField);
        await tester.pumpWidget(app);
        expect(find.text(message1), findsNothing);
        expect(formKey.currentState.validate(), true);
      });
    });
  });

  group('When predicate(value) == true, trigger is called', () {
    final triggerTextFormField = TriggeredTextFormField(
        trigger: (value) => TriggerResponse(message1),
        predicate: (value) => value == input1 || value == input2);
    group('with value == input1 (single try)', () {
      testWidgets('and useForValidation == true', (tester) async {
        final app = createApp(
          triggerTextFormField.copyWith(
            trigger: (value) =>
                TriggerResponse(message1, useForValidation: true),
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
        expect(formKey.currentState.validate(), false);
      });

      testWidgets('and useForValidation == false', (tester) async {
        final app = createApp(triggerTextFormField);
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final message1Finder = find.text(message1);
        expect(message1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(message1Finder, findsOneWidget);
        expect(formKey.currentState.validate(), true);
      });
    });

    group('with value == input1 (double try)', () {
      testWidgets('and useForValidation == true', (tester) async {
        final app = createApp(
          triggerTextFormField.copyWith(
            trigger: (value) =>
                TriggerResponse(message1, useForValidation: true),
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
        expect(formKey.currentState.validate(), false);
        final newInput = input1.substring(0, input1.length - 1);
        await tester.enterText(field, newInput);
        await tester.pump();
        expect(message1Finder, findsOneWidget);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(find.text(input1), findsOneWidget);
        expect(message1Finder, findsOneWidget);
      });

      testWidgets('and useForValidation == false', (tester) async {
        final app = createApp(triggerTextFormField);
        await tester.pumpWidget(app);
        final field = find.byType(TriggeredTextFormField);
        expect(field, findsOneWidget);
        final message1Finder = find.text(message1);
        expect(message1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(message1Finder, findsOneWidget);
        expect(formKey.currentState.validate(), true);
        final newInput = input1.substring(0, input1.length - 1);
        await tester.enterText(field, newInput);
        await tester.pump();
        expect(message1Finder, findsNothing);
        await tester.enterText(field, input1);
        await tester.pump();
        expect(find.text(input1), findsOneWidget);
        expect(message1Finder, findsOneWidget);
      });
    });
  });
}
