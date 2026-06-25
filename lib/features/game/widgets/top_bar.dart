import 'package:flutter/material.dart';

import 'top_bar_button.dart';

class TopBar extends StatelessWidget {
  final int balance;

  const TopBar({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final balanceWidth = totalWidth / 3;
          final buttonsWidth = totalWidth * 2 / 3;

          return Row(
            children: [
              SizedBox(
                width: balanceWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/balance.png', width: balanceWidth, height: 44, fit: BoxFit.contain),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13, bottom: 3),
                        child: Image.asset('assets/coin.png', width: 28, height: 28),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 3),
                      child: Text(
                        '$balance',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: buttonsWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TopBarButton(asset: 'assets/shop.png', tooltip: 'Shop', onPressed: () {}),
                    TopBarButton(asset: 'assets/withdraw.png', tooltip: 'Ball', onPressed: () {}),
                    TopBarButton(
                      asset: 'assets/wheel.png',
                      tooltip: 'Wheel',
                      onPressed: () => Navigator.pushNamed(context, '/wheel'),
                    ),
                    TopBarButton(
                      asset: 'assets/settings.png',
                      tooltip: 'Settings',
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
