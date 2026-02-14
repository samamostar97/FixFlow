import 'package:flutter/material.dart';

class AppTableSkeleton extends StatelessWidget {
  final int rows;

  const AppTableSkeleton({super.key, this.rows = 8});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      padding: const EdgeInsets.all(20),
      child: _ShimmerBlock(
        child: Column(
          children: [
            const _RowSkeleton(isHeader: true),
            const SizedBox(height: 12),
            ...List.generate(
              rows,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _RowSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  final bool isHeader;

  const _RowSkeleton({this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final height = isHeader ? 14.0 : 12.0;
    final factors = isHeader
        ? const [0.12, 0.22, 0.16, 0.2, 0.14, 0.16]
        : const [0.1, 0.24, 0.18, 0.22, 0.14, 0.16];

    return Row(
      children: factors
          .map(
            (factor) => Expanded(
              flex: (factor * 100).round(),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          )
          .toList(),
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
