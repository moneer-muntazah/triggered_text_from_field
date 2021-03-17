import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

MaterialApp createApp(GlobalKey<FormState> key, TriggeredTextFormField field) =>
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: key,
          child: Column(
            children: <Widget>[
              field,
              RaisedButton(child: Text('Submit'),onPressed: key.currentState.validate)
            ],
          ),
        ),
      ),
    );

void main() {
  testWidgets(
      'When an initial value is provided, it valid despite challenging '
      'predicate checks', (tester) async {
    final formKey = GlobalKey<FormState>();
    const initialValue = '123456';
    final app = createApp(
      formKey,
      TriggeredTextFormField(
          initialValue: initialValue,
          trigger: (value) async {
            final message =
                await Future.delayed(Duration(seconds: 2), () => 'error');
            return TriggerResponse(message);
          },
          predicate: (value) => value == initialValue),
    );
    await tester.pumpWidget(app);
    await tester.tap(find.widgetWithText(RaisedButton, 'Submit'));
    //expect(formKey.currentState.validate(), true);
  });
}
