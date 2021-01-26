import 'package:url_launcher/url_launcher.dart';

const _url = "https://www.youtube.com/channel/UCeeI-TMpIDBwFgDCmo8Qixw";

class IsonSchoolUrl {
  static Future<void> launchYoutubeChannel() async {
    if (await canLaunch(_url)) {
      await launch(_url);
    }
  }

  static Future<void> searchYoutubeChannel(String query) async {
    var u = '$_url/search?query=${Uri.encodeQueryComponent(query)}';
    if (await canLaunch(u)) {
      await launch(u);
    }
  }
}
