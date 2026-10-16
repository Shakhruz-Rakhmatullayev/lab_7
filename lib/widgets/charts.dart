import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}

/// Orange progress ring with a filled icon bubble in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.icon,
    this.size = 62,
  });

  final double progress;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: RingPainter(
            progress: v,
            color: AppColors.orange,
            trackColor: AppColors.orange.withValues(alpha: 0.18),
            strokeWidth: size * 0.09,
          ),
          child: Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.orangeLight, AppColors.orange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: size * 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped weekly bar chart. Tap a bar to inspect its value.
class PillBarChart extends StatefulWidget {
  const PillBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.formatter,
    this.height = 200,
  });

  final List<double> values;
  final List<String> labels;
  final String Function(double) formatter;
  final double height;

  @override
  State<PillBarChart> createState() => _PillBarChartState();
}

class _PillBarChartState extends State<PillBarChart> {
  late int _selected = _argMax(widget.values);

  static int _argMax(List<double> v) {
    var best = 0;
    for (var i = 1; i < v.length; i++) {
      if (v[i] > v[best]) best = i;
    }
    return best;
  }

  @override
  void didUpdateWidget(PillBarChart old) {
    super.didUpdateWidget(old);
    if (!identical(old.values, widget.values)) {
      _selected = _argMax(widget.values);
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    const tooltipArea = 28.0;
    final barMax = widget.height - tooltipArea - 6;

    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final frac = maxV == minV
              ? 1.0
              : 0.3 + 0.7 * (values[i] - minV) / (maxV - minV);
          final selected = i == _selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selected = i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: tooltipArea,
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            child: Text(
                              widget.formatter(values[i]),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: frac),
                    duration: Duration(milliseconds: 700 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: barMax * v,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 8),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: selected
                              ? const [AppColors.inkSoft, AppColors.ink]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.45),
                                ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.ink.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        widget.labels[i],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppColors.ink.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Mountain-shaped heart-rate wave with a highlighted peak marker.
class WavePainter extends CustomPainter {
  WavePainter(this.progress);

  final double progress;

  static const _points = [
    0.30,
    0.42,
    0.36,
    0.55,
    0.47,
    0.80,
    0.52,
    0.66,
    0.40,
    0.50,
    0.34,
  ];
  static const _peak = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final usable = size.height * 0.78;
    final top = size.height - usable;
    final pts = [
      for (var i = 0; i < _points.length; i++)
        Offset(
          size.width * i / (_points.length - 1),
          size.height - usable * _points[i] * progress,
        ),
    ];

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final mid = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      line.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, mid.dx, mid.dy);
    }
    line.lineTo(pts.last.dx, pts.last.dy);

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.inkSoft.withValues(alpha: 0.85), AppColors.ink],
        ).createShader(Rect.fromLTWH(0, top, size.width, usable)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.45),
    );

    final markerAlpha = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
    if (markerAlpha == 0) return;
    final p = pts[_peak];
    final dash = Paint()
      ..strokeWidth = 1.2
      ..color = AppColors.ink.withValues(alpha: 0.7 * markerAlpha);
    for (var y = p.dy - 44; y < p.dy - 6; y += 6) {
      canvas.drawLine(Offset(p.dx, y), Offset(p.dx, y + 3), dash);
    }
    canvas.drawCircle(
      p,
      6.5,
      Paint()..color = Colors.white.withValues(alpha: markerAlpha),
    );
    canvas.drawCircle(
      p,
      6.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.ink.withValues(alpha: markerAlpha),
    );
  }

  @override
  bool shouldRepaint(WavePainter old) => old.progress != progress;
}
