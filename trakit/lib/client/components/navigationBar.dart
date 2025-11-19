import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/bottom_button.dart';

class NavigationbarE extends StatelessWidget {
  final bool hasFloatingButton;
  NavigationbarE({super.key, this.hasFloatingButton = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        
        child: Row(
          mainAxisAlignment: hasFloatingButton ? MainAxisAlignment.spaceAround : MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedPadding(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(right: hasFloatingButton ? 20 : 0),
              child: BottomButton(
                icon: Icons.dashboard,
                label: 'Dashboard',
                onTap: () {
                  context.pushNamed('dashboard');
                },
              ),
            ),
            SizedBox(width: hasFloatingButton ? 48: 0), // Space for FAB notch
            AnimatedPadding(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(left: hasFloatingButton ? 20 : 0),
              child: BottomButton(
                icon: Icons.people,
                label: 'Usuario',
                onTap: () {},
              ),
            ),
          ],
        ),
      );
  }
}