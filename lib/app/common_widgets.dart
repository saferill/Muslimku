import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_session.dart';
import '../data/demo_content.dart';
import '../theme/muslimku_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color(0xFFF9FBF7),
                MuslimKuColors.background,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        const Positioned.fill(child: IgnorePointer(child: PatternOverlay())),
        Positioned(
            top: -140,
            right: -80,
            child: _blob(
                MuslimKuColors.primaryFixed.withValues(alpha: 0.18), 300)),
        Positioned(
            top: 120,
            left: -120,
            child: _blob(
                MuslimKuColors.primaryContainer.withValues(alpha: 0.08), 240)),
        Positioned(
            bottom: -180,
            left: -100,
            child: _blob(MuslimKuColors.primary.withValues(alpha: 0.08), 360)),
      ],
    );
  }

  static Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 120, spreadRadius: 12),
        ],
      ),
    );
  }
}

class PatternOverlay extends StatelessWidget {
  const PatternOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter());
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MuslimKuColors.primary.withValues(alpha: 0.035);

    for (double y = 24; y < size.height; y += 72) {
      for (double x = 24; x < size.width; x += 72) {
        canvas.drawPath(_star(Offset(x, y), 12), paint);
      }
    }
  }

  Path _star(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi * 2 * i) / 8;
      final currentRadius = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + currentRadius * math.cos(angle - math.pi / 2),
        center.dy + currentRadius * math.sin(angle - math.pi / 2),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoadingDot extends StatelessWidget {
  const LoadingDot({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.45 : 0.22),
        shape: BoxShape.circle,
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? MuslimKuColors.surface;
    final content = Container(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: MuslimKuColors.primary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: content,
    );
  }
}

class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassInfoCard extends StatelessWidget {
  const GlassInfoCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MuslimKuColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(leading, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MuslimKuColors.primary,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: MuslimKuColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tag,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: MuslimKuColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: enabled
                    ? const [
                        MuslimKuColors.primary,
                        MuslimKuColors.primaryContainer
                      ]
                    : const [
                        MuslimKuColors.surfaceHighest,
                        MuslimKuColors.surfaceHigh
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: enabled
                      ? MuslimKuColors.primary.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: enabled ? 24 : 14,
                  offset: Offset(0, enabled ? 14 : 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: enabled ? Colors.white : MuslimKuColors.textSoft,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.action,
  });

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null) action!,
      ],
    );
  }
}

class ProfileBubble extends StatelessWidget {
  const ProfileBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.of(context);
    return ProfileAvatar(initials: session.profile.initials, size: 44);
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.size = 44,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [MuslimKuColors.primaryContainer, MuslimKuColors.primary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class ShellHeader extends StatelessWidget {
  const ShellHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);

    return Row(
      children: [
        ProfileAvatar(initials: session.profile.initials, size: 46),
        const Spacer(),
        Column(
          children: [
            Text(
              'Muslimku',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: MuslimKuColors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              'Digital Sanctuary',
              style: theme.textTheme.labelSmall?.copyWith(
                color: MuslimKuColors.textSoft,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: MuslimKuColors.primary),
          ),
        ),
      ],
    );
  }
}

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(Icons.home_rounded, 'Beranda'),
    _BottomNavItem(Icons.menu_book_rounded, 'Al-Qur\'an'),
    _BottomNavItem(Icons.notifications_active_rounded, 'Adzan'),
    _BottomNavItem(Icons.settings_rounded, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = currentIndex == index;

          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 16 : 10,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected ? MuslimKuColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: selected ? Colors.white : MuslimKuColors.textSoft,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              selected ? Colors.white : MuslimKuColors.textSoft,
                          fontWeight: FontWeight.w700,
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

class PermissionTile extends StatelessWidget {
  const PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: MuslimKuColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: MuslimKuColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MuslimKuColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MuslimKuColors.primary),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: MuslimKuColors.textSoft)),
        ],
      ),
    );
  }
}

class FeatureBentoCard extends StatelessWidget {
  const FeatureBentoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: SizedBox(
        height: 192,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: MuslimKuColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MuslimKuColors.primary),
            ),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class FeatureMiniCard extends StatelessWidget {
  const FeatureMiniCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: MuslimKuColors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MuslimKuColors.text),
          ),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.titleMedium)),
          Icon(Icons.chevron_right_rounded, color: MuslimKuColors.textSoft),
        ],
      ),
    );
  }
}

class PrayerRow extends StatelessWidget {
  const PrayerRow({super.key, required this.prayer});

  final PrayerData prayer;

  @override
  Widget build(BuildContext context) {
    final active = prayer.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: active
            ? MuslimKuColors.primaryContainer
            : MuslimKuColors.surfaceLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(prayer.icon,
              color: active ? Colors.white : MuslimKuColors.textSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: active ? Colors.white : MuslimKuColors.text,
                  ),
            ),
          ),
          Text(
            prayer.time,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active ? Colors.white : MuslimKuColors.text,
                ),
          ),
          if (active) ...[
            const SizedBox(width: 8),
            const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 18),
          ],
        ],
      ),
    );
  }
}

class SelectableOption extends StatelessWidget {
  const SelectableOption({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: selected ? MuslimKuColors.surfaceLow : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected
              ? MuslimKuColors.primary.withValues(alpha: 0.25)
              : MuslimKuColors.outline.withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color:
                  selected ? MuslimKuColors.primary : MuslimKuColors.textSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? MuslimKuColors.primary : MuslimKuColors.textSoft,
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: child,
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.iconBackground = MuslimKuColors.primaryFixed,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: MuslimKuColors.text),
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class SettingSwitchRow extends StatelessWidget {
  const SettingSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.bottomPadding = 16,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: MuslimKuColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class SettingArrowRow extends StatelessWidget {
  const SettingArrowRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.bottomPadding = 16,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double bottomPadding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded, color: MuslimKuColors.textSoft),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: child,
    );
  }
}

class SurahTile extends StatelessWidget {
  const SurahTile({
    super.key,
    required this.surah,
    required this.onTap,
  });

  final SurahData surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MuslimKuColors.surfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              surah.number.toString(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: MuslimKuColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${surah.meaning} • ${surah.ayahs} Ayat',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            surah.arabic,
            textDirection: TextDirection.rtl,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: MuslimKuColors.primary),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.suffixIcon,
  });

  final String hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: suffixIcon ?? const Icon(Icons.tune_rounded),
      ),
    );
  }
}

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? MuslimKuColors.primary : MuslimKuColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: active ? Colors.white : MuslimKuColors.text,
            ),
      ),
    );
  }
}

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MuslimKuColors.surfaceLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: MuslimKuColors.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class AudioBar extends StatelessWidget {
  const AudioBar({
    super.key,
    required this.height,
    required this.opacity,
  });

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: MuslimKuColors.primary.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
