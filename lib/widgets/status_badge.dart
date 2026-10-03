import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class StatusBadge extends StatelessWidget {
  final ItemType? itemType;
  final ClaimStatus? claimStatus;
  final bool isResolved;

  const StatusBadge.item({
    super.key,
    required this.itemType,
    this.isResolved = false,
  }) : claimStatus = null;

  const StatusBadge.claim({
    super.key,
    required this.claimStatus,
  })  : itemType = null,
        isResolved = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String label = '';
    Color bg = scheme.surfaceContainerHighest;
    Color fg = scheme.onSurfaceVariant;
    IconData icon = Icons.info_outline;

    if (isResolved) {
      label = 'Возвращено';
      bg = scheme.tertiaryContainer;
      fg = scheme.onTertiaryContainer;
      icon = Icons.check_circle_outline;
    } else if (itemType == ItemType.found) {
      label = 'Найдено';
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      icon = Icons.search;
    } else if (itemType == ItemType.lost) {
      label = 'Потеряно';
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
      icon = Icons.priority_high;
    } else if (claimStatus == ClaimStatus.accepted) {
      label = 'Одобрено';
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      icon = Icons.verified_outlined;
    } else if (claimStatus == ClaimStatus.pending) {
      label = 'На рассмотрении';
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
      icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}