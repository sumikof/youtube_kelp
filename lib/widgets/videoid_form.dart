import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtubeepl/main.dart';

typedef VideoIdFormFieldSetter = void Function(String? newValue);

class VideoIdInputForm extends ConsumerWidget {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
        key: _form,
        child: Column(children: [
          TextFormField(
            enabled: true,
            maxLength: 20,
            onSaved: (String? txt) {
              ref.read(videoIdProvider.notifier).state = txt!;
            },
          ),
          ElevatedButton(
            onPressed: () {
              _form.currentState!.save();
            },
            child: const Text("更新"),
          ),
        ]));
  }
}
