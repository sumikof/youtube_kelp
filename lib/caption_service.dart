import 'dart:convert';

import 'package:http/http.dart' as http;

const CAPTION_SERVICE_URL = "localhost:3000";
final DURATION_STRING = RegExp(r'(\w+):(\w+):(\w+),(\w+)');
const DURATION_STRING_HOUR = 1;
const DURATION_STRING_MINUTES = 2;
const DURATION_STRING_SECOND = 3;
const DURATION_STRING_MILLI_SECOND = 4;

final captionService = CaptionService();
final captionServer = CaptionServer();

typedef CaptionTable = Map<String, CaptionList>;
typedef CaptionListTable = Map<String, Map<String, CaptionTrack>>;
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
  CaptionTable _caption_table;
  CaptionListTable _captionListTable;
  CaptionServer()
      : videoId = "",
        _caption_table = CaptionTable(),
        _captionListTable = CaptionListTable() {
    print("Create CaptionTable");
  }
  void checkVideoId(String videoId) {
    if (this.videoId != videoId) {
      _caption_table.clear();
      _captionListTable.clear();
      this.videoId = videoId;
    }
  }

  Future<Map<String, CaptionTrack>> captionTracks(String videoId) async {
    checkVideoId(videoId);
    if (_captionListTable.containsKey(videoId)) {
      return _captionListTable[videoId]!;
    }
    _captionListTable[videoId] = await captionService.captionList(videoId);

    if (!_captionListTable[videoId]!.containsKey("en")) {
      _captionListTable[videoId]!["en"] =
          CaptionTrack(videoId, "", "en", "asr");
    }
    if (!_captionListTable[videoId]!.containsKey("ja")) {
      _captionListTable[videoId]!["ja"] =
          CaptionTrack(videoId, "", "ja", "asr");
    }

    return _captionListTable[videoId]!;
  }

  Future<CaptionList> updateCaption(
      String videoId, String language, String trackKind) async {
    checkVideoId(videoId);
    if (_caption_table.containsKey(language)) {
      print("return cash caption");
      return _caption_table[language]!;
    }
    _caption_table[language] =
        await captionService.download(videoId, language, trackKind);
    return _caption_table[language]!;
  }
}

class CaptionTrack {
  String videoId;
  String captionId;
  String language;
  String trackKind;
  CaptionTrack(this.videoId, this.captionId, this.language, this.trackKind);
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

  Future<Map<String, CaptionTrack>> captionList(String videoId) async {
    final params = {
      "vid": videoId,
    };
    final body = await execApi("captions/list", params);

    Map<String, CaptionTrack> ret = {};
    body['items'].forEach((item) {
      final language = item["snippet"]["language"];
      final caption_info = CaptionTrack(
          videoId, item["id"], language, item["snippet"]["trackKind"]);
      if (["en", "ja"].contains(language) &&
          (!ret.containsKey(language) || ret[language]!.trackKind == "asr")) {
        ret[language] = caption_info;
      }
    });
    return ret;
  }

  Future<CaptionList> download(
      String videoId, String lang, String trackKind) async {
    final sub_option =
        trackKind == "standard" ? "--write-sub" : "--write-auto-sub";
    final params = {
      "vid": videoId,
      "lang": lang,
      'sub_option': sub_option,
    };
    final body = await execApi("captions/download", params);
    CaptionList captions = [];
    if (body.containsKey("error")) {
      print("error download captions");
      captions.add(Caption(
          "0", "00:00:00,000", "99:99:99,000", "error download caption"));
      return captions;
    }

    final first_caption = body["captions"].first;
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
