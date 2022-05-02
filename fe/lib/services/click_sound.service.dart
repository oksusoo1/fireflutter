import 'package:audioplayers/audioplayers.dart';

class ClickSoundService {
  static ClickSoundService? _instance;
  static ClickSoundService get instance {
    _instance ??= ClickSoundService();
    return _instance!;
  }

  late final String url;

  // 최초 앱 부팅시 한번 호출하도록해서, 페이지 이동시 최초 1회에서 딜레이가 없도록 한다.
  init() async {
    final uri = await AudioCache.instance.load('click.mp3');
    url = uri.toString();
  }

  Future play() {
    // debugPrint('url; $url');
    return AudioPlayer().play(UrlSource(url));
  }
}
