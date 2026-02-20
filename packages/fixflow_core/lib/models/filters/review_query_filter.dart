import 'package:fixflow_core/models/filters/base_query_filter.dart';

class ReviewQueryFilter extends BaseQueryFilter {
  int? technicianId;
  int? customerId;
  int? minRating;

  ReviewQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.technicianId,
    this.customerId,
    this.minRating,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (technicianId != null) params['technicianId'] = technicianId.toString();
    if (customerId != null) params['customerId'] = customerId.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    return params;
  }

  @override
  ReviewQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? technicianId,
    int? customerId,
    int? minRating,
  }) {
    return ReviewQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      technicianId: technicianId ?? this.technicianId,
      customerId: customerId ?? this.customerId,
      minRating: minRating ?? this.minRating,
    );
  }
}
