import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/main.dart';

import 'caption_service.dart';
import 'caption_widget.dart';
import 'widgets/videoid_form.dart';

class CaptionViewState {
  Caption currentCaption;
  CaptionViewState()
      : currentCaption = Caption("", "00:00:00,000", "00:00:00,000", "");
}

final captionStateEn = StateProvider((ref) => CaptionViewState());
final captionStateJa = StateProvider((ref) => CaptionViewState());

class YoutubePlayBack extends ConsumerWidget {
  List<Widget> playbackWidget() {
    return [
      VideoIdInputForm(),
      const YoutubePlayerIFrame(
        aspectRatio: 16 / 9,
      ),
    ];
  }

  List<Widget> captionWidget() {
    return [
      CaptionWidget("en"),
      CaptionWidget("ja"),
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
          if (kIsWeb && constraints.maxWidth > 700) {
            return Row(
              children: [
                SizedBox(
                    width: 500,
                    child: Column(
                      children: playbackWidget(),
                    )),
                Column(
                  children: captionWidget(),
                )
              ],
            );
          } else {
            return Column(
              children: [...playbackWidget(), ...captionWidget()],
            );
          }
        }));
  }
}
