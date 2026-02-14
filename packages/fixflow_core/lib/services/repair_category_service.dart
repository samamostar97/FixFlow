import 'package:fixflow_core/models/filters/repair_category_query_filter.dart';
import 'package:fixflow_core/models/requests/create_repair_category_request.dart';
import 'package:fixflow_core/models/requests/update_repair_category_request.dart';
import 'package:fixflow_core/models/responses/repair_category_response.dart';
import 'package:fixflow_core/services/crud_service.dart';

class RepairCategoryService extends CrudService<RepairCategoryResponse,
    CreateRepairCategoryRequest, UpdateRepairCategoryRequest, RepairCategoryQueryFilter> {
  RepairCategoryService({required super.client})
      : super(
          basePath: '/api/repair-categories',
          fromJson: RepairCategoryResponse.fromJson,
        );
}
