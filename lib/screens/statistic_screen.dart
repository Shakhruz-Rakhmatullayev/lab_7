import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/glass.dart';
import '../widgets/sheet.dart';
import 'home_screen.dart' show showWorkoutSheet;

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  Metric _metric = Metric.steps;
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    final values = chartData[_metric]![_period];
    final avg = values.reduce((a, b) => a + b) / values.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          ScreenHeader(
            title: 'Statistic',
            onBack: widget.onBack,
            trailing: GlassCircleButton(
              icon: Icons.more_horiz_rounded,
              onTap: () => _showMore(context),
            ),
          ),
          const SizedBox(height: 22),
          Reveal(
            child: Glass(
              radius: 32,
              opacity: 0.1,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _MetricTabs(
                    selected: _metric,
                    onChanged: (m) => setState(() => _metric = m),
                  ),
                  const SizedBox(height: 10),
                  Glass(
                    radius: 26,
                    opacity: 0.55,
                    borderOpacity: 0.6,
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [...previous, ?current],
                                ),
                                child: Text.rich(
                                  key: ValueKey('$_metric$_period'),
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _metric.format(avg),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '  ${_metric.caption}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.ink.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(color: AppColors.ink),
                                ),
                              ),
                            ),
                            _PeriodPicker(
                              selected: _period,
                              onChanged: (p) => setState(() => _period = p),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PillBarChart(
                          key: ValueKey(_metric),
                          values: values,
                          labels: chartDays,
                          formatter: _metric.format,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(
            title: 'Recent workout',
            action: 'See all',
            onAction: () => showWorkoutSheet(context),
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: const Duration(milliseconds: 120),
            child: SizedBox(
              height: 290,
              child: Row(
                children: [
                  const Expanded(child: _HeartRateCard()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.orange,
                            title: 'Calories',
                            value: '143',
                            unit: 'kcal',
                          ),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: _MiniStatCard(
                            icon: Icons.alarm_rounded,
                            title: 'Durations',
                            value: '130',
                            unit: 'minutes',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader(
            title: 'Habit consistency',
            action: 'Last 4 weeks',
          ),
          const SizedBox(height: 14),
          const Reveal(
            delay: Duration(milliseconds: 200),
            child: _ConsistencyCard(),
          ),
        ],
      ),
    );
  }

  void _showMore(BuildContext context) {
    const actions = [
      (Icons.flag_outlined, 'Set weekly goals'),
      (Icons.ios_share_rounded, 'Share progress'),
      (Icons.file_download_outlined, 'Export report'),
    ];
    showGlassSheet<void>(
      context,
      title: 'Statistics',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (icon, label) in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Glass(
                radius: 22,
                opacity: 0.14,
                padding: const EdgeInsets.all(12),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showToast(context, '$label — coming soon');
                },
                child: Row(
                  children: [
                    IconBubble(icon: icon),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: AppText.body)),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTabs extends StatelessWidget {
  const _MetricTabs({required this.selected, required this.onChanged});

  final Metric selected;
  final ValueChanged<Metric> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in Metric.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Pressable(
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  height: 44,
                  decoration: BoxDecoration(
                    color: m == selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m.icon,
                        size: 16,
                        color: m == selected ? AppColors.ink : Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          m.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: m == selected ? AppColors.ink : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: selected,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 8,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (_) => [
        for (var i = 0; i < chartPeriods.length; i++)
          PopupMenuItem(
            value: i,
            child: Text(
              chartPeriods[i],
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: i == selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chartPeriods[selected],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.ink,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard();

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 28,
      opacity: 0.5,
      borderOpacity: 0.6,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            top: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => CustomPaint(painter: WavePainter(v)),
            ),
          ),
          const Positioned(
            top: 14,
            left: 14,
            child: IconBubble(icon: Icons.monitor_heart_outlined),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heart rate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '120',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' bpm', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    this.iconColor = AppColors.ink,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 28,
      opacity: 0.5,
      borderOpacity: 0.6,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon: icon, color: iconColor, size: 36),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12)),
              ],
            ),
            style: const TextStyle(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// GitHub-style heatmap of how many habits were completed each day.
class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  static double _level(int week, int day) => ((week * 7 + day) * 37 % 5) / 4;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 28,
      opacity: 0.14,
      child: Column(
        children: [
          Row(
            children: [
              for (final d in chartDays)
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppText.caption.copyWith(fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var w = 0; w < 4; w++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.1 + 0.8 * _level(w, d),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: AppText.caption.copyWith(fontSize: 11)),
              const SizedBox(width: 6),
              for (var i = 0; i < 5; i++)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1 + 0.8 * i / 4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 3),
              Text('More', style: AppText.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
