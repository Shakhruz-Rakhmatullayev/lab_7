import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';
import '../widgets/glass.dart';
import '../widgets/sheet.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final DateTime _today = dateOnly(DateTime.now());
  late DateTime _selected = _today;

  bool get _isToday => _selected == _today;
  bool get _isFuture => _selected.isAfter(_today);

  /// Past days get a stable, made-up history; future days are all open.
  bool _doneOn(Habit h) {
    if (_isToday) return h.done;
    if (_isFuture) return false;
    return (h.id.hashCode + _selected.day * 7) % 3 != 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final habits = state.habits;
    final done = habits.where(_doneOn).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          ScreenHeader(
            title: 'Habits',
            onBack: widget.onBack,
            trailing: GlassCircleButton(
              icon: Icons.add_rounded,
              onTap: () => showAddHabitSheet(context),
            ),
          ),
          const SizedBox(height: 22),
          Reveal(
            child: _DateStrip(
              today: _today,
              selected: _selected,
              onSelect: (d) => setState(() => _selected = d),
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            delay: const Duration(milliseconds: 80),
            child: _SummaryCard(
              done: done,
              total: habits.length,
              bestStreak: state.bestStreak,
              isToday: _isToday,
              isFuture: _isFuture,
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(
            title: _isToday
                ? 'Today'
                : '${weekdayShort[_selected.weekday - 1]}, ${formatLongDate(_selected)}',
            action: '${habits.length} habits',
          ),
          const SizedBox(height: 12),
          if (habits.isEmpty)
            Glass(
              opacity: 0.12,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 10),
                  const Text('No habits yet', style: AppText.section),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to start building your flow.',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          for (var i = 0; i < habits.length; i++)
            Dismissible(
              key: ValueKey(habits[i].id),
              direction: _isToday
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(right: 24),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) {
                final h = habits[i];
                state.removeHabit(h);
                showToast(context, 'Removed "${h.title}"');
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Reveal(
                  delay: Duration(milliseconds: 120 + i * 60),
                  child: _HabitTile(
                    habit: habits[i],
                    done: _doneOn(habits[i]),
                    onToggle: _isToday
                        ? () => state.toggleHabit(habits[i])
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var i = -3; i <= 3; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    return Row(
      children: [
        for (final d in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Pressable(
                onTap: () => onSelect(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: d == selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekdayShort[d.weekday - 1],
                        style: TextStyle(
                          fontSize: 11,
                          color: d == selected
                              ? AppColors.ink.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: d == selected ? AppColors.ink : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: d == today
                              ? AppColors.orange
                              : Colors.transparent,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.done,
    required this.total,
    required this.bestStreak,
    required this.isToday,
    required this.isFuture,
  });

  final int done;
  final int total;
  final int bestStreak;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final remaining = total - done;
    final (title, subtitle) = isFuture
        ? ('Coming up', 'Your $total habits are planned for this day.')
        : !isToday
        ? ('Looking back', 'You completed $done of $total habits on this day.')
        : remaining == 0 && total > 0
        ? (
            'Perfect day!',
            'Every habit is complete. Enjoy the rest of your day.',
          )
        : progress >= 0.5
        ? (
            "You're on a roll!",
            'Complete $remaining more habit${remaining == 1 ? '' : 's'} to close your day.',
          )
        : (
            "Let's get going",
            '$remaining habit${remaining == 1 ? '' : 's'} left for today. Small steps count.',
          );

    return Glass(
      radius: 30,
      opacity: 0.18,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => SizedBox.square(
              dimension: 96,
              child: CustomPaint(
                painter: RingPainter(
                  progress: v,
                  color: Colors.white,
                  trackColor: Colors.white.withValues(alpha: 0.18),
                  strokeWidth: 10,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$done/$total',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('done', style: AppText.caption),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.section),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppText.caption.copyWith(height: 1.35, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Best streak $bestStreak days',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, required this.done, this.onToggle});

  final Habit habit;
  final bool done;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 26,
      opacity: done ? 0.28 : 0.14,
      padding: const EdgeInsets.all(14),
      onTap: onToggle,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habit.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(habit.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        habit.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 13,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${habit.streak} days',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Colors.white : Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: done ? 1 : 0.6),
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey(true),
                      size: 20,
                      color: AppColors.ink,
                    )
                  : const SizedBox.shrink(key: ValueKey(false)),
            ),
          ),
        ],
      ),
    );
  }
}

void showAddHabitSheet(BuildContext context) {
  showGlassSheet<void>(
    context,
    title: 'New habit',
    builder: (_) => const _AddHabitForm(),
  );
}

class _AddHabitForm extends StatefulWidget {
  const _AddHabitForm();

  @override
  State<_AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<_AddHabitForm> {
  final _title = TextEditingController();
  IconData _icon = habitIconChoices.first;
  Color _color = habitColorChoices.first;
  String _time = habitTimes.first;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    AppScope.of(context)
        .addHabit(title: title, icon: _icon, color: _color, time: _time);
    Navigator.pop(context);
    showToast(context, 'Added "$title" to your flow');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassTextField(
            controller: _title,
            hint: 'e.g. Stretch for 5 minutes',
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Icon', style: AppText.caption),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final icon in habitIconChoices)
                Pressable(
                  onTap: () => setState(() => _icon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: icon == _icon
                          ? _color
                          : Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Color', style: AppText.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final c in habitColorChoices)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Pressable(
                    onTap: () => setState(() => _color = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: c == _color ? 3 : 0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Time of day', style: AppText.caption),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in habitTimes)
                Pressable(
                  onTap: () => setState(() => _time = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: t == _time ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t == _time ? AppColors.ink : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Add habit',
              icon: Icons.add_rounded,
              onTap: _title.text.trim().isEmpty ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
