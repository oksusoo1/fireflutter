import 'dart:ui' as ui;
import '../../fireflutter.dart';
import 'package:flutter/material.dart';

/// Tr
///
/// Text translation. It supports all `Text` widget properties, and [onTap], [padding], [margin]
class Tr extends StatelessWidget {
  const Tr(
    String this.data, {
    Key? key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.onTap,
    this.margin,
    this.padding,
  })  : textSpan = null,
        super(key: key);

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;

  final Function()? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Map<String, String>>>(
        stream: TranslationService.instance.changes.stream,
        builder: (context, snapshot) {
          String text = data!;
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data![text] != null) {
              final code = ui.window.locale.languageCode;
              if (snapshot.data![text]![code] != null) {
                text = snapshot.data![text]![code]!;
              }
            }
          }
          Widget child = Text(
            text,
            key: key,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            overflow: overflow,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            semanticsLabel: semanticsLabel,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
          );
          if (margin != null || padding != null) {
            child = Container(
              child: child,
              margin: margin,
              padding: padding,
            );
          }
          if (onTap != null) {
            child = GestureDetector(
              child: child,
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
            );
          }
          return child;
        });
  }
}
