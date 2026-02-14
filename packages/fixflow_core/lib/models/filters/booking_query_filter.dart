import 'package:fixflow_core/models/filters/base_query_filter.dart';

class BookingQueryFilter extends BaseQueryFilter {
  int? jobStatus;
  int? customerId;
  int? technicianId;

  BookingQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.jobStatus,
    this.customerId,
    this.technicianId,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (jobStatus != null) params['jobStatus'] = jobStatus.toString();
    if (customerId != null) params['customerId'] = customerId.toString();
    if (technicianId != null) params['technicianId'] = technicianId.toString();
    return params;
  }

  @override
  BookingQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? jobStatus,
    int? customerId,
    int? technicianId,
  }) {
    return BookingQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      jobStatus: jobStatus ?? this.jobStatus,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
    );
  }
}
