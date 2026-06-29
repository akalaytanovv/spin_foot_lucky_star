import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/image_button.dart';
import '../../../game_provider.dart';

const _kRoundOptions = [10, 40, 100, 200];
const _kCashOutMax = 100;

Future<void> showAutoPlayDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(value: context.read<GameProvider>(), child: const _AutoPlayDialog()),
  );
}

class _AutoPlayDialog extends StatefulWidget {
  const _AutoPlayDialog();

  @override
  State<_AutoPlayDialog> createState() => _AutoPlayDialogState();
}

class _AutoPlayDialogState extends State<_AutoPlayDialog> {
  int _selectedRounds = _kRoundOptions.first;
  // 0 = disabled
  int _cashOutAt = 1;

  void _start() {
    Navigator.of(context).pop();
    context.read<GameProvider>().startAutoPlay(
      rounds: _selectedRounds,
      cashOutAt: _cashOutAt > 0 ? _cashOutAt.toDouble() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
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
                  'AUTO PLAY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFE5B4),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),

                // ── Rounds ───────────────────────────────────────────────────
                const Text(
                  'Rounds',
                  style: TextStyle(color: Color(0xFFFFE5B4), fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                Row(
                  children: _kRoundOptions.map((value) {
                    final selected = _selectedRounds == value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: value != _kRoundOptions.last ? 7 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRounds = value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 38,
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF7BA74F) : const Color(0x337BA74F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected ? const Color(0xFFA9FF09) : const Color(0xFF7BA74F),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$value',
                              style: TextStyle(
                                color: selected ? Colors.white : const Color(0xFFFFE5B4),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // ── Stop auto play on ────────────────────────────────────────
                const Text(
                  'Stop auto play on',
                  style: TextStyle(color: Color(0xFFFFE5B4), fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                _CashOutStepper(
                  value: _cashOutAt,
                  onDecrement: _cashOutAt > 0 ? () => setState(() => _cashOutAt--) : null,
                  onIncrement: _cashOutAt < _kCashOutMax ? () => setState(() => _cashOutAt++) : null,
                ),

                const SizedBox(height: 14),
                ImageButton(label: 'Start', height: 50, onPressed: _start),
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
    );
  }
}

class _CashOutStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CashOutStepper({required this.value, required this.onDecrement, required this.onIncrement});

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
            child: Text(
              value == 0 ? '—' : '${value}×',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFE5B4),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 3, color: Colors.black54)],
              ),
            ),
          ),
          _stepBtn(label: '+', onTap: onIncrement),
        ],
      ),
    );
  }
}
