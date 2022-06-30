import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtubeepl/caption_service.dart';
import 'package:youtubeepl/youtubeel.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final videoIdProvider = StateProvider((ref) => "");
final captionListProvider = FutureProvider((ref) {
  final videoId = ref.watch(videoIdProvider);
  return captionServer.getCaptionTracks(videoId);
});
final firstCaptionProvider = FutureProvider<CaptionList>((ref) {
  AsyncValue<CaptionTracks> captionTracks = ref.watch(captionListProvider);
  return captionTracks.when(data: (CaptionTracks caps) {
    return captionServer.downloadCaption(caps["en"]!);
  }, error: (err, stack) {
    return [];
  }, loading: () {
    return [];
  });
});
final secondCaptionProvider = FutureProvider<CaptionList>((ref) {
  AsyncValue<CaptionTracks> captionTracks = ref.watch(captionListProvider);
  return captionTracks.when(data: (CaptionTracks caps) {
    return captionServer.downloadCaption(caps["ja"]!);
  }, error: (err, stack) {
    return [];
  }, loading: () {
    return [];
  });
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage('Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage(this.title);

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: YoutubePlayBack());
  }
}
