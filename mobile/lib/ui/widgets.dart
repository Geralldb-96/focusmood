import 'package:flutter/material.dart';

import '../core/theme.dart';

void pushScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

/// Contenedor estándar de pantalla: área segura, margen lateral de 22 y desplazamiento.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.children,
    this.onRefresh,
    this.bottomPadding = 28,
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(22, 12, 22, bottomPadding),
      children: children,
    );
    return Scaffold(
      body: SafeArea(
        child: onRefresh == null
            ? list
            : RefreshIndicator(onRefresh: onRefresh!, child: list),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      child: Row(
        children: [
          if (onBack != null) ...[
            RoundIconButton(
              icon: Icons.arrow_back,
              tooltip: 'Volver',
              onPressed: onBack!,
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.5,
                    height: 1.15,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MoodColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: MoodColors.soft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 19, color: MoodColors.green),
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    this.danger = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color bg = danger
        ? MoodColors.dangerBg
        : (secondary ? Colors.white : MoodColors.green);
    final Color fg = danger
        ? MoodColors.danger
        : (secondary ? MoodColors.deep : Colors.white);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: SizedBox(
        height: 50,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: .6),
            elevation: 0,
            shape: StadiumBorder(
              side: BorderSide(
                color: secondary ? MoodColors.line : Colors.transparent,
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 9),
                    ],
                    Flexible(child: Text(label, textAlign: TextAlign.center)),
                  ],
                ),
        ),
      ),
    );
  }
}

class LinkText extends StatelessWidget {
  const LinkText(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: MoodColors.green,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      minimumSize: Size.zero,
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class PastelCard extends StatelessWidget {
  const PastelCard({
    super.key,
    required this.child,
    this.color = MoodColors.soft,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.white = false,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool white;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: white ? Colors.white : color,
      borderRadius: BorderRadius.circular(23),
      border: white ? Border.all(color: const Color(0xFFE7EEEA)) : null,
      boxShadow: white
          ? const [
              BoxShadow(
                color: Color(0x10263B30),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ]
          : null,
    ),
    child: child,
  );
}

/// Aviso informativo con icono (equivale a los `aside` del prototipo).
class InfoBanner extends StatelessWidget {
  const InfoBanner(
    this.text, {
    super.key,
    this.icon = Icons.info_outline,
    this.color = MoodColors.peach,
    this.foreground = MoodColors.peachText,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) => PastelCard(
    color: color,
    child: Row(
      children: [
        Icon(icon, size: 21, color: foreground),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, height: 1.45, color: foreground),
          ),
        ),
      ],
    ),
  );
}

class MoodChip extends StatelessWidget {
  const MoodChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : MoodColors.deep;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? MoodColors.deep : const Color(0xFFDCEEE6),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check, size: 13, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChipWrap extends StatelessWidget {
  const ChipWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 12),
    child: Wrap(spacing: 7, runSpacing: 7, children: children),
  );
}

class RowTile extends StatelessWidget {
  const RowTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.tileColor = MoodColors.soft,
    this.iconColor = MoodColors.green,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Control independiente (interruptor, casilla...). Va fuera del área táctil de la fila
  /// para que tenga sus propias semánticas y no active `onTap`.
  final Widget? trailing;
  final Color tileColor;
  final Color iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFFE6EEEA)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                container: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(23),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, size: 19, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    subtitle!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: MoodColors.muted,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (trailing == null && onTap != null)
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: MoodColors.muted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Semantics(container: true, child: trailing),
              ),
          ],
        ),
      ),
    ),
  );
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.readOnly = false,
    this.validator,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool readOnly;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            readOnly: readOnly,
            validator: validator,
            autofillHints: autofillHints,
            style: TextStyle(
              fontSize: 14,
              color: readOnly ? MoodColors.muted : MoodColors.text,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA9B8B1),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, size: 18, color: MoodColors.muted),
            ),
          ),
        ),
      ],
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: MoodColors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.eco_outlined, color: Colors.white, size: 21),
      ),
      const SizedBox(width: 10),
      const Text(
        'Mood',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: MoodColors.deep,
        ),
      ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -.3,
      ),
    ),
  );
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key, this.center = false, this.size = 14});

  final String text;
  final bool center;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      text,
      textAlign: center ? TextAlign.center : null,
      style: TextStyle(fontSize: size, height: 1.5, color: MoodColors.muted),
    ),
  );
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.foreground = MoodColors.text,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: MoodColors.muted),
          ),
        ],
      ),
    ),
  );
}

class ProgressTrack extends StatelessWidget {
  const ProgressTrack(this.value, {super.key, this.color = MoodColors.green});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: 8,
      color: color,
      backgroundColor: Colors.white.withValues(alpha: .7),
    ),
  );
}
