import 'dart:io';

void main() async {
  const folder = r'C:\Users\kapak\Downloads\generated';
  const folder2 = r'C:\Users\kapak\Documents\isonschoolapp\isapp\assets\pupils';
  var i = 1;
  await for (var f in Directory(folder).list()) {
    if (f.path.endsWith('.png'))
      f.rename('$folder2\\p${i.toString().padLeft(3, '0')}.png');
    i++;
  }
}
