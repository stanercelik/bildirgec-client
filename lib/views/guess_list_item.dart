import 'package:contexto_turkish/controllers/guess_view_controller.dart';
import 'package:contexto_turkish/utils/show_how_to_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/guess.dart';

class GuessListItem extends StatelessWidget {
  final Guess guess;
  final bool isLastGuess;

  const GuessListItem({Key? key, required this.guess, this.isLastGuess = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuessViewController());
    double fillPercentage;

    if (guess.distance == 1) {
      fillPercentage = 1.0;
    } else if (guess.distance <= 5000) {
      fillPercentage = (5000 - guess.distance) / 5000;
    } else {
      fillPercentage = 0.05;
    }

    return GestureDetector(
      onTap: () async {
        List<String> meanings =
            (await controller.getWordMeaning(guess.word)).cast<String>();

        String combinedMeanings = meanings.join(",\n\n");

        showHowToDialog(
            context, guess.word, combinedMeanings, Icons.abc_rounded);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xff1E2732),
          borderRadius: BorderRadius.circular(10),
          border: isLastGuess
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: fillPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: guess.distance < 1000
                      ? const Color(0xff00BA7C)
                      : guess.distance < 2500
                          ? const Color(0xffEF7D31)
                          : const Color(0xffF9197F),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
      ),
    );
  }
}
