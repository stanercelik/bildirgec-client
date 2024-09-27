import 'package:contexto_turkish/controllers/guess_view_controller.dart';
import 'package:contexto_turkish/models/guess.dart';
import 'package:contexto_turkish/views/guess_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowClosestWordsDialog extends StatelessWidget {
  const ShowClosestWordsDialog(
      {Key? key, required this.title, required this.icon})
      : super(key: key);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuessViewController());

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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: controller.fetchClosestWords(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final closestWords = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: closestWords.length,
                          itemBuilder: (context, index) {
                            final guess = Guess(
                              word: closestWords[index]['word'],
                              distance: closestWords[index]['rank'],
                            );
                            return GuessListItem(guess: guess);
                          },
                        ),
                      );
                    } else {
                      return const Center(child: Text('Veri bulunamadı.'));
                    }
                  },
                )
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

void showClosestWordsDialog(BuildContext context, String title, IconData icon) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShowClosestWordsDialog(
        title: title,
        icon: icon,
      );
    },
  );
}
