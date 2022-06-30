import 'dart:io';

Future<int> getnum(int time, int num) async {
  //await Future.delayed(Duration(seconds: time));
  sleep(Duration(seconds: time));
  return Future<int>.value(num);
}

void unko() async {
  final num = await getnum(1, 3);
  final a = await getnum(3, num);
  print("A,${a * 5}");
  final int b = await getnum(2, num);
  print("B,${b * 10}");
}

void main() {
  unko();
}
