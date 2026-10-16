import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          ScreenHeader(
            title: 'Profile',
            onBack: onBack,
            trailing: GlassCircleButton(
              icon: Icons.edit_outlined,
              onTap: () => _showEditProfile(context),
            ),
          ),
          const SizedBox(height: 22),
          Reveal(
            child: Glass(
              radius: 32,
              opacity: 0.2,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Avatar(name: state.userName, size: 74),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.userName,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    state.location,
                                    style: AppText.caption.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Age',
                          value: '${state.age}',
                          unit: 'y.o',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Height',
                          value: '${state.height}',
                          unit: 'cm',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          label: 'Weight',
                          value: '${state.weight}',
                          unit: 'kg',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text('Account settings', style: AppText.section),
          const SizedBox(height: 12),
          Reveal(
            delay: const Duration(milliseconds: 80),
            child: _SettingsGroup(
              children: [
                _SettingTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal information',
                  onTap: () => _showEditProfile(context),
                ),
                _SettingTile(
                  icon: Icons.alarm_rounded,
                  title: 'Reminder',
                  trailingText: state.reminder.format(context),
                  onTap: () => _pickReminder(context, state),
                ),
                _SettingTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound',
                  switchValue: state.sound,
                  onSwitch: state.setSound,
                ),
                _SettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  switchValue: state.notifications,
                  onSwitch: state.setNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text('Preferences', style: AppText.section),
          const SizedBox(height: 12),
          Reveal(
            delay: const Duration(milliseconds: 140),
            child: _SettingsGroup(
              children: [
                _SettingTile(
                  icon: _appearanceIcon(state.themeMode),
                  title: 'Appearance',
                  trailingText: _appearanceLabel(state.themeMode),
                  onTap: () => _showAppearance(context),
                ),
                _SettingTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Experience level',
                  trailingText: state.experience,
                  onTap: () => _showExperience(context),
                ),
                _SettingTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'Caution areas',
                  trailingText: state.cautionAreas.isEmpty
                      ? 'None'
                      : '${state.cautionAreas.length}',
                  onTap: () => _showCautionAreas(context),
                ),
                _SettingTile(
                  icon: Icons.straighten_rounded,
                  title: 'Units',
                  trailingText: 'Metric',
                  onTap: () => showToast(context, 'Imperial units coming soon'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Glass(
            radius: 28,
            opacity: 0.12,
            onTap: () => showToast(context, 'Signed out (demo)'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Log out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminder(BuildContext context, AppState state) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: state.reminder,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.orange,
            surface: Palette.of(context).bgBottom,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) state.setReminder(picked);
  }

  void _showEditProfile(BuildContext context) {
    showGlassSheet<void>(
      context,
      title: 'Personal information',
      builder: (_) => const _EditProfileForm(),
    );
  }

  static String _appearanceLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };

  static IconData _appearanceIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };

  void _showAppearance(BuildContext context) {
    const modes = [
      (ThemeMode.light, 'Bright sage glass'),
      (ThemeMode.dark, 'Deep green, easy on the eyes at night'),
      (ThemeMode.system, 'Follow your device setting'),
    ];
    showGlassSheet<void>(
      context,
      title: 'Appearance',
      builder: (sheetContext) {
        final state = AppScope.of(sheetContext);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, desc) in modes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Glass(
                  radius: 22,
                  opacity: mode == state.themeMode ? 0.4 : 0.12,
                  padding: const EdgeInsets.all(14),
                  onTap: () => state.setThemeMode(mode),
                  child: Row(
                    children: [
                      Icon(_appearanceIcon(mode), color: Colors.white),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appearanceLabel(mode),
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(desc, style: AppText.caption),
                          ],
                        ),
                      ),
                      if (mode == state.themeMode)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Done',
                onTap: () => Navigator.pop(sheetContext),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExperience(BuildContext context) {
    const levels = [
      ('Beginner', 'Just getting started with routines'),
      ('Intermediate', 'Consistent a few times a week'),
      ('Advanced', 'Training and tracking daily'),
    ];
    showGlassSheet<void>(
      context,
      title: 'Experience level',
      builder: (sheetContext) {
        final state = AppScope.of(sheetContext);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (level, desc) in levels)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Glass(
                  radius: 22,
                  opacity: level == state.experience ? 0.4 : 0.12,
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    state.setExperience(level);
                    Navigator.pop(sheetContext);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level,
                              style: AppText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(desc, style: AppText.caption),
                          ],
                        ),
                      ),
                      if (level == state.experience)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCautionAreas(BuildContext context) {
    const areas = [
      'Neck',
      'Shoulders',
      'Wrists',
      'Lower back',
      'Hips',
      'Knees',
      'Ankles',
    ];
    showGlassSheet<void>(
      context,
      title: 'Caution areas',
      builder: (sheetContext) {
        final state = AppScope.of(sheetContext);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We will avoid exercises that strain these areas.',
              style: AppText.caption.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in areas)
                  Pressable(
                    onTap: () => state.toggleCaution(a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: state.cautionAreas.contains(a)
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        a,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: state.cautionAreas.contains(a)
                              ? AppColors.ink
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Done',
                onTap: () => Navigator.pop(sheetContext),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      opacity: 0.5,
      borderOpacity: 0.6,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.ink.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11)),
              ],
            ),
            style: const TextStyle(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 30,
      opacity: 0.1,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
    this.switchValue,
    this.onSwitch,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;

  @override
  Widget build(BuildContext context) {
    final isSwitch = switchValue != null;
    return Glass(
      radius: 24,
      opacity: 0.2,
      padding: EdgeInsets.fromLTRB(
        10,
        isSwitch ? 4 : 10,
        12,
        isSwitch ? 4 : 10,
      ),
      onTap: isSwitch ? () => onSwitch?.call(!switchValue!) : onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                trailingText!,
                style: AppText.caption.copyWith(fontSize: 13),
              ),
            ),
          if (isSwitch)
            Switch(
              value: switchValue!,
              onChanged: onSwitch,
              thumbColor: const WidgetStatePropertyAll(AppColors.ink),
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.85),
            ),
        ],
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final AppState _state = AppScope.of(context);
  late final _name = TextEditingController(text: _state.userName);
  late final _location = TextEditingController(text: _state.location);
  late final _age = TextEditingController(text: '${_state.age}');
  late final _height = TextEditingController(text: '${_state.height}');
  late final _weight = TextEditingController(text: '${_state.weight}');

  @override
  void dispose() {
    for (final c in [_name, _location, _age, _height, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    _state.updateProfile(
      name: name.isEmpty ? _state.userName : name,
      location: _location.text.trim(),
      age: int.tryParse(_age.text) ?? _state.age,
      height: int.tryParse(_height.text) ?? _state.height,
      weight: int.tryParse(_weight.text) ?? _state.weight,
    );
    Navigator.pop(context);
    showToast(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    const number = TextInputType.number;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassTextField(controller: _name, hint: 'Full name'),
          const SizedBox(height: 10),
          GlassTextField(controller: _location, hint: 'City, Country'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _age,
                  hint: 'Age',
                  keyboardType: number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassTextField(
                  controller: _height,
                  hint: 'Height',
                  keyboardType: number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassTextField(
                  controller: _weight,
                  hint: 'Weight',
                  keyboardType: number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Save changes', onTap: _save),
        ],
      ),
    );
  }
}
