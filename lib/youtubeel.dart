import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/main.dart';

import 'caption_service.dart';
import 'caption_widget.dart';
import 'widgets/videoid_form.dart';

final positionProvider = StateProvider((ref) {
  return Duration();
});

class YoutubePlayBack extends ConsumerWidget {
  List<Widget> playbackWidget() {
    return [
      VideoIdInputForm(),
      const YoutubePlayerIFrame(
        aspectRatio: 16 / 9,
      ),
    ];
  }

  Widget firstCaption(WidgetRef ref) {
    AsyncValue<CaptionList> asyncValue = ref.watch(firstCaptionProvider);
    return asyncValue.when(
      data: (CaptionList caps) {
        return CaptionView(caps);
      },
      error: (err, stak) {
        return Text("error => $err");
      },
      loading: () => const Text("loading"),
    );
  }

  Widget secondCaption(WidgetRef ref) {
    AsyncValue<CaptionList> asyncValue = ref.watch(firstCaptionProvider);
    return asyncValue.when(
      data: (CaptionList caps) {
        return CaptionView(caps);
      },
      error: (err, stak) {
        return Text("error => $err");
      },
      loading: () => const Text("loading"),
    );
  }

  List<Widget> captionWidgets(ref) {
    return [
      firstCaption(ref),
      secondCaption(ref),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String videoId = ref.watch(videoIdProvider);
    print("youtubeplayback => videoId => $videoId");
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      params: const YoutubePlayerParams(
        startAt: Duration(seconds: 0),
        showControls: true,
        showFullscreenButton: true,
      ),
    )..listen((event) {
        //ref.read(positionProvider.notifier).state = event.position;
      });

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
                  children: captionWidgets(ref),
                )
                //Text("${ref.watch(positionProvider).toString()}")
              ],
            );
          } else {
            return Column(
              children: [...playbackWidget(), ...captionWidgets(ref)],
            );
          }
        }));
  }
}
