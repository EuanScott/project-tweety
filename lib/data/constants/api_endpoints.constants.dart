class ApiEndpoints {
  //region Authentication
  /// POST - Creates a new user session
  static const String customerLogin = '/customer/login';

  /// POST - Clear's the users session from the backend
  static const String customerLogout = '/customer/logout';

  //endregion

  //region Order
  /// GET - Retrieves the customer's orders
  static const String customerOrders = '/customer/orders';

  /// GET - Retrieve the details of a specific order
  static const String orderDetails = '/customer/orders/{orderId}';

  /// Returns the endpoint URL for retrieving details of a specific order.
  ///
  /// [orderId] - The unique identifier of the order.
  static String orderDetailsUrl(String orderId) =>
      orderDetails.replaceAll('{orderId}', orderId);
  //endregion
}
