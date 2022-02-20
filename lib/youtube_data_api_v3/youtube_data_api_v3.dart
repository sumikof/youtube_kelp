import 'package:googleapis/youtube/v3.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class YoutubeCaptionService {
  static String apiKey = "apiKey-XXXXXXXXXXXXXXXX";

  Future<void> getCaptions(videoId) async {
    final _googleSignIn = await GoogleSignIn(
      scopes: <String>[YouTubeApi.youtubeForceSslScope],
      clientId: 'clientId-XXXXXXXXXXXXX',
    );
    await _googleSignIn.signIn();
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      print("not create http client ${_googleSignIn.signInOption}");
      throw Exception();
    }
    var _api = YouTubeApi(httpClient!);

    var captions = await _api.captions.list(["snippet"], videoId);
  }
}
