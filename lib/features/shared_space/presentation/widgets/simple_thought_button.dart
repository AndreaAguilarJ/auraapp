import 'package:flutter/material.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../core/constants/app_styles.dart';

/// Botón simplificado para enviar pulsos de pensamiento
class SimpleThoughtButton extends StatefulWidget {
  final MoodCompassProvider provider;
  final VoidCallback? onPressed;

  const SimpleThoughtButton({
    Key? key,
    required this.provider,
    this.onPressed,
  }) : super(key: key);

  @override
  State<SimpleThoughtButton> createState() => _SimpleThoughtButtonState();
}

class _SimpleThoughtButtonState extends State<SimpleThoughtButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.provider.canSendPulse && !widget.provider.isLoading;
    
    return GestureDetector(
      onTapDown: canSend ? (_) => _animationController.forward() : null,
      onTapUp: canSend ? (_) => _animationController.reverse() : null,
      onTapCancel: () => _animationController.reverse(),
      onTap: canSend ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: canSend
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryViolet,
                          AppColors.primaryRose,
                        ],
                      )
                    : null,
                color: canSend ? null : AppColors.textSecondary,
                boxShadow: canSend
                    ? [
                        BoxShadow(
                          color: AppColors.primaryViolet.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.provider.isLoading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Icon(
                      Icons.favorite,
                      size: 50,
                      color: Colors.white,
                    ),
                  if (!canSend && !widget.provider.isLoading) ...[
                    Positioned(
                      bottom: 20,
                      child: _buildCooldownIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCooldownIndicator() {
    final cooldown = widget.provider.cooldownRemaining;
    
    if (cooldown == null) {
      return Text(
        '${widget.provider.dailyPulseCount}/10',
        style: AppTypography.bodySStyle.copyWith(
          color: Colors.white70,
          fontSize: 10,
        ),
      );
    }
    
    final minutes = cooldown.inMinutes;
    final seconds = cooldown.inSeconds % 60;
    
    return Text(
      '${minutes}:${seconds.toString().padLeft(2, '0')}',
      style: AppTypography.bodySStyle.copyWith(
        color: Colors.white70,
        fontSize: 10,
      ),
    );
  }
}
