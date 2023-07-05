import 'package:flutter/material.dart';

typedef OptionButtonCallback = void Function(int index);

class OptionButton extends StatelessWidget {
  const OptionButton({
    required this.index,
    required this.title,
    required this.iconPath,
    required this.callback,
    Key? key,
  }) : super(key: key);

  final int index;
  final String title;
  final String iconPath;
  final OptionButtonCallback callback;

  final double containerSize = 60;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                callback(index);
              },
              child: Image.asset(iconPath),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(0),
                backgroundColor: Colors.white, // <-- Button color
              ),
            ),
            width: containerSize,
            height: containerSize,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(title),
        ],
      ),
    );
  }
}
