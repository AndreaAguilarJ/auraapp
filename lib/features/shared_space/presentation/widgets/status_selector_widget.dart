import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/models/user_status.dart';

/// Widget para seleccionar el estado del usuario
class StatusSelectorWidget extends StatefulWidget {
  final UserStatus? currentStatus;
  final Function(UserStatus) onStatusChanged;

  const StatusSelectorWidget({
    Key? key,
    this.currentStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<StatusSelectorWidget> createState() => _StatusSelectorWidgetState();
}

class _StatusSelectorWidgetState extends State<StatusSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  void _selectStatus(UserStatus status) {
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });

    widget.onStatusChanged(status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                theme,
                UserStatus.available,
                Icons.check_circle_outline,
                'Disponible',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusOption(
                theme,
                UserStatus.busy,
                Icons.work_outline,
                'Ocupado',
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption(
                theme,
                UserStatus.resting,
                Icons.bedtime_outlined,
                'Descansando',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusOption(
                theme,
                UserStatus.traveling,
                Icons.flight_outlined,
                'Viajando',
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(
    ThemeData theme,
    UserStatus status,
    IconData icon,
    String label,
    Color color,
  ) {
    final isSelected = widget.currentStatus == status;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _selectStatus(status),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(0x1F)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? color
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withAlpha(0x33),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? color : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
