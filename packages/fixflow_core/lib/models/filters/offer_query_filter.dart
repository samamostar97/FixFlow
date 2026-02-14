import 'package:fixflow_core/models/filters/base_query_filter.dart';

class OfferQueryFilter extends BaseQueryFilter {
  int? status;
  int? serviceType;
  int? repairRequestId;
  int? technicianId;

  OfferQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.status,
    this.serviceType,
    this.repairRequestId,
    this.technicianId,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (status != null) params['status'] = status.toString();
    if (serviceType != null) params['serviceType'] = serviceType.toString();
    if (repairRequestId != null) {
      params['repairRequestId'] = repairRequestId.toString();
    }
    if (technicianId != null) params['technicianId'] = technicianId.toString();
    return params;
  }

  @override
  OfferQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? status,
    int? serviceType,
    int? repairRequestId,
    int? technicianId,
  }) {
    return OfferQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      repairRequestId: repairRequestId ?? this.repairRequestId,
      technicianId: technicianId ?? this.technicianId,
    );
  }
}
