import 'dart:async';
import 'package:flutter/material.dart';

typedef Trigger = FutureOr<TriggerResponse> Function(String);

class TriggerResponse {
  const TriggerResponse(this.message, {this.color, this.useForValidation});

  final String message;
  final Color color;

  /// Set true if the async call is used for validation, and to prevent
  /// the submission of the form.
  final bool useForValidation;

  @override
  String toString() => 'TriggerResponse { message: $message, color: $color, '
      'useForValidation: $useForValidation }';
}

class TriggeredTextFormField extends FormField<String> {
  TriggeredTextFormField(
      {Key key,
      @required this.trigger,
      FormFieldValidator<String> validator,
      InputBorder border = const OutlineInputBorder(),
      @required this.triggerLength})
      : super(
            key: key,
            validator: validator,
            builder: (field) {
              final triggeredField = field as TriggeredTextFormFieldState;
              var errorText = field.errorText;
              InputBorder errorBorder, focusedErrorBorder;
              TextStyle errorStyle;
              final errorColor = triggeredField?.response?.color;
              if (errorColor != null) {
                errorText = triggeredField.response.message;
                errorBorder = border.copyWith(
                  borderSide: BorderSide(color: errorColor),
                );
                focusedErrorBorder = border.copyWith(
                  borderSide: BorderSide(color: errorColor, width: 2.0),
                );
                errorStyle = TextStyle(color: errorColor);
              }
              return Builder(
                builder: (context) => TextField(
                  controller: triggeredField.controller,
                  enabled: !triggeredField.isLoading,
                  decoration: InputDecoration(
                    errorText: errorText,
                    errorBorder: errorBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    errorStyle: errorStyle,
                    errorMaxLines: 3,
                    contentPadding: const EdgeInsets.all(15),
                    border: const OutlineInputBorder(),
                    suffixIcon: triggeredField.isLoading
                        ? Transform(
                            transform: Matrix4.translationValues(
                                Directionality.of(context) == TextDirection.ltr
                                    ? -10.0
                                    : 10.0,
                                0,
                                0),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.12)),
                            ),
                          )
                        : const SizedBox(),
                    suffixIconConstraints:
                        const BoxConstraints(maxWidth: 20, maxHeight: 20),
                  ),
                ),
              );
            });

  final int triggerLength;
  final Trigger trigger;

  @override
  TriggeredTextFormFieldState createState() => TriggeredTextFormFieldState();
}

class TriggeredTextFormFieldState extends FormFieldState<String> {
  final TextEditingController controller = TextEditingController();

  TriggerResponse response;
  String previousText;
  bool isLoading = false;

  @override
  bool get hasError => response?.useForValidation ?? super.hasError;

  @override
  void initState() {
    super.initState();
    final triggeredWidget = widget as TriggeredTextFormField;
    controller.addListener(() async {
      if (controller.text == previousText) return;
      setValue(controller.text);
      previousText = controller.text;
      response = null;
      if (controller.text.length == triggeredWidget.triggerLength) {
        previousText = controller.text;
        setState(() {
          isLoading = true;
        });
        response = await triggeredWidget.trigger(controller.text);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool validate() {
    if (!isValid || (response != null && !response.useForValidation)) {
      response = null;
    }
    return super.validate();
  }
}
