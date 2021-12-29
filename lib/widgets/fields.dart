import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roman/services/constants.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key? key,
    this.hint,
    this.icon,
    this.type,
    this.controller,
    this.onTap,
    this.formatter,
    this.obscureText = false,
    this.readOnly = false,
    this.autofillHints = const <String>[],
    this.onChanged,
  }) : super(key: key);

  final String? hint;
  final IconData? icon;
  final TextInputType? type;
  final TextEditingController? controller;
  final Function()? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatter;
  final bool obscureText;
  final bool readOnly;
  final List<String> autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      controller: controller,
      inputFormatters: formatter,
      readOnly: readOnly,
      textCapitalization: TextCapitalization.sentences,
      keyboardAppearance: Brightness.light,
      keyboardType: type,
      obscureText: obscureText,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      autofillHints: autofillHints,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        border: const OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        counterStyle: const TextStyle(
          height: double.minPositive,
        ),
        counterText: "",
        prefixIcon: icon != null
            ? Icon(
                icon!,
                color: Colors.blueGrey[800],
              )
            : null,
      ),
    );
  }
}
