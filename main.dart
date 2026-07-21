import 'dart:io';

void main() {
  stdout.write('Say Hi or hello: ');
  final raw = stdin.readLineSync() ?? '';
  final s = raw.trim().toLowerCase();
  if (s.startsWith('hi')) {
    print('Nice one!');
  } else if (s.startsWith('hello')) {
    print('Amazeballs!');
  } else {
    print("I expected 'Hi' or 'hello'.");
  }
}