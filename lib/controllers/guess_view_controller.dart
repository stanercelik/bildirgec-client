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
  var resultMessage = ''.obs;

  void prepareResultMessage(bool gaveUp) {
    String status = gaveUp
        ? 'Bildirgec oynadım ama ${guesses.length} tahminden sonra pes ettim!'
        : 'Bildirgec oynadım ve ${guesses.length}. tahminde doğru kelimeyi bulabildim!';

    // Tahminlerin sınırlarına göre gruplandırılması
    int greenGuesses = guesses.where((guess) => guess.distance <= 1000).length;
    int orangeGuesses = guesses
        .where((guess) => guess.distance <= 2500 && guess.distance > 1000)
        .length;
    int redGuesses = guesses.where((guess) => guess.distance > 2500).length;

    // Maksimum 6 emoji olacak şekilde oranlara göre emoji sayısını belirliyoruz
    int totalGuesses = greenGuesses + orangeGuesses + redGuesses;

    int maxEmojis = 6;
    int greenEmojiCount = (maxEmojis * greenGuesses / totalGuesses).round();
    int orangeEmojiCount = (maxEmojis * orangeGuesses / totalGuesses).round();
    int redEmojiCount = (maxEmojis * redGuesses / totalGuesses).round();

    // Emojilerin gösterimi
    String greenEmojis = '🟩' * greenEmojiCount;
    String orangeEmojis = '🟧' * orangeEmojiCount;
    String redEmojis = '🟥' * redEmojiCount;

    // Tahmin sayılarını alt alta gösterecek şekilde düzenliyoruz
    resultMessage.value = "$status\n\n"
        "$greenEmojis $greenGuesses\n"
        "$orangeEmojis $orangeGuesses\n"
        "$redEmojis $redGuesses";
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
      // API'ye istek gönderme
      final response = await http.post(
        Uri.parse('${APIConstant.apiDomain}/similarity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'word': guessedWord}),
      );

      // Eğer istek başarılıysa
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // `rank` değeri null değilse ve int tipindeyse
        final rank = responseData['rank'];
        if (rank != null && rank is int) {
          // Hata mesajını temizle
          errorMessage.value = '';

          // Yeni tahmini listeye ekle
          final guess = Guess(word: guessedWord, distance: rank);
          guesses.add(guess);
          lastGuess.value = guess;

          // Tahminleri `rank` değerine göre sırala
          guesses.sort((a, b) => a.distance.compareTo(b.distance));

          // Eğer rank 1 ise (doğru tahmin), anlamlarını göster
          if (rank == 1) {
            isGameOver.value = true; // Oyun bitti olarak işaretle
            prepareResultMessage(false); // Doğru tahminle oyun bitti

            List<String> meanings =
                (await getWordMeaning(guessedWord)).cast<String>();

            // Anlamları birleştir ve string'e dönüştür
            String combinedMeanings = meanings.join(', ');

            showHowToDialog(
                context, guessedWord, combinedMeanings, Icons.abc_outlined);
          }

          // Tahmin text alanını temizle
          guessText.value = '';
        } else {
          print('Error: Rank is null or not an integer');
        }
      } else if (response.statusCode == 400) {
        // Kelime bulunamadı hatası durumunda kullanıcıya mesaj göster
        errorMessage.value = 'Bu kelime bulunamadı, başka bir kelime deneyin!';
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      errorMessage.value = 'Bir hata oluştu, lütfen tekrar deneyin.';
    }
  }

  // Pes etme fonksiyonu, gizli kelimeyi gösterir
  Future<void> giveUp() async {
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
        isGameOver.value = true;
        prepareResultMessage(true);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  // Kelimenin anlamını getiren fonksiyon
  Future<List> getWordMeaning(String word) async {
    try {
      // Kelimenin anlamını almak için API'ye istek gönder
      final response = await http.get(
        Uri.parse('${APIConstant.apiDomain}/meaning?word=$word'),
        headers: {'Content-Type': 'application/json'},
      );

      // Eğer istek başarılıysa anlamlarını döndür
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

  void copyResult() {
    Clipboard.setData(ClipboardData(text: resultMessage.value));
    Get.snackbar('Başarılı', 'Sonuç kopyalandı!',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.greenAccent);
  }
}
