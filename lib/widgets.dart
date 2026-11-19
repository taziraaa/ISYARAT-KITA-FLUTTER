import 'package:flutter/material.dart';

import 'data.dart';
import 'theme.dart';

// ───────────────────────── State scope ─────────────────────────

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// ───────────────────────── Brand ─────────────────────────

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset('assets/Logo/logo_mark.png',
            width: size, height: size, fit: BoxFit.cover),
      );
}

class LogoLockup extends StatelessWidget {
  final double markSize;
  final double fontSize;
  const LogoLockup({super.key, this.markSize = 42, this.fontSize = 24});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoMark(size: markSize),
          const SizedBox(width: 8),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: 'Isyarat',
                style: AppText.base(size: fontSize, weight: FontWeight.w700)),
            TextSpan(
                text: 'Kita',
                style: AppText.base(
                    size: fontSize,
                    weight: FontWeight.w700,
                    color: AppColors.primary)),
          ])),
        ],
      );
}

// ───────────────────────── Headers ─────────────────────────

/// Back arrow + title row used on pushed screens.
class BackHeader extends StatelessWidget {
  final String title;
  const BackHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            InkResponse(
              onTap: () => Navigator.of(context).maybePop(),
              radius: 24,
              child:
                  const Icon(Icons.arrow_back, size: 24, color: AppColors.ink),
            ),
            const SizedBox(width: 28),
            Expanded(child: Text(title, style: AppText.appBar())),
          ],
        ),
      );
}

/// Large title used on tab screens (Modul, Kamus, Profile).
class TabTitle extends StatelessWidget {
  final String title;
  const TabTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Text(title, style: AppText.pageTitle()),
      );
}

// ───────────────────────── Buttons ─────────────────────────

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? trailing;
  final VoidCallback? onTap;
  const PrimaryButton(this.label, {super.key, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppText.button()),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailing, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      );
}

class OutlineButtonX extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const OutlineButtonX(this.label, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
                child: Text(label,
                    style: AppText.button(color: AppColors.primary))),
          ),
        ),
      );
}

// ───────────────────────── Cards ─────────────────────────

class OutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  const OutlinedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
              color: borderColor ?? AppColors.border, width: borderWidth),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

class TintCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const TintCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.tintBorder),
        ),
        child: child,
      );
}

/// Light-blue box with a leading icon and text (info / tip).
class InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? title;
  const InfoBox(
      {super.key, required this.icon, required this.text, this.title});

  @override
  Widget build(BuildContext context) => TintCard(
        radius: 12,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: AppText.base(size: 14, height: 1.45)),
            ),
          ],
        ),
      );
}

/// "Latihan kecil" style tip card with heading row.
class TipCard extends StatelessWidget {
  final String title;
  final String text;
  const TipCard({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) => TintCard(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lightbulb_outline,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(title, style: AppText.label()),
            ]),
            const SizedBox(height: 12),
            Text(text, style: AppText.base(size: 14, height: 1.5)),
          ],
        ),
      );
}

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  const ProgressBar(this.value, {super.key});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: AppColors.tint,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
      );
}

/// "Progres belajarmu 20%" card (Home, Modul, Profile, Hasil).
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return OutlinedCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Progres belajarmu', style: AppText.label()),
              Text('${s.percent}%',
                  style: AppText.base(
                      size: 24,
                      weight: FontWeight.w800,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(s.completed / modules.length),
          const SizedBox(height: 12),
          Text('${s.completed} dari ${modules.length} modul selesai',
              style: AppText.caption()),
        ],
      ),
    );
  }
}

class PillChip extends StatelessWidget {
  final String text;
  final double size;
  final bool upper;
  const PillChip(this.text, {super.key, this.size = 12, this.upper = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: upper ? 12 : 10, vertical: upper ? 5 : 4),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text,
            style: upper
                ? AppText.eyebrow(color: AppColors.primary, size: size)
                : AppText.base(
                    size: size,
                    weight: FontWeight.w700,
                    color: AppColors.primary)),
      );
}

class AppField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final bool error;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const AppField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.error = false,
    this.suffix,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = error ? AppColors.error : AppColors.border;
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label()),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppText.base(size: 15, color: AppColors.body),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.base(size: 15, color: AppColors.muted),
            filled: true,
            fillColor: AppColors.field,
            suffixIcon: suffix,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: b(color, error ? 1.5 : 1.5),
            focusedBorder: b(error ? AppColors.error : AppColors.primary, 1.5),
            border: b(color, 1.5),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Bottom navigation ─────────────────────────

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.index, required this.onTap});

  static const _items = <(IconData, String)>[
    (Icons.home_outlined, 'Beranda'),
    (Icons.menu_book_outlined, 'Modul'),
    (Icons.book_outlined, 'Kamus'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: List.generate(_items.length, (i) {
                final sel = i == index;
                final (icon, label) = _items[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 32,
                          decoration: BoxDecoration(
                            color: sel ? AppColors.tint : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon,
                              size: 24,
                              color:
                                  sel ? AppColors.primary : AppColors.navIcon),
                        ),
                        const SizedBox(height: 4),
                        Text(label,
                            style: AppText.base(
                                size: 12,
                                weight: sel ? FontWeight.w700 : FontWeight.w500,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.navIcon)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
}

// ───────────────────────── Misc ─────────────────────────

/// Illustration with rounded corners (lesson / quiz / spelling images).
class SignImage extends StatelessWidget {
  final String asset;
  final double radius;
  final BoxFit fit;
  const SignImage(this.asset,
      {super.key, this.radius = 14, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(asset, width: double.infinity, fit: fit),
      );
}

class AvatarCircle extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool ring;
  const AvatarCircle(
      {super.key,
      required this.size,
      required this.iconSize,
      this.ring = false});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.tint,
          border:
              ring ? Border.all(color: AppColors.tintBorder, width: 1.5) : null,
        ),
        child: Icon(Icons.account_circle_outlined,
            size: iconSize, color: AppColors.primary),
      );
}

/// Scrollable page body with the standard 20dp side padding.
class PageBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  const PageBody(
      {super.key,
      required this.children,
      this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 24)});

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        physics: const ClampingScrollPhysics(),
        children: children,
      );
}

/// Dimmed scrim color used behind the bottom sheet and dialog.
const kScrim = AppColors.scrim;
