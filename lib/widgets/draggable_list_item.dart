import 'package:flutter/material.dart';
import '../utils/haptic_feedback_util.dart';

/// Draggable элемент списка для переупорядочивания
class DraggableListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Function(int oldIndex, int newIndex) onReorder;
  final bool enabled;

  const DraggableListItem({
    super.key,
    required this.child,
    required this.index,
    required this.onReorder,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: () {
        HapticFeedbackUtil.mediumImpact();
      },
      onDragEnd: (details) {
        HapticFeedbackUtil.lightImpact();
      },
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          final draggedIndex = details.data;
          if (draggedIndex != index) {
            HapticFeedbackUtil.success();
            onReorder(draggedIndex, index);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: candidateData.isNotEmpty
                  ? Border.all(
                      color: Colors.blue,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
