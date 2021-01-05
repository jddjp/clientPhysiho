import 'dart:math';

const _chars = '1234567890';
Random _rnd = Random();

// Create a random string
String getUID(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));