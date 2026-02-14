import 'dart:convert';
import 'package:fixflow_core/api/api_client.dart';
import 'package:fixflow_core/models/common/lookup_response.dart';
import 'package:fixflow_core/models/common/paged_result.dart';
import 'package:fixflow_core/models/filters/base_query_filter.dart';

abstract class CrudService<TResponse, TCreate, TUpdate, TFilter extends BaseQueryFilter> {
  final ApiClient _client;
  final String basePath;
  final TResponse Function(Map<String, dynamic>) fromJson;

  CrudService({
    required ApiClient client,
    required this.basePath,
    required this.fromJson,
  }) : _client = client;

  Future<PagedResult<TResponse>> getAll(TFilter filter) async {
    final response = await _client.get(basePath, queryParams: filter.toQueryParameters());
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PagedResult.fromJson(json, fromJson);
  }

  Future<TResponse> getById(int id) async {
    final response = await _client.get('$basePath/$id');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(json);
  }

  Future<TResponse> create(Map<String, dynamic> data) async {
    final response = await _client.post(basePath, body: data);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(json);
  }

  Future<TResponse> update(int id, Map<String, dynamic> data) async {
    final response = await _client.put('$basePath/$id', body: data);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(json);
  }

  Future<void> delete(int id) async {
    await _client.delete('$basePath/$id');
  }

  Future<List<LookupResponse>> getLookup() async {
    final response = await _client.get('$basePath/lookup');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => LookupResponse.fromJson(e as Map<String, dynamic>)).toList();
  }
}
