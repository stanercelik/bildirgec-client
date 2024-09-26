import 'dart:async';
import 'package:contexto_turkish/constants/api_constant.dart';
import 'package:contexto_turkish/utils/show_how_to_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/guess.dart';

class GuessViewController extends GetxController {
  var guesses = <Guess>[].obs;
  var guessText = ''.obs;
  var lastGuess = Guess(word: '', distance: 0).obs;

  Future<void> submitGuess(BuildContext context) async {
    final guessedWord = guessText.value.trim();

    if (guessedWord.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse('${APIConstant.apiDomain}/similarity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'word': guessedWord}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final distance = responseData['distance'] as int;

      final guess = Guess(word: guessedWord, distance: distance);

      guesses.add(guess);
      lastGuess.value = guess;
      guesses.sort((a, b) => a.distance.compareTo(b.distance));

      if (distance == 1) {
        List<String> meanings =
            (await getWordMeaning(guessedWord)).cast<String>();
        showHowToDialog(
            context, guessedWord, meanings.toString(), Icons.abc_outlined);
      }

      guessText.value = '';
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> giveUp() async {
    final response = await http.get(
      Uri.parse('${APIConstant.apiDomain}/reveal'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final hiddenWord = responseData['hidden_word'];

      // Create a Guess object with distance 1 (since it's the hidden word)
      final guess = Guess(word: hiddenWord, distance: 1);

      guesses.add(guess);
      lastGuess.value = guess;
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<List> getWordMeaning(String word) async {
    final response = await http.get(
      Uri.parse('${APIConstant.apiDomain}/meaning?word=$word'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final meanings = responseData['meanings'] as List;
      return meanings;
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      return [];
    }
  }

  // Show meaning in an alert dialog
  void _showMeaningDialog(
      BuildContext context, String word, List<String> meanings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('"$word anlamı:"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: meanings.map((meaning) => Text(meaning)).toList(),
          ),
          actions: [
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
