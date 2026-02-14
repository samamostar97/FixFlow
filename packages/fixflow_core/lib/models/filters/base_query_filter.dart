class BaseQueryFilter {
  int pageNumber;
  int pageSize;
  String? search;
  String? orderBy;

  BaseQueryFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
    this.orderBy,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (search != null && search!.isNotEmpty) {
      params['search'] = search!;
    }
    if (orderBy != null && orderBy!.isNotEmpty) {
      params['orderBy'] = orderBy!;
    }

    return params;
  }

  BaseQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return BaseQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
