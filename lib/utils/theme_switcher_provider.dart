import 'package:flutter/material.dart';

class ThemeSwitcherProvider extends InheritedWidget {
  const ThemeSwitcherProvider({
    super.key,
    required this.changeTheme,
    required super.child,
  });

  final void Function(ThemeData theme) changeTheme;

  static ThemeSwitcherProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeSwitcherProvider>();

  @override
  bool updateShouldNotify(ThemeSwitcherProvider old) => false;
}
