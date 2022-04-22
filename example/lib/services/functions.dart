import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:example/services/global.dart';
import 'package:fireflutter/fireflutter.dart';

String tr(String code) {
  return TranslationService.instance.tr(code);
}

/// Puts [element] between every element in [list].
///
/// Example:
///
///     final list1 = intersperse(2, <int>[]); // [];
///     final list2 = intersperse(2, [0]); // [0];
///     final list3 = intersperse(2, [0, 0]); // [0, 2, 0];
///
///     return intersperse(Divider(), children).toList();
///
Iterable<T> intersperse<T>(T element, Iterable<T> iterable) sync* {
  final iterator = iterable.iterator;
  if (iterator.moveNext()) {
    yield iterator.current;
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

/// Convert youtube link into embeded HTML to display youtube video in HTML
String convertYoutubeLinkToEmbedHTML(String str) {
  return str.replaceAllMapped(
    RegExp(
        r"http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?"),
    (match) {
      return """
      <video id="${match.group(0)}" src="${match.group(0)}"></video>
      """;
    },
  );
}

/// Check if a string has youtube link.
bool hasYoutubeLink(String str) {
  return RegExp(
          r"http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?")
      .hasMatch(str);
}

// Return youtube id.
String getYoutubeId(String url, {bool trimWhitespaces = true}) {
  /// if url is youtube id itself,
  if (!url.contains("http") && (url.length == 11)) return url;
  //
  if (trimWhitespaces) url = url.trim();

  for (final exp in [
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    RegExpMatch? match = exp.firstMatch(url);
    // print('url; $url, match; $match\n--\n');
    if (match != null && match.groupCount >= 1) return match.group(1)!;
  }
  return '';
}

/// 공공데이터 Tour Api 에서 검색 결과에서 어떤 경우 mapx, mapy 가 문자열로 넘어 온다. 또 어떤 경우는 숫자이다.
double toDouble(dynamic v) {
  if (v == null) {
    return 0;
  } else if (v is String) {
    return double.parse(v);
  } else {
    return v;
  }
}

// int toInt(dynamic v) {
//   if (v == null) return 0;
//   if (v is int)
//     return v;
//   else
//     return int.parse(v);
//   // if (v is String) {
//   //   return int.parse(v);
//   // } else {
//   //   return v;
//   // }
// }

/// 공공데이터 Tour Api 에서 검색 결과에서 zipcode 의 결과 값이 어떤 경우는 String, 어떤 경우는 int 이다.
String toString(dynamic v) {
  if (v == null) {
    return '';
  } else if (v is int) {
    return v.toString();
  }
  return v;
}

launchURL(String uri) async {
  // final uri = Uri(scheme: scheme, path: path).toString();

  // print('uri; $uri');
  bool re = false;
  try {
    re = await canLaunch(uri);
  } catch (e) {
    service.error(e);
  }
  try {
    if (re) {
      await launch(uri);
    }
  } catch (e) {
    service.error(e);
  }
}

// bool isHtml(String t) {
//   t = t.toLowerCase();

//   if (t.indexOf('<br>') != -1) return true;
//   if (t.indexOf('<br />') != -1) return true;
//   if (t.indexOf('<p>') != -1) return true;
//   if (t.indexOf('</div>') != -1) return true;
//   if (t.indexOf('</span>') != -1) return true;
//   if (t.indexOf('<img') != -1) return true;
//   if (t.indexOf('</em>') != -1) return true;
//   if (t.indexOf('</b>') != -1) return true;
//   if (t.indexOf('</strong>') != -1) return true;
//   if (t.indexOf('</a>') != -1) return true;
//   if (t.indexOf('</i>') != -1) return true;

//   return false;
// }

/// Returns width size
///
/// percentage is the width percentage of screen width.
/// width is fixed width.
/// min is the minimal size.
/// max is the maximal size.
///
/// ```dart // width can't go below 200, nor can't grow 300. it will try to remain 70%
/// width(context, percentage: 70, min: 200, max: 300);
/// ```
width(
  BuildContext context, {
  double? percentage,
  double? width,
  double? min,
  double? max,
}) {
  if (percentage != null) {
    width = MediaQuery.of(context).size.width * percentage / 100;
  }

  // print('width: $width');

  if (min != null && width! < min) return min;
  if (max != null && width! > max) return max;
  return width;
}
