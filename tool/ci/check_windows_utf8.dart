import 'dart:convert';
import 'dart:io';

void main() {
  if (!Platform.isWindows) {
    throw StateError('This check is for the Windows CI tool environment.');
  }
  const description = '温油站共享设计 Token、系统排版与跨端体验契约';
  if (systemEncoding.decode(utf8.encode(description)) != description) {
    throw StateError('Dart cannot decode UTF-8 Git pubspec content correctly.');
  }
  stdout.writeln('Windows Dart UTF-8 pubspec decoding verified.');
}
