import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'Pendiente';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        backgroundColor = AppColors.info.withValues(alpha: 0.15);
        textColor = AppColors.info;
        label = 'Aprobado';
        icon = Icons.check_circle_outline;
        break;
      case 'dispatched':
        backgroundColor = AppColors.secondary.withValues(alpha: 0.15);
        textColor = AppColors.secondary;
        label = 'Despachado';
        icon = Icons.local_shipping_outlined;
        break;
      case 'completed':
        backgroundColor = AppColors.primaryLight.withValues(alpha: 0.15);
        textColor = AppColors.primaryDark;
        label = 'Entregado';
        icon = Icons.handshake_outlined;
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        label = 'Cancelado';
        icon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
