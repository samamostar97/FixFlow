class PaginationHelper {
  /// Returns page range with ellipsis markers (-1).
  /// Example: [1, 2, -1, 5, 6, 7, -1, 12]
  static List<int> getPageRange(int currentPage, int totalPages, {int visiblePages = 5}) {
    if (totalPages <= visiblePages + 2) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <int>[];
    final half = visiblePages ~/ 2;
    var start = currentPage - half;
    var end = currentPage + half;

    if (start < 2) {
      start = 2;
      end = start + visiblePages - 1;
    }

    if (end > totalPages - 1) {
      end = totalPages - 1;
      start = end - visiblePages + 1;
    }

    pages.add(1);
    if (start > 2) pages.add(-1);

    for (var i = start; i <= end; i++) {
      pages.add(i);
    }

    if (end < totalPages - 1) pages.add(-1);
    pages.add(totalPages);

    return pages;
  }
}
