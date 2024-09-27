import 'dart:async';
import 'package:contexto_turkish/constants/api_constant.dart';
import 'package:contexto_turkish/utils/show_how_to_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/guess.dart';

class GuessViewController extends GetxController {
  var guesses = <Guess>[].obs;
  var guessText = ''.obs;
  var lastGuess = Guess(word: '', distance: 0).obs;
  var errorMessage = ''.obs;
  var isGameOver = false.obs;
  var statusMessage = ''.obs;
  var emojiMessage = ''.obs;
  var resultMessage = ''.obs;
  var hintRank = 300.obs;
  var hintWord = ''.obs;
  var isHintsFinished = false.obs;
  var hintCount = 0.obs;
  var guessCount = 0.obs;

  void prepareResultStatus(bool gaveUp) {
    String status = gaveUp
        ? 'Bildirgec oynadım ama ${guessCount.value} tahmin ve $hintCount ipucundan sonra pes ettim!'
        : 'Bildirgec oynadım ve $hintCount ipucundan sonra ${guessCount.value}. tahminde doğru kelimeyi bulabildim!';

    statusMessage.value = status;
  }

  void prepareResultEmoji() {
    int greenGuesses = guesses.where((guess) => guess.distance <= 1000).length;
    int orangeGuesses = guesses
        .where((guess) => guess.distance <= 2500 && guess.distance > 1000)
        .length;
    int redGuesses = guesses.where((guess) => guess.distance > 2500).length;

    int totalGuesses = greenGuesses + orangeGuesses + redGuesses;

    int maxEmojis = 5;
    int greenEmojiCount = (maxEmojis * greenGuesses / totalGuesses).round();
    int orangeEmojiCount = (maxEmojis * orangeGuesses / totalGuesses).round();
    int redEmojiCount = (maxEmojis * redGuesses / totalGuesses).round();

    String greenEmojis = '🟩' * greenEmojiCount;
    String orangeEmojis = '🟧' * orangeEmojiCount;
    String redEmojis = '🟥' * redEmojiCount;

    emojiMessage.value = "$greenEmojis $greenGuesses\n"
        "$orangeEmojis $orangeGuesses\n"
        "$redEmojis $redGuesses";
  }

  void prepareResultMessages(bool gaveUp) {
    prepareResultStatus(gaveUp);
    prepareResultEmoji();
  }

  // Tahmin gönderme fonksiyonu
  Future<void> submitGuess(BuildContext context) async {
    final guessedWord = guessText.value.trim();

    // Eğer tahmin boşsa işlemi sonlandır
    if (guessedWord.isEmpty) {
      errorMessage.value = 'Bir kelime girmelisiniz!';
      return;
    }

    // Kelimenin zaten listede olup olmadığını kontrol et
    if (guesses.any((guess) => guess.word == guessedWord)) {
      errorMessage.value = 'Bu kelime zaten listede mevcut!';
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${APIConstant.apiDomain}/similarity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'word': guessedWord}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final rank = responseData['rank'];
        if (rank != null && rank is int) {
          errorMessage.value = '';

          final guess = Guess(word: guessedWord, distance: rank);
          guesses.add(guess);
          lastGuess.value = guess;
          guessCount++;

          guesses.sort((a, b) => a.distance.compareTo(b.distance));

          if (rank == 1) {
            isGameOver.value = true;
            prepareResultMessages(false);

            List<String> meanings =
                (await getWordMeaning(guessedWord)).cast<String>();

            String combinedMeanings = meanings.join(', ');

            showHowToDialog(
                context, guessedWord, combinedMeanings, Icons.abc_rounded);
          }

          guessText.value = '';
        } else {
          print('Error: Rank is null or not an integer');
        }
      } else if (response.statusCode == 400) {
        errorMessage.value = 'Bu kelime bulunamadı, başka bir kelime deneyin!';
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      errorMessage.value = 'Bir hata oluştu, lütfen tekrar deneyin.';
    }
  }

  Future<void> giveUp(BuildContext context) async {
    try {
      // API'den gizli kelimeyi al
      final response = await http.get(
        Uri.parse('${APIConstant.apiDomain}/reveal'),
        headers: {'Content-Type': 'application/json'},
      );

      // Eğer istek başarılıysa
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final hiddenWord = responseData['hidden_word'];

        // Gizli kelimeyi rank 1 ile tahmin olarak ekle
        final guess = Guess(word: hiddenWord, distance: 1);
        guesses.add(guess);
        lastGuess.value = guess;

        guesses.sort((a, b) => a.distance.compareTo(b.distance));

        List<String> meanings =
            (await getWordMeaning(hiddenWord)).cast<String>();
        String combinedMeanings = meanings.join(', ');

        showHowToDialog(
            context, hiddenWord, combinedMeanings, Icons.abc_rounded);

        isGameOver.value = true;
        prepareResultMessages(true);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<List> getWordMeaning(String word) async {
    try {
      // Kelimenin anlamını almak için API'ye istek gönder
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
    } catch (e) {
      print('Exception caught: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClosestWords() async {
    final response =
        await http.get(Uri.parse('${APIConstant.apiDomain}/closest-words'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
          data['closest_words'].map((wordData) => {
                'word': wordData['word'],
                'rank': (wordData['rank']).toInt(),
              }));
    } else {
      throw Exception('Failed to load closest words');
    }
  }

  Future<void> getHint() async {
    try {
      // Eğer hintRank 2'den küçükse ipucu verme işlemini durdur
      if (hintRank.value < 2) {
        isHintsFinished.value = true;
        return;
      }

      final response = await http.get(
        Uri.parse('${APIConstant.apiDomain}/hint?rank=${hintRank.value}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        hintWord.value = responseData['hint_word'];

        hintCount++;

        var hintGuess = Guess(word: hintWord.value, distance: hintRank.value);
        guesses.add(hintGuess);
        lastGuess.value = hintGuess;

        guesses.sort((a, b) => a.distance.compareTo(b.distance));
        guessText.value = '';
        hintRank.value = (hintRank.value / 2).floor();
      } else {
        print('Error fetching hint: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  void copyResult() async {
    resultMessage.value = "${statusMessage.value}\n\n${emojiMessage.value}";
    await Clipboard.setData(ClipboardData(text: resultMessage.value));

    Get.snackbar(
      'Başarılı',
      'Sonuç kopyalandı!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.greenAccent,
    );
  }
}
