import 'package:flutter/material.dart';
import '../utils/haptic_feedback_util.dart';

/// Swipeable элемент списка с действиями
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final Widget? leftAction;
  final Widget? rightAction;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final String? leftActionLabel;
  final String? rightActionLabel;
  final Color? leftActionColor;
  final Color? rightActionColor;
  final IconData? leftActionIcon;
  final IconData? rightActionIcon;
  final bool confirmDismiss;
  final String? confirmMessage;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.leftAction,
    this.rightAction,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionLabel,
    this.rightActionLabel,
    this.leftActionColor,
    this.rightActionColor,
    this.leftActionIcon,
    this.rightActionIcon,
    this.confirmDismiss = false,
    this.confirmMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? ValueKey(UniqueKey()),
      background: _buildActionBackground(
        context,
        isLeft: true,
      ),
      secondaryBackground: _buildActionBackground(
        context,
        isLeft: false,
      ),
      confirmDismiss: confirmDismiss
          ? (direction) => _confirmDismiss(context, direction)
          : null,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && onSwipeRight != null) {
          HapticFeedbackUtil.success();
          onSwipeRight!();
        } else if (direction == DismissDirection.endToStart &&
            onSwipeLeft != null) {
          HapticFeedbackUtil.success();
          onSwipeLeft!();
        }
      },
      child: child,
    );
  }

  Widget _buildActionBackground(BuildContext context, {required bool isLeft}) {
    final action = isLeft ? rightAction : leftAction;
    final label = isLeft ? rightActionLabel : leftActionLabel;
    final color = isLeft ? rightActionColor : leftActionColor;
    final icon = isLeft ? rightActionIcon : leftActionIcon;

    if (action != null) {
      return action;
    }

    return Container(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 20,
        right: isLeft ? 20 : 0,
      ),
      decoration: BoxDecoration(
        color: color ?? (isLeft ? Colors.redAccent : Colors.green),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment:
            isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 28),
            if (label != null) const SizedBox(width: 8),
          ],
          if (label != null && label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (confirmMessage == null) return true;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text(confirmMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}
