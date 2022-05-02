import 'package:flutter/material.dart';

///
class Loader extends StatelessWidget {
  const Loader({
    Key? key,
    this.size = 20,
    this.loading = true,
    this.centered = true,
    this.valueColor = Colors.yellow,
    this.padding,
  }) : super(key: key);

  final double size;
  final bool loading;
  final bool centered;
  final Color valueColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (loading == false) return const SizedBox.shrink();
    Widget spinner = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
        strokeWidth: 2,
      ),
    );

    if (padding != null) {
      spinner = Padding(padding: padding!, child: spinner);
    }

    return centered ? Center(child: spinner) : spinner;
  }
}
