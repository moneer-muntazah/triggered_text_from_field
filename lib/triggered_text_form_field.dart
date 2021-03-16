import 'dart:async';
import 'package:flutter/material.dart';

typedef Trigger = FutureOr<String> Function(String);

class TriggeredTextFormField extends FormField<String> {
  final int triggerLength;
  final Trigger trigger;

  TriggeredTextFormField(
      {Key key,
      @required this.trigger,
      FormFieldValidator<String> validator,
      @required this.triggerLength})
      : super(
            key: key,
            validator: validator,
            builder: (field) {
              final triggeredField = field as TriggeredTextFormFieldState;
              return Builder(
                builder: (context) => TextField(
                  controller: triggeredField.controller,
                  enabled: !triggeredField.isLoading,
                  decoration: InputDecoration(
                    errorText: triggeredField.message ?? field.errorText,
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

  String message;
  String previousText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final triggeredWidget = widget as TriggeredTextFormField;
    controller.addListener(() async {
      if (controller.text.length == triggeredWidget.triggerLength &&
          controller.text != previousText) {
        previousText = controller.text;
        setState(() {
          isLoading = true;
        });
        message = await triggeredWidget.trigger(controller.text);
        setState(() {
          isLoading = false;
        });
      } else {
        message = null;
      }
    });
  }
}
