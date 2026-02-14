import 'package:fixflow_core/models/filters/base_query_filter.dart';

class TechnicianProfileQueryFilter extends BaseQueryFilter {
  bool? isVerified;
  String? zone;

  TechnicianProfileQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.isVerified,
    this.zone,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isVerified != null) params['isVerified'] = isVerified.toString();
    if (zone != null && zone!.isNotEmpty) params['zone'] = zone!;
    return params;
  }

  @override
  TechnicianProfileQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    bool? isVerified,
    String? zone,
  }) {
    return TechnicianProfileQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      isVerified: isVerified ?? this.isVerified,
      zone: zone ?? this.zone,
    );
  }
}
