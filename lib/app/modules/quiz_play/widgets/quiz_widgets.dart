import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoiceOptionCard extends StatelessWidget {
  final String optionKey;
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceOptionCard({
    Key? key,
    required this.optionKey,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              optionKey.toUpperCase(),
              style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        title: Text(
          optionText,
          style: TextStyle(color: Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }
}

// --- INPUT FIELD SOAL ESSAY DENGAN DETEKSI STATE STABIL ---
class EssayInputField extends StatefulWidget {
  final int questionId;
  final String initialValue;
  final Function(String) onAnswerChanged;

  const EssayInputField({
    Key? key,
    required this.questionId,
    required this.initialValue,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  State<EssayInputField> createState() => _EssayInputFieldState();
}

class _EssayInputFieldState extends State<EssayInputField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant EssayInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika soal berganti, reset isi text field sesuai history text soal baru tersebut
    if (oldWidget.questionId != widget.questionId) {
      _textController.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: _textController,
        maxLines: 6,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        onChanged: widget.onAnswerChanged,
        decoration: InputDecoration(
          hintText: 'Ketik analisis atau jawaban essay Anda secara mendalam di sini...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// --- MODAL SHEET GRID NOMER NAVIGASI SOAL CEPAT ---
// --- MODAL SHEET GRID NOMER NAVIGASI SOAL CEPAT (VERSI INDIKATOR MERAH) ---
class QuestionGridSheet extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<int, String> userAnswers;
  final List<Map<String, dynamic>> questions;
  final Function(int) onNodeTap;

  const QuestionGridSheet({
    Key? key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.userAnswers,
    required this.questions,
    required this.onNodeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Modal Sheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Navigasi Soal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Pastikan seluruh indikator berwarna biru (terisi)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 18, color: Colors.black54),
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Grid Nomor Soal
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: totalQuestions,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final q = questions[index];
                int qId = q['id'];
                
                bool isAnswered = userAnswers[qId] != null && userAnswers[qId]!.trim().isNotEmpty;
                bool isCurrent = currentIndex == index;

                Color tileColor = const Color(0xFFFFEAEA); 
                Color textColor = const Color.fromARGB(255, 220, 220, 38); 
                Border? tileBorder;

                if (isAnswered) {
                  tileColor = const Color(0xFFE8F1FF); 
                  textColor = const Color(0xFF0056FF); 
                }
                
                if (isCurrent) {
                  tileBorder = Border.all(color: const Color(0xFF0056FF), width: 2.5);
                }

                return GestureDetector(
                  onTap: () {
                    Get.back();
                    onNodeTap(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(14),
                      border: tileBorder,
                      boxShadow: isCurrent 
                          ? [BoxShadow(color: const Color(0xFF0056FF).withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: textColor, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}