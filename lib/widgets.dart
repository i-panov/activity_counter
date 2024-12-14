import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DateFormField extends StatefulWidget {
  final DateTime initialValue;

  DateFormField({
    super.key, 
    DateTime? initialValue,
  }) : initialValue = initialValue ?? DateTime.now();

  @override
  State createState() => DateFormFieldState();

  String? get initialStringValue => '${initialValue.hour}:${initialValue.minute}';
}

class DateFormFieldState extends State<DateFormField> {
  late final _fmt = MaskTextInputFormatter(
    mask: '##:##',
    filter: {'#': RegExp(r'[0-9]')},
    initialText: widget.initialStringValue,
  );

  late final _ctrl = TextEditingController(text: widget.initialStringValue ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _ctrl,
    decoration: const InputDecoration(labelText: 'Время'),
    validator: (v) => v == null || v.isEmpty ? 'Введите время' : null,
    inputFormatters: [_fmt],
  );
}
