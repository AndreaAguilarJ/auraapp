import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';

/// Widget para ingresar notas contextuales opcionales
class ContextNoteWidget extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final String? hint;

  const ContextNoteWidget({
    Key? key,
    required this.controller,
    this.maxLength = 140,
    this.hint,
  }) : super(key: key);

  @override
  State<ContextNoteWidget> createState() => _ContextNoteWidgetState();
}

class _ContextNoteWidgetState extends State<ContextNoteWidget>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _focusController;
  late Animation<double> _expandAnimation;
  late Animation<Color?> _borderAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  bool _showCharacterCount = false;
  bool _hasInitializedAnimations = false;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 56.0, end: 120.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Mover la inicialización que depende del context aquí
    if (!_hasInitializedAnimations) {
      _borderAnimation = ColorTween(
        begin: Colors.grey.withOpacity(0.3),
        end: Theme.of(context).colorScheme.primary,
      ).animate(_focusController);

      _hasInitializedAnimations = true;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isExpanded) {
      setState(() => _isExpanded = true);
      _expandController.forward();
      _focusController.forward();
    } else if (!_focusNode.hasFocus && _isExpanded && widget.controller.text.isEmpty) {
      setState(() => _isExpanded = false);
      _expandController.reverse();
      _focusController.reverse();
    }
  }

  void _onTextChange() {
    final shouldShowCount = widget.controller.text.length > widget.maxLength * 0.8;
    if (shouldShowCount != _showCharacterCount) {
      setState(() => _showCharacterCount = shouldShowCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_expandAnimation, _borderAnimation]),
      builder: (context, child) {
        return Container(
          height: _expandAnimation.value,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderAnimation.value ?? Colors.grey.withOpacity(0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLines: _isExpanded ? 4 : 1,
                    maxLength: widget.maxLength,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? '¿Algo más que quieras compartir?',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      counterText: '', // Ocultar contador por defecto
                    ),
                    style: theme.textTheme.bodyMedium,
                    onSubmitted: (_) => _focusNode.unfocus(),
                  ),
                ),
              ),

              if (_isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sugerencias rápidas
                      if (widget.controller.text.isEmpty)
                        _buildQuickSuggestions(),

                      const Spacer(),

                      // Contador de caracteres
                      if (_showCharacterCount)
                        _buildCharacterCounter(theme),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = ['En casa 🏠', 'En el trabajo 💼', 'Con amigos 👥'];

    return Row(
      children: suggestions.map((suggestion) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              widget.controller.text = suggestion;
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCharacterCounter(ThemeData theme) {
    final currentLength = widget.controller.text.length;
    final isNearLimit = currentLength > widget.maxLength * 0.9;
    final isOverLimit = currentLength > widget.maxLength;

    Color counterColor;
    if (isOverLimit) {
      counterColor = Colors.red;
    } else if (isNearLimit) {
      counterColor = Colors.orange;
    } else {
      counterColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOverLimit)
          Icon(
            Icons.warning,
            size: 14,
            color: Colors.red,
          ),
        if (isOverLimit) const SizedBox(width: 4),
        Text(
          '$currentLength/${widget.maxLength}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: counterColor,
          ),
        ),
      ],
    );
  }
}
