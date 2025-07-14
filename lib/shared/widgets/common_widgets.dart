import 'package:flutter/material.dart';
import '../../core/constants/app_styles.dart';

/// Widget para mostrar estados de carga con mensaje personalizado
class LoadingWidget extends StatelessWidget {
  final String message;
  final bool showSpinner;

  const LoadingWidget({
    super.key,
    this.message = 'Cargando...',
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.m),
          ],
          Text(
            message,
            style: AppTypography.bodyMStyle.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar estados de error con opción de reintentar
class ErrorWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Algo salió mal',
              style: AppTypography.headingSStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              style: AppTypography.bodyMStyle.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(actionText ?? 'Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estados vacíos con mensaje e ícono
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              style: AppTypography.headingSStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              style: AppTypography.bodyMStyle.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Comenzar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para botones con carga
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const LoadingButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
