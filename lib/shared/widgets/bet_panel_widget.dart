import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../features/game/game_provider.dart';

class BetPanelWidget extends StatefulWidget {
  const BetPanelWidget({super.key});

  @override
  State<BetPanelWidget> createState() => _BetPanelWidgetState();
}

class _BetPanelWidgetState extends State<BetPanelWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    final initialBet = context.read<GameProvider>().bet;
    _controller = TextEditingController(text: '$initialBet');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Syncs the controller only when the field does not have focus,
  // so active keyboard input is never overwritten by a provider rebuild.
  void _syncController(int bet) {
    if (_focusNode.hasFocus) return;
    final text = '$bet';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _changeBet(int delta) {
    final provider = context.read<GameProvider>();
    provider.setBet(provider.bet + delta);
    _syncController(provider.bet);
  }

  void _startHold(int delta) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _changeBet(delta);
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  // Called only via onEditingComplete; unfocuses after applying value.
  void _commitInput() {
    final parsed = int.tryParse(_controller.text);
    final provider = context.read<GameProvider>();
    if (parsed == null) {
      _controller.text = '${provider.bet}';
    } else {
      provider.setBet(parsed);
      _controller.text = '${provider.bet}';
    }
    _focusNode.unfocus();
  }

  Widget _buildButton({required String label, required int delta, required bool disabled}) {
    final color = disabled ? Colors.grey.shade400 : Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disabled ? null : () => _changeBet(delta),
        onLongPress: disabled ? null : () {},
        child: GestureDetector(
          onLongPressStart: disabled ? null : (_) => _startHold(delta),
          onLongPressEnd: disabled ? null : (_) => _stopHold(),
          onLongPressCancel: disabled ? null : _stopHold,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isRunning = game.state == RoundState.running;

    // Only sync when the field is not focused to avoid overwriting typed input.
    _syncController(game.bet);

    return IgnorePointer(
      ignoring: isRunning,
      child: Opacity(
        opacity: isRunning ? 0.5 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(label: '−', delta: -1, disabled: isRunning),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isRunning,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  helperText: 'Min ${Constants.minBet} / Max ${game.maxBet}',
                  helperStyle: const TextStyle(fontSize: 10),
                ),
                // onEditingComplete handles both submit and unfocus in one call;
                // onSubmitted is intentionally omitted to avoid double execution.
                onEditingComplete: _commitInput,
              ),
            ),
            const SizedBox(width: 12),
            _buildButton(label: '+', delta: 1, disabled: isRunning),
          ],
        ),
      ),
    );
  }
}
