import 'package:flutter/material.dart';
import '../models/guess.dart';

class GuessListItem extends StatelessWidget {
  final Guess guess;
  final bool isLastGuess;

  const GuessListItem({Key? key, required this.guess, this.isLastGuess = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxDistance = 15000;

    // Calculate the fill percentage
    final fillPercentage = (maxDistance - guess.distance) / maxDistance;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xff1E2732), // Dark background for unfilled portion
        borderRadius: BorderRadius.circular(10),
        border: isLastGuess
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Stack(
        children: [
          // Filled portion based on distance
          FractionallySizedBox(
            widthFactor: fillPercentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: guess.distance < 5000
                    ? const Color(0xff00BA7C) // Fill color
                    : guess.distance < 10000
                        ? const Color(0xffEF7D31) // İkinci renk
                        : const Color(0xffF9197F), // Üçüncü renk

                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Text displayed on top

          Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          guess.word,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          guess.distance.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ])))
        ],
      ),
    );
  }
}
