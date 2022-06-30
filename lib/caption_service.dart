import 'dart:convert';

import 'package:http/http.dart' as http;

const CAPTION_SERVICE_URL = "192.168.11.211:3000";
final DURATION_STRING = RegExp(r'(\w+):(\w+):(\w+),(\w+)');
const DURATION_STRING_HOUR = 1;
const DURATION_STRING_MINUTES = 2;
const DURATION_STRING_SECOND = 3;
const DURATION_STRING_MILLI_SECOND = 4;
final captionServer = CaptionServer();

final captionApiService = CaptionApiService();
typedef Language = String;
typedef VideoId = String;
typedef CaptionTable = Map<Language, CaptionList>;
typedef CaptionTracks = Map<Language, CaptionTrack>;
typedef CaptionListTable = Map<VideoId, CaptionTracks>;
typedef CaptionTables = Map<VideoId, CaptionTable>;
typedef CaptionList = List<Caption>;

class CaptionTrack {
  String videoId;
  String captionId;
  Language language;
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
  CaptionTables _caption_table;
  CaptionListTable _captionTracks;
  CaptionServer()
      : _caption_table = CaptionTables(),
        _captionTracks = CaptionListTable() {
    print("Create CaptionTable");
  }

  Future<CaptionTracks> getCaptionTracks(String videoId) async {
    if (_captionTracks.containsKey(videoId)) {
      return _captionTracks[videoId]!;
    }
    _captionTracks[videoId] = await captionApiService.captionList(videoId);
    return _captionTracks[videoId]!;
  }

  Future<CaptionList> downloadCaption(CaptionTrack captionTrack) async {
    if (_caption_table.containsKey(captionTrack.videoId)) {
      if (!_caption_table[captionTrack.videoId]!
          .containsKey(captionTrack.language)) {
        _caption_table[captionTrack.videoId]![captionTrack.language] =
            await captionApiService.download(captionTrack.videoId,
                captionTrack.language, captionTrack.trackKind);
      }
    } else {
      final captionList = await captionApiService.download(
          captionTrack.videoId, captionTrack.language, captionTrack.trackKind);
      final captionTable = {captionTrack.language: captionList};
      _caption_table[captionTrack.videoId] = captionTable;
    }
    return _caption_table[captionTrack.videoId]![captionTrack.language]!;
  }
}

class CaptionApiService {
  Future<Map> execApi(String api, params) async {
    final response = await http.get(Uri.http(CAPTION_SERVICE_URL, api, params));
    return json.decode(response.body);
  }

  Future<CaptionTracks> captionList(String videoId) async {
    if (videoId == "") {
      return {};
    }
    final params = {
      "vid": videoId,
    };
    final body = await execApi("captions/list", params);

    CaptionTracks ret = {};
    ["en", "ja"].forEach((language) {
      ret[language] = CaptionTrack(videoId, "", language, "asr");
    });
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
