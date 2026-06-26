import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/concept_map/controllers/concept_map_controller.dart';
import 'package:quizzin/app/modules/concept_map/widgets/concept_map_widgets.dart';

class ConceptMapView extends GetView<ConceptMapController> {
  const ConceptMapView({Key? key}) : super(key: key);

  IconData _getModuleIcon(String? iconType) {
    switch (iconType?.toLowerCase()) {
      case 'atom': return Icons.blur_on_rounded;
      case 'diagram': return Icons.schema_outlined;
      case 'function': return Icons.functions_rounded;
      case 'cycle': return Icons.autorenew_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      default: return Icons.bubble_chart_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);
    const canvasSize = 650.0; 
    const centerPoint = canvasSize / 2; 
    const radialRadius = 200.0; 

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          children: [
            const Text('CONCEPT MAP EXPLORER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text(
              controller.chapterTitle.value, 
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final modulesList = controller.modules;
        final int totalNodes = modulesList.length;

        return SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 20, 32, 10),
                child: Text(
                  'Gunakan dua jari untuk memperbesar (zoom) atau geser untuk menjelajahi peta keterkaitan konsep materi dari AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
              ),
              
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: InteractiveViewer(
                      constrained: false, 
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.4,
                      maxScale: 2.0,
                      child: SizedBox(
                        width: canvasSize,
                        height: canvasSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            
                            // LAYER 1: Garis Penghubung Dinamis (Dari folder widgets)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DynamicMindMapLinesPainter(
                                  nodeCount: totalNodes,
                                  canvasCenter: centerPoint,
                                  radius: radialRadius,
                                ),
                              ),
                            ),
                            
                            Positioned(
                              left: centerPoint - 80, 
                              top: centerPoint - 65,  
                              child: CoreNodeCard(
                                title: controller.coreConcept['title'] ?? controller.chapterTitle.value,
                                label: controller.coreConcept['label'] ?? 'Core Concept',
                              ),
                            ),
                            
                            ...List.generate(totalNodes, (index) {
                              final currentModule = modulesList[index];
                              double angle = (2 * math.pi * index) / totalNodes;
                              
                              double nodeX = centerPoint + radialRadius * math.cos(angle);
                              double nodeY = centerPoint + radialRadius * math.sin(angle);

                              return Positioned(
                                left: nodeX - 65, 
                                top: nodeY - 65,  
                                child: SubNodeCard(
                                  title: currentModule['title'] ?? 'Untitled Module',
                                  moduleNum: 'Module ${currentModule['module_number'] ?? ''}',
                                  icon: _getModuleIcon(currentModule['icon_type']),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.continueToQuiz(),
                    icon: const Text('Lanjut Pilih Tingkat Kesulitan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 2,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}