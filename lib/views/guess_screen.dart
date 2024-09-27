import 'package:contexto_turkish/utils/show_closest_words.dart';
import 'package:contexto_turkish/utils/show_how_to_dialog.dart';
import 'package:contexto_turkish/views/guess_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/guess_view_controller.dart';

class GuessScreen extends StatelessWidget {
  const GuessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuessViewController());

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff15202B),
      appBar: AppBar(
        title: const Text(
          'BİLDİRGEÇ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xff263340),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) {
              switch (value) {
                case 'howToPlay':
                  showHowToDialog(
                      context,
                      "Nasıl Oynanır",
                      "Gizli kelimeyi bulun. Sınırsız tahmin hakkınız var.\n\nTahmin ettiğiniz kelimeler, gizli kelimeye ne kadar benzediğine göre bir yapay zeka algoritması tarafından sıralanır.\n\nBir kelimeyi tahmin ettikten sonra, onun sırasını göreceksiniz. Gizli kelime 1. sırada, gizli kelimeye en uzak kelime ise 15000. sıradadır.\n\nAlgoritma binlerce metni analiz etti. Kelimeler arasındaki benzerliği hesaplamak için kelimelerin hangi bağlamda kullanıldığını dikkate alır.",
                      Icons.question_mark_rounded);
                  break;
                case 'howItWork':
                  showHowToDialog(
                      context,
                      "Sıralama nasıl belirlenir?",
                      'Oyun, günün kelimesiyle ilişkili olarak kelimelerin benzerliğini hesaplamak için yapay zeka algoritması ve binlerce metin kullanır. Bu benzerlik mutlaka kelimelerin anlamıyla ilgili olmayıp, kelimelerin internette hangi yakınlıkta kullanıldığıyla ilgilidir.\n\nÖrneğin, eğer günün kelimesi "sonsuz" olsaydı, "sonsuz" kelimesi genellikle "aşk" veya "evren" gibi iki farklı bağlamda kullanıldığı için "aşk" ile ilgili kelimeler ya da "evren" ile ilgili kelimeler günün kelimesine yakın olabilir. Benzer bir mantıkla, örneğin "tv" ve "televizyon" çok farklı pozisyonlarda bulunuyorsa, bu onların aynı nesne olmalarına rağmen günün kelimesiyle ilişkili olarak farklı şekillerde kullanıldığı anlamına gelir.',
                      Icons.question_answer_rounded);
                  break;
                case 'giveUp':
                  if (!controller.isGameOver.value) {
                    controller.giveUp(context);
                  }
                  break;
                case 'hint':
                  if (!controller.isHintsFinished.value &&
                      !controller.isGameOver.value) {
                    controller.getHint();
                  }
                  break;
                case 'settings':
                  print("settings");
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'howToPlay',
                  child: Row(
                    children: [
                      Icon(Icons.question_mark_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Nasıl Oynanır',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'howItWork',
                  child: Row(
                    children: [
                      Icon(Icons.question_answer_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Algoritma Mantığı',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  enabled: !controller.isHintsFinished.value &&
                      !controller.isGameOver.value,
                  value: 'hint',
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('İpucu Al',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  enabled: !controller.isGameOver.value,
                  value: 'giveUp',
                  child: const Row(
                    children: [
                      Icon(Icons.flag_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Pes Et',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Ayarlar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        backgroundColor: const Color(0xff15202B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Guess TextField
              TextField(
                cursorColor: Colors.white,
                onChanged: (value) {
                  controller.guessText.value = value;
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tahmininizi Girin',
                  hintStyle: TextStyle(
                    color: Color(0xff757575),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xff263340),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Obx(
                () => controller.isGameOver.value
                    ? Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff1E2732),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Sonuç mesajı
                              Obx(() {
                                final status = controller.statusMessage.value;
                                final emoji = controller.emojiMessage.value;

                                if (status.isNotEmpty && emoji.isNotEmpty) {
                                  return Column(
                                    children: [
                                      Text(
                                        status,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        emoji,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff1C9BEF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.copyResult;
                                  },
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Sonucu Kopyala",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff1C9BEF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    showClosestWordsDialog(context,
                                        "En yakın kelimeler", Icons.book);
                                  },
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "En Yakın 500 Kelime",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // Varsayılan yazı boyutu
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Hata mesajını göstermek için Obx kullanıyoruz
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : const SizedBox.shrink()),

              SizedBox(height: screenHeight * 0.02),

              // Guess Button
              Obx(
                () => controller.isGameOver.value
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.06,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1C9BEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            controller.submitGuess(context);
                            controller.guessText.value = '';
                          },
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Tahmin Gönder',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GetX<GuessViewController>(
                builder: (controller) {
                  return controller.guesses.isNotEmpty
                      ? GuessListItem(
                          guess: controller.lastGuess.value,
                          isLastGuess: true,
                        )
                      : const SizedBox.shrink();
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.guesses.length,
                    itemBuilder: (context, index) {
                      final guess = controller.guesses[index];
                      return GuessListItem(guess: guess);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
