class Progress {
  late double total;
  late double loaded;

  Progress.fromMap(Map<String, dynamic> map) {
    total = map['total'];
    loaded = map['loaded'];
  }
}
