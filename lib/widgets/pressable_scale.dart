import 'package:flutter/material.dart';

/// يضيف تكبيراً خفيفاً عند اللمس مع الحفاظ على تموّج Material داخل [InkWell].
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.minScale = 0.985,
  });

  final Widget child;
  final double minScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1, end: widget.minScale).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _c.forward(),
      onPointerUp: (_) => _c.reverse(),
      onPointerCancel: (_) => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
