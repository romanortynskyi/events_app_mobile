class MatchedSubstring {
  int? offset;
  int? length;

  MatchedSubstring({
    this.offset,
    this.length,
  });

  factory MatchedSubstring.fromMap(Map<String, dynamic> map) {
    return MatchedSubstring(
      length: map['length'],
      offset: map['offset'],
    );
  }
}
