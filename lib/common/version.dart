const isonSchoolMathVersion = '1.0.0';
const isonSchoolMathAppName = 'IsonSchool Math';
const isRelease = bool.fromEnvironment('dart.vm.product');

bool satisfiesMinVersion(String minVersion) {
  if (minVersion == null) {
    print('minVersion is null.');
    return true;
  }
  var parts = minVersion.split('.');
  if (parts.length != 3) {
    print('minVersion is not rightly written. $minVersion');
    return true;
  }
  var current = isonSchoolMathVersion.split('.');
  if (current.length != 3) {
    print(
        'isonSchoolMathVersion is not rightly written. $isonSchoolMathVersion');
    return true;
  }
  for (var i = 0; i < 3; i++) {
    var c = int.tryParse(parts[0]);
    var v = int.tryParse(parts[0]);
    if (c < v)
      return false;
    else if (c > v) return true;
  }
  return true;
}
