import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:triggered_text_form_field/triggered_text_form_field.dart';

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
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        )
      ),
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
                    // initialValue: "12345",
                    predicate: (value) => value == '12345',
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
                      // if (value == '12345678') return 'cannot be 12345678';
                      // if (value == '12345') return 'cannot be 12345';
                      print('validator says null');
                      return null;
                    },
                    trigger: (value)  {
                      try {
                        return value == '12345'
                            ? TriggerResponse('some warning', useForValidation: true,
                        color: Colors.amber)
                            : null;
                      } catch (e) {
                        print('exception');
                        rethrow;
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
