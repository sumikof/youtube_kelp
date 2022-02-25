import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/caption_service.dart';
import 'dart:developer';

class CaptionView extends StatefulWidget {
  CaptionList captionList;
  CaptionView(this.captionList);
  @override
  State<StatefulWidget> createState() => _CaptionViewState();
}

class _CaptionViewState extends State<CaptionView> {
  int captionIndex = 0;
  _CaptionViewState();

  @override
  Widget build(BuildContext context) {
    final widgetContent = YoutubeValueBuilder(builder: (context, value) {
      Duration position = value.position;
      if (position < widget.captionList[captionIndex].start ||
          widget.captionList[captionIndex].end < position) {
        final tmpIndex = widget.captionList
            .indexWhere((caption) => caption.isMatch(value.position));
        if (tmpIndex != -1) {
          if (mounted) {
            captionIndex = tmpIndex;
          }
        }
      }
      return Text(widget.captionList[captionIndex].caption);
    });

    return Container(
      height: 50,
      child: widgetContent,
      //child: Text("Cations"),
    );
  }
}

class CaptionWidget extends ConsumerWidget {
  final String language;
  final String videoId;
  final CaptionTrack captionTrack;
  final captionProvider;

  CaptionWidget(this.videoId, this.language, this.captionTrack)
      : captionProvider = FutureProvider<CaptionList>((ref) async {
          log("Create CaptionWidget");
          return captionServer.updateCaption(
              videoId, language, captionTrack.trackKind);
        });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("build CaptionWidget");
    AsyncValue<CaptionList> asyncValue = ref.watch(captionProvider);
    return asyncValue.when(
      data: (CaptionList caps) {
        return CaptionView(caps);
      },
      error: (err, stak) {
        log("$stak");
        return Text("error => $err");
      },
      loading: () => const Text("loading"),
    );
  }
}
