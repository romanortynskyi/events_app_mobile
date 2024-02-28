class Paginated<T> {
  List<T> items;
  int totalPagesCount;

  Paginated({required this.items, required this.totalPagesCount});
}
