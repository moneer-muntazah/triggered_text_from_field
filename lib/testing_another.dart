import 'package:flutter/material.dart';

class TestingAnother extends StatefulWidget {

  final TextEditingController controller = TextEditingController();

  @override
  _TestingAnotherState createState() => _TestingAnotherState();
}

class _TestingAnotherState extends State<TestingAnother> {

  String test = '';
  @override
  void initState() {
    super.initState();
    print('initState');
    widget.controller.addListener(() {
      print('called callback');
      setState(() {
        test = DateTime.now().toString();
      });
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
          controller: widget.controller,
        ),
        Text(test)
      ],
    );
  }
}
