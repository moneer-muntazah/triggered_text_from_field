import 'dart:async';
import 'package:flutter/material.dart';

typedef _Trigger = FutureOr<TriggerResponse> Function(String);
typedef _onLoadingNotifier = void Function(bool);

class TriggerResponse {
  const TriggerResponse(this.message, {this.color, this.useForValidation});

  final String message;
  final Color color;

  /// Set true if the async call is used for validation to prevent the
  /// submission of the form. Setting this to true will cause the validate call
  /// on the instant of the [FormState] to return false even if the validator
  /// call back return null.
  final bool useForValidation;

  @override
  String toString() => 'TriggerResponse { message: $message, color: $color, '
      'useForValidation: $useForValidation }';
}

/// Similar to [TextFormField], but can be trigger an async callback when the
/// value inputted reaches a specified length.
class TriggeredTextFormField extends FormField<String> {
  TriggeredTextFormField(
      {Key key,
      String initialValue,
      @required this.trigger,
      @required this.triggerLength,
      this.onLoading,
      int maxLength,
      String labelText,
      FormFieldValidator<String> validator,
      FormFieldSetter<String> onSaved,
      InputBorder border = const OutlineInputBorder()})
      : assert(trigger != null),
        assert(triggerLength != null),
        assert(() {
          if (maxLength == null) return true;
          if (triggerLength > maxLength) return false;
          return true;
        }(),
            'Since triggerLength is used to know when to fire the trigger '
            'callback, maxLength cannot exceed it'),
        super(
            key: key,
            initialValue: initialValue ?? '',
            validator: validator,
            onSaved: onSaved,
            builder: (field) {
              final triggeredField = field as _TriggeredTextFormFieldState;
              var errorText = triggeredField.errorText;
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
              return TextField(
                controller: triggeredField.controller,
                enabled: !triggeredField._isLoading,
                maxLength: maxLength,
                decoration: InputDecoration(
                  labelText: labelText,
                  errorText: errorText,
                  errorBorder: errorBorder,
                  focusedErrorBorder: focusedErrorBorder,
                  errorStyle: errorStyle,
                  errorMaxLines: 3,
                  counterText: '',
                  contentPadding: const EdgeInsets.all(15),
                  border: const OutlineInputBorder(),
                  suffixIcon: triggeredField._isLoading
                      ? Transform(
                          transform: Matrix4.translationValues(
                              Directionality.of(triggeredField.context) ==
                                      TextDirection.ltr
                                  ? -10.0
                                  : 10.0,
                              0,
                              0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(triggeredField.context)
                                  .disabledColor
                                  .withOpacity(0.12),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  suffixIconConstraints:
                      const BoxConstraints(maxWidth: 20, maxHeight: 20),
                ),
              );
            });

  final int triggerLength;
  final _Trigger trigger;
  final _onLoadingNotifier onLoading;

  @override
  _TriggeredTextFormFieldState createState() => _TriggeredTextFormFieldState();
}

class _TriggeredTextFormFieldState extends FormFieldState<String> {
  TextEditingController controller;
  TriggerResponse response;
  String _previousText;

  bool _isLoading = false;

  set isLoading(value) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (widget.onLoading != null) {
      widget.onLoading(value);
    }
    _isLoading = value;
  }

  TriggeredTextFormField get widget => super.widget as TriggeredTextFormField;

  @override
  bool get hasError => response?.useForValidation ?? super.hasError;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
    controller.addListener(() async {
      if (controller.text == _previousText) return;
      setValue(controller.text);
      _previousText = controller.text;
      response = null;
      if (controller.text.length == widget.triggerLength) {
        _previousText = controller.text;
        setState(() {
          isLoading = true;
        });
        response = await widget.trigger(controller.text);
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
