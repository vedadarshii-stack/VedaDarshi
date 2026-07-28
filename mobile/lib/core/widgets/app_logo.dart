import 'package:flutter/material.dart';

/// The single reusable app logo widget.
///
/// Renders the "Veda Jyoti" app-icon tile (navy rounded square, gold
/// border, flame-lotus-book artwork). Use this everywhere the logo mark
/// needs to appear instead of loading the asset directly.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/logo_veda_jyoti.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}
