import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';

/// A compact, keyboard-accessible control with raised and selected states.
class NeoIconButton extends StatefulWidget {
  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.tooltip,
    this.primary = false,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
  final String? tooltip;
  final bool primary;

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Listener(
        onPointerDown: (_) {
          if (widget.onPressed != null) setState(() => _pressed = true);
        },
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: NeoStyle.control(
            context,
            radius: 14,
            selected: widget.selected || _pressed,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              selected: widget.selected,
              child: IconButton(
                tooltip: widget.tooltip,
                onPressed: widget.onPressed,
                color: widget.selected || widget.primary
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface,
                icon: Icon(widget.icon),
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
