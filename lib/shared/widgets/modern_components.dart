import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Campo de texto moderno con diseño consistente
class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;  // added
  final bool isPassword;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const ModernTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,  // added
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _labelColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _obscureText = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _obscureText = widget.isPassword;

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize color animations when context is available
    _borderColorAnimation = ColorTween(
      begin: Colors.grey.withAlpha((0.3 * 255).toInt()),
      end: Theme.of(context).colorScheme.primary,
    ).animate(_focusController);

    _labelColorAnimation = ColorTween(
      begin: Colors.grey.withAlpha((0.7 * 255).toInt()),
      end: Theme.of(context).colorScheme.primary,
    ).animate(_focusController);
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: _hasFocus || widget.controller.text.isNotEmpty ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: _labelColorAnimation.value,
                ),
              ),
            ),

            // Campo de texto
            Container(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? Theme.of(context).colorScheme.surface
                    : Colors.grey.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _borderColorAnimation.value ?? Colors.grey.withAlpha((0.3 * 255).toInt()),
                  width: _hasFocus ? 2 : 1,
                ),
                boxShadow: _hasFocus ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                obscureText: _obscureText,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasFocus
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withAlpha((0.6 * 255).toInt()),
                        )
                      : null,
                  suffixIcon: _buildSuffixIcon(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  counterText: '', // Ocultar contador por defecto
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.enabled
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        onPressed: _togglePasswordVisibility,
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _hasFocus
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withAlpha((0.6 * 255).toInt()),
        ),
      );
    } else if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixTap,
        icon: Icon(
          widget.suffixIcon,
          color: _hasFocus
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withAlpha((0.6 * 255).toInt()),
        ),
      );
    }
    return null;
  }
}

/// Botón moderno con diseño consistente
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final double? width;
  final double height;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width,
    this.height = 48,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_pressController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? Theme.of(context).intimacyGradient
                    : null,
                color: widget.isPrimary
                    ? null
                    : widget.onPressed != null
                        ? Theme.of(context).colorScheme.surface
                        : Colors.grey.withAlpha((0.3 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
                border: !widget.isPrimary
                    ? Border.all(
                        color: Theme.of(context).colorScheme.outline.withAlpha((0.3 * 255).toInt()),
                      )
                    : null,
                boxShadow: widget.isPrimary && widget.onPressed != null ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ] else ...[
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isPrimary
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.isPrimary
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
