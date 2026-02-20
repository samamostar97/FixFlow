import 'package:fixflow_core/models/filters/base_query_filter.dart';

class PaymentQueryFilter extends BaseQueryFilter {
  final int? bookingId;
  final int? userId;
  final int? status;
  final int? type;

  PaymentQueryFilter({
    super.pageNumber,
    super.pageSize,
    this.bookingId,
    this.userId,
    this.status,
    this.type,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (bookingId != null) params['bookingId'] = bookingId.toString();
    if (userId != null) params['userId'] = userId.toString();
    if (status != null) params['status'] = status.toString();
    if (type != null) params['type'] = type.toString();
    return params;
  }

  @override
  PaymentQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? bookingId,
    int? userId,
    int? status,
    int? type,
  }) {
    return PaymentQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}
