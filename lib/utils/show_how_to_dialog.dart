import 'package:flutter/material.dart';

class ShowHowToDialog extends StatelessWidget {
  const ShowHowToDialog(
      {Key? key,
      required this.title,
      required this.content,
      required this.icon})
      : super(key: key);

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff263340),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight < 500
                            ? constraints.maxHeight
                            : 500,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Material(
              shape: const CircleBorder(side: BorderSide(color: Colors.white)),
              color: const Color(0xff263340),
              child: IconButton(
                enableFeedback: false,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showHowToDialog(
    BuildContext context, String title, String content, IconData icon) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShowHowToDialog(
        title: title,
        content: content,
        icon: icon,
      );
    },
  );
}
