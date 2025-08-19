class ApiEndpoints {
  //region Authentication
  static const String customerLogin = '/customer/login';
  static const String customerLogout = '/customer/logout';
  //endregion

  //region Order
  static const String customerOrders = '/customer/orders';
  static const String orderDetails = '/customer/orders/{orderId}';

  static String orderDetailsUrl(String orderId) =>
      orderDetails.replaceAll('{orderId}', orderId);
  //endregion
}
