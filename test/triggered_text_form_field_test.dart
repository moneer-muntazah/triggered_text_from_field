// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:triggered_text_form_field/triggered_text_form_field.dart';
//
// void main() {
//   const MethodChannel channel = MethodChannel('triggered_text_form_field');
//
//   TestWidgetsFlutterBinding.ensureInitialized();
//
//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       return '42';
//     });
//   });
//
//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });
//
//   test('getPlatformVersion', () async {
//     expect(await TriggeredTextFormField.platformVersion, '42');
//   });
// }
