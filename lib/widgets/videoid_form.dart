import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtubeepl/main.dart';

typedef VideoIdFormFieldSetter = void Function(String? newValue);

class VideoIdInputForm extends ConsumerWidget {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return YoutubeValueBuilder(
      builder: (context, value) {
        return Form(
            key: _form,
            child: Column(children: [
              TextFormField(
                initialValue: "_CIHLJHVoN8",
                enabled: true,
                maxLength: 20,
                onSaved: (String? txt) {
                  ref.read(videoIdProvider.notifier).state = txt!;
                  context.ytController.load(txt);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _form.currentState!.save();
                },
                child: const Text("更新"),
              ),
            ]));
      },
    );
  }
}
