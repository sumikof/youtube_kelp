import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/caption_service.dart';
import 'package:youtubeepl/main.dart';

final captionServer = CaptionServer();
typedef CaptionTable = Map<String, CaptionList>;

class CaptionServer {
  String videoId;
  CaptionTable _caption_table;
  CaptionServer()
      : videoId = "",
        _caption_table = CaptionTable() {
    print("Create CaptionTable");
  }
  Future<CaptionList> updateCaption(String videoId, String language) async {
    if (this.videoId == videoId && _caption_table.containsKey(language)) {
      return _caption_table[language]!;
    }
    print("get caption $videoId");
    this.videoId = videoId;
    final download_captions = captionService.download(videoId, language);
    _caption_table[language] = await download_captions;
    return _caption_table[language]!;
  }
}

class CaptionWidget extends ConsumerWidget {
  String language = "";
  Duration start;
  Duration end;
  String caption;

  late final captionProvider;
  CaptionWidget(this.language)
      : start = Duration(),
        end = Duration(),
        caption = "" {
    this.captionProvider = FutureProvider<CaptionList>((ref) async {
      String videoId = ref.watch(videoIdProvider);
      return captionServer.updateCaption(videoId, language);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<CaptionList> prov = ref.watch(captionProvider);
    final widget_content = prov.when(
      data: (CaptionList captions) {
        return YoutubeValueBuilder(builder: (context, value) {
          final captionIndex =
              captions.indexWhere((caption) => caption.isMatch(value.position));
          if (captionIndex != -1) {
            final start = captions[captionIndex].start;
            final end = captions[captionIndex].end;
            return Text(captions[captionIndex].caption);
          }
          return Text("");
        });
      },
      error: (err, stack) {
        return Text("error ${err}");
      },
      loading: () {
        return Text("loading");
      },
    );

    return Container(
      height: 50,
      child: widget_content,
    );
  }
}
