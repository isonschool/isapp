String elapsedTimeString(int elapsed) {
  if (elapsed == null) {
    return '-';
  }
  var min = (elapsed.toDouble() / 60.0).floor();
  var sec = elapsed - min * 60;
  var ret = '';
  if (min < 10) {
    ret += '0';
  }
  ret += '$min';
  ret += ':';
  if (sec < 10) {
    ret += '0';
  }
  ret += '$sec';
  return ret;
}
