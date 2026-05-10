import '../models/menu_response.dart';
import '../models/order.dart';
import 'api_client.dart';

class MenuApi {
  final _dio = ApiClient().dio;

  Future<MenuResponse> getMenu(String tableId) async {
    final res = await _dio.get(
      '/api/v1/menu',
      queryParameters: {'table_id': tableId},
    );
    return MenuResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Order> createOrder(OrderRequest request) async {
    final res = await _dio.post('/api/v1/orders', data: request.toJson());
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Order> getOrderStatus(String orderId) async {
    final res = await _dio.get('/api/v1/orders/$orderId');
    return Order.fromJson(res.data as Map<String, dynamic>);
  }
}
