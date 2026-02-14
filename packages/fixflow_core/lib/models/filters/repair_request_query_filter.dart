import 'package:fixflow_core/models/filters/base_query_filter.dart';

class RepairRequestQueryFilter extends BaseQueryFilter {
  int? status;
  int? categoryId;
  int? preferenceType;
  int? customerId;

  RepairRequestQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.status,
    this.categoryId,
    this.preferenceType,
    this.customerId,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (status != null) params['status'] = status.toString();
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    if (preferenceType != null) {
      params['preferenceType'] = preferenceType.toString();
    }
    if (customerId != null) params['customerId'] = customerId.toString();
    return params;
  }

  @override
  RepairRequestQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? status,
    int? categoryId,
    int? preferenceType,
    int? customerId,
  }) {
    return RepairRequestQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      preferenceType: preferenceType ?? this.preferenceType,
      customerId: customerId ?? this.customerId,
    );
  }
}
