class MatchedSubstring {
  late int length;
  late int offset;

  MatchedSubstring.fromMap(Map<String, dynamic> map) {
    length = map['length'];
    offset = map['offset'];
  }
}
