import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';
import 'package:triggered_text_form_field/testing_another.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TestingAnother(),
                  // const SizedBox(height: 15),
                  TextFormField(
                    maxLines: 30,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TriggeredTextFormField(
                    initialValue: "12345",
                    predicate: (value) =>
                        RegExp(r'^[0-9]{5}$').hasMatch(value) ||
                        RegExp(r'^[0-9]{8}$').hasMatch(value),
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      print('saved $value');
                    },
                    onLoading: (value) {
                      print('isLoading $value');
                    },
                    validator: (value) {
                      print(value);
                      if (value.isEmpty) return 'required field';
                      if (value == '12345678') return 'cannot be that easy';
                      if (value == '12345') return 'cannot be that easy';
                      print('validator says null');
                      return null;
                    },
                    trigger: (value) async {
                      try {
                        final message = await Future.delayed(
                            Duration(seconds: 2), () => 'there was an error');
                        return value == '12345'
                            ? TriggerResponse(message, useForValidation: false)
                            : TriggerResponse(message,
                                color: Colors.deepOrange,
                                useForValidation: true);
                      } catch (e) {
                        print('exception');
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        print('submitted');
                      }
                    },
                    child: Text('Submit'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
