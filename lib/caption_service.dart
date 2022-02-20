import 'dart:convert';

import 'package:http/http.dart' as http;

const CAPTION_SERVICE_URL = "localhost:3000";
final DURATION_STRING = RegExp(r'(\w+):(\w+):(\w+),(\w+)');
const DURATION_STRING_HOUR = 1;
const DURATION_STRING_MINUTES = 2;
const DURATION_STRING_SECOND = 3;
const DURATION_STRING_MILLI_SECOND = 4;

final captionService = CaptionService();
typedef CaptionList = List<Caption>;
Duration parseDurationString(String durationString) {
  final match = DURATION_STRING.firstMatch(durationString);
  if (match != null && match.groupCount == 4) {
    return Duration(
        hours: int.parse(match.group(DURATION_STRING_HOUR)!),
        minutes: int.parse(match.group(DURATION_STRING_MINUTES)!),
        seconds: int.parse(match.group(DURATION_STRING_SECOND)!),
        milliseconds: int.parse(match.group(DURATION_STRING_MILLI_SECOND)!));
  } else {
    throw Exception(
        "Not Allow Durtion Format Expect => HH:MM:SS.MS ,It is => $durationString");
  }
}

class CaptionServer {
  String videoId;
  Map<String, CaptionList> _caption_table;
  CaptionServer()
      : videoId = "",
        _caption_table = {};
}

class Caption {
  String id;
  Duration start;
  Duration end;
  String caption;
  Caption(String id, String start, String end, String caption)
      : this.id = id,
        this.caption = caption,
        this.start = parseDurationString(start),
        this.end = parseDurationString(end);
  bool isMatch(Duration time) {
    return start <= time && time < end;
  }
}

class CaptionService {
  Future<Map> execApi(String api, params) async {
    final response = await http.get(Uri.http(CAPTION_SERVICE_URL, api, params));
    return json.decode(response.body);
  }

  Future<Map> getCaptions(String videoId) async {
    final params = {
      "vid": videoId,
    };
    final body = await execApi("captions/list", params);

    var ret = {};
    body['items'].forEach((item) {
      final language = item["snippet"]["language"];
      final caption_info = {
        "id": item["id"],
        "language": language,
        "trackKind": item["snippet"]["trackKind"]
      };
      if (["en", "ja"].contains(language) &&
          (!ret.containsKey(language) || ret[language]["trackKind"] == "asr")) {
        ret[language] = caption_info;
      }
    });
    return ret;
  }

  Future<CaptionList> download(String videoId, String lang) async {
    final params = {
      "vid": videoId,
      "lang": lang,
    };
    final body = await execApi("captions/download", params);

    final first_caption = body["captions"].first;
    CaptionList captions = [];
    captions.add(
        Caption("0", "00:00:00,000", first_caption["start"], "first caption"));

    body["captions"].forEach((item) {
      final caption =
          Caption(item["index"], item["start"], item["end"], item["caption"]);
      captions.add(caption);
      //print(
      //"item => ${caption.caption},start => ${caption.start} end=> ${caption.end}");
    });

    return captions;
  }
}
