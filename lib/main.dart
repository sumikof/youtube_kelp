import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtubeepl/caption_service.dart';
import 'package:youtubeepl/caption_widget.dart';
import 'package:youtubeepl/widgets/videoid_form.dart';
import 'package:youtubeepl/youtubeel.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final videoIdProvider = StateProvider((ref) {
  return "_CIHLJHVoN8";
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

class MyHomePage extends ConsumerWidget {
  final CaptionService _captionService = CaptionService();

  final String title;
  MyHomePage(this.title);

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoId = ref.watch(videoIdProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: YoutubePlayBack());
  }
}
