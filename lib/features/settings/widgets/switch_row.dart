import 'package:flutter/material.dart';

import 'custom_switch.dart';

class SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFFFE5B4), fontSize: 20, fontWeight: FontWeight.w400),
        ),
        CustomSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
