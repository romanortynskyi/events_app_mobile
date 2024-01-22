class Term {
  int? offset;
  String? value;

  Term({
    this.offset,
    this.value,
  });

  Term.fromMap(Map<String, dynamic> map) {
    offset = map['offset'];
    value = map['value'];
  }
}
