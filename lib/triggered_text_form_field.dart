import 'dart:async';
import 'package:flutter/material.dart';

typedef Trigger = FutureOr<TriggerResponse> Function(String);

class TriggerResponse {
  const TriggerResponse(this.message, {this.color, this.enforce = false});

  final String message;
  final Color color;

  @override
  String toString() => 'TriggerResponse { message: $message, color: $color }';
}

class TriggeredTextFormField extends FormField<String> {
  final int triggerLength;
  final Trigger trigger;

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
              InputBorder errorBorder;
              TextStyle errorStyle;
              final errorColor = triggeredField?.response?.color;
              if (errorColor != null) {
                errorBorder = border.copyWith(
                  borderSide: BorderSide(color: errorColor),
                );
                errorStyle = TextStyle(color: errorColor);
              }
              return Builder(
                builder: (context) => TextField(
                  controller: triggeredField.controller,
                  enabled: !triggeredField.isLoading,
                  decoration: InputDecoration(
                    errorText:
                        triggeredField?.response?.message ?? field.errorText,
                    errorBorder: errorBorder,
                    focusedErrorBorder: errorBorder,
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
                                  Theme.of(context).disabledColor),
                            ),
                          )
                        : const SizedBox(),
                    suffixIconConstraints:
                        const BoxConstraints(maxWidth: 20, maxHeight: 20),
                  ),
                ),
              );
            });

  @override
  TriggeredTextFormFieldState createState() => TriggeredTextFormFieldState();
}

class TriggeredTextFormFieldState extends FormFieldState<String> {
  final TextEditingController controller = TextEditingController();

  TriggerResponse response;
  String previousText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final triggeredWidget = widget as TriggeredTextFormField;
    controller.addListener(() async {
      if (controller.text == previousText) return;
      previousText = controller.text;
      if (controller.text.length == triggeredWidget.triggerLength) {
        previousText = controller.text;
        setState(() {
          isLoading = true;
        });
        response = await triggeredWidget.trigger(controller.text);
        setState(() {
          isLoading = false;
        });
      } else {
        response = null;
      }
    });
  }
}
