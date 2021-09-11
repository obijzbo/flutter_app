import 'package:flutter/material.dart';

// Builds the heads-up display for this game.
class HUD extends StatelessWidget {
  // This function will be called when pause button is pressed.
  final Function onPausePressed;

  const HUD({
    Key? key,
    required this.onPausePressed,
  })  : assert(onPausePressed != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.pause,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () {
            onPausePressed.call();
          },
        ),
      ],
    );
  }
}