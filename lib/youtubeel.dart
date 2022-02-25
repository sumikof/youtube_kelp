import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/caption_service.dart';
import 'package:youtubeepl/main.dart';
import 'dart:developer';

import 'caption_widget.dart';
import 'widgets/videoid_form.dart';

class CaptionListWidget extends ConsumerWidget {
  String videoId;
  final captionListProvider;
  CaptionListWidget(this.videoId)
      : captionListProvider = FutureProvider<Map<String, CaptionTrack>>((ref) {
          return captionServer.captionTracks(videoId);
        });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Map<String, CaptionTrack>> asyncValue =
        ref.watch(captionListProvider);
    return asyncValue.when(
        data: (Map captions) {
          return Column(children: [
            CaptionWidget(videoId, "en", captions["en"]),
            CaptionWidget(videoId, "ja", captions["ja"]),
          ]);
        },
        error: (err, stack) {
          return Text("$err");
        },
        loading: () => const Text("caption list loading"));
  }
}

class YoutubePlayBack extends ConsumerWidget {
  List<Widget> playbackWidget() {
    return [
      VideoIdInputForm(),
      const YoutubePlayerIFrame(
        aspectRatio: 16 / 9,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String videoId = ref.watch(videoIdProvider);
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      params: const YoutubePlayerParams(
        startAt: Duration(seconds: 0),
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    return YoutubePlayerControllerProvider(
        controller: _controller,
        child: LayoutBuilder(builder: (context, constraints) {
          log("playback build");
          if (kIsWeb && constraints.maxWidth > 700) {
            return Row(
              children: [
                SizedBox(
                    width: 500,
                    child: Column(
                      children: playbackWidget(),
                    )),
                CaptionListWidget(videoId)
              ],
            );
          } else {
            return Column(
              children: [...playbackWidget(), CaptionListWidget(videoId)],
            );
          }
        }));
  }
}
