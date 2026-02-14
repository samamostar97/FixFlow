import 'package:flutter/material.dart';

class AppListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const AppListSkeleton({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, separatorIndex) => const SizedBox(height: 12),
      itemBuilder: (_, index) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: const _ShimmerBlock(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bar(widthFactor: 0.55, height: 14),
            SizedBox(height: 10),
            _Bar(widthFactor: 0.95, height: 12),
            SizedBox(height: 6),
            _Bar(widthFactor: 0.8, height: 12),
            SizedBox(height: 14),
            _Bar(widthFactor: 0.35, height: 10),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _Bar({required this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  final Widget child;

  const _ShimmerBlock({required this.child});

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFF1E293B);
    final highlight = const Color(0xFF334155);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.2 + (_controller.value * 2.4), -0.3),
              end: Alignment(-0.2 + (_controller.value * 2.4), 0.3),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
    );
  }
}
