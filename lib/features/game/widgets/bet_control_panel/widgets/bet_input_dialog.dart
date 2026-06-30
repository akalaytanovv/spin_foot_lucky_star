import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants.dart';
import '../../../../../shared/widgets/image_button.dart';
import '../../../game_provider.dart';

Future<void> showBetInputDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(value: context.read<GameProvider>(), child: const _BetInputDialog()),
  );
}

class _BetInputDialog extends StatefulWidget {
  const _BetInputDialog();

  @override
  State<_BetInputDialog> createState() => _BetInputDialogState();
}

class _BetInputDialogState extends State<_BetInputDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = context.read<GameProvider>().bet;
    _controller = TextEditingController(text: '$_value');
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncController() {
    final text = '$_value';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _setValue(int next) {
    final maxBet = context.read<GameProvider>().maxBet;
    setState(() {
      _value = next.clamp(Constants.minBet, maxBet);
      _syncController();
    });
  }

  void _applyFromField() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) {
      _setValue(parsed);
    } else {
      _syncController();
    }
  }

  void _submitFromKeyboard() {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null) {
      _syncController();
      return;
    }

    final maxBet = context.read<GameProvider>().maxBet;
    if (parsed > maxBet) {
      _setValue(parsed);
      return;
    }

    _apply();
  }

  void _apply() {
    _applyFromField();
    Navigator.of(context).pop();
    context.read<GameProvider>().setBet(_value);
  }

  @override
  Widget build(BuildContext context) {
    final maxBet = context.select<GameProvider, int>((g) => g.maxBet);
    final topOffset = MediaQuery.sizeOf(context).height * 0.14;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
      child: Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.fromLTRB(20, topOffset, 20, 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: Image.asset('assets/bet_card_bg.png', fit: BoxFit.fill)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'BET AMOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFE5B4),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Min ${Constants.minBet} / Max $maxBet',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFFE5B4), fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 10),
                  _BetStepper(
                    controller: _controller,
                    focusNode: _focusNode,
                    onDecrement: _value > Constants.minBet ? () => _setValue(_value - Constants.betStep) : null,
                    onIncrement: _value < maxBet ? () => _setValue(_value + Constants.betStep) : null,
                    onSubmit: _submitFromKeyboard,
                  ),
                  const SizedBox(height: 14),
                  ImageButton(label: 'Apply', height: 50, labelStyle: ImageButton.dialogLabelStyle, onPressed: _apply),
                ],
              ),
            ),
            Positioned(
              top: 14,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Color(0xFFFFE5B4), size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BetStepper extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback onSubmit;

  const _BetStepper({
    required this.controller,
    required this.focusNode,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSubmit,
  });

  Widget _stepBtn({required String label, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: onTap == null ? 0.35 : 1.0,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: const Color(0xFF7BA74F), borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: const Color(0x22FFE5B4), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _stepBtn(label: '−', onTap: onDecrement),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFE5B4),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onEditingComplete: onSubmit,
            ),
          ),
          _stepBtn(label: '+', onTap: onIncrement),
        ],
      ),
    );
  }
}
