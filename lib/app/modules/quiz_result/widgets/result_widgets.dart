import 'package:flutter/material.dart';

class ScoreSummaryHeader extends StatelessWidget {
  final int score;
  final int xp;
  final int mastery;
  final String time;

  const ScoreSummaryHeader({
    Key? key,
    required this.score,
    required this.xp,
    required this.mastery,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60E8), Color(0xFF0A349E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0A349E).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          const Text('TOTAL SKOR KAMU', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 10),
          Container(
            width: 100, height: 100,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Center(
              child: Text('$score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadgeItem(Icons.bolt, '+$xp XP', 'Reward Poin', const Color(0xFFA5E08B)),
              _buildBadgeItem(Icons.workspace_premium_rounded, '+$mastery%', 'Mastery Naik', const Color(0xFFFFD700)),
              _buildBadgeItem(Icons.speed_rounded, time, 'Durasi Kerja', const Color(0xFF8CE8FF)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String value, String label, Color accentColor) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}

class QuestionReviewCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const QuestionReviewCard({Key? key, required this.result}) : super(key: key);

  // Helper pencari teks lengkap pilihan ganda
  String _getCompleteAnswerText(String? key, List? options) {
    if (key == null || key.trim().isEmpty) return '(Tidak diisi)';
    if (options == null || options.isEmpty) return key; // Jika essay, langsung kembalikan teks jawaban mentah

    final match = options.firstWhere(
      (opt) => opt['key'].toString().toLowerCase() == key.trim().toLowerCase(),
      orElse: () => null,
    );

    if (match != null) {
      return '${match['key']}. ${match['text']}';
    }
    
    return key; 
  }

  @override
  Widget build(BuildContext context) {
    bool isCorrect = result['is_correct'] ?? false;
    String qType = result['question_type'] ?? 'multiple_choice';
    List? optionsList = result['options']; 
    
    Color statusColor = isCorrect ? Colors.green.shade600 : Colors.red.shade600;
    Color statusBg = isCorrect ? Colors.green.shade50 : Colors.red.shade50;

    bool isEssay = qType.toLowerCase() == 'essay';

    // Ambil teks display jawaban kamu
    String displayUserAnswer = _getCompleteAnswerText(result['user_answer'], optionsList);
    String displayCorrectAnswer = _getCompleteAnswerText(result['correct_answer'], optionsList);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar Kategori Status Atas Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: statusBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SOAL NO. ${result['order'] ?? '-'} (${isEssay ? 'ESSAY' : 'PG'})',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
                Row(
                  children: [
                    Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Benar (+${result['score']})' : 'Salah',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teks Pertanyaan Utama
                Text(
                  result['question_text'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 18),
                
                // Blok Jawaban Siswa
                _buildAnswerBlock(
                  label: 'Jawaban Kamu:', 
                  value: displayUserAnswer, 
                  color: isCorrect ? Colors.green.shade700 : Colors.red.shade700
                ),
                
                if (!isCorrect && !isEssay) ...[
                  const SizedBox(height: 12),
                  _buildAnswerBlock(
                    label: 'Kunci Jawaban yang Benar:', 
                    value: displayCorrectAnswer, 
                    color: Colors.green.shade700
                  ),
                ],

                if (result['feedback'] != null && result['feedback'].toString().isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF), 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD0E0FF), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0056FF), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analisis Koreksi AI:', 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0056FF))
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result['feedback'].toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.5),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnswerBlock({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, height: 1.4),
          ),
        ),
      ],
    );
  }
}