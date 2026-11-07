import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';

class ApiService {
  static const String baseUrl = "https://api.pointbox.me/api/customer";
  //'https://api.pointbox.me/api/customer';
  // `/api/notification` is mounted as a sibling of `/api/customer` on the
  // backend (server.js), not nested under it - so it needs its own base.
  static String get _notificationBaseUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/customer$'), '')}/notification';
  // Get the storage service
  static StorageService get _storage => Get.find<StorageService>();

  // Get auth token from storage
  static String? get _token => _storage.getString('auth_token');

  // Headers for authenticated requests
  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Headers for public requests
  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        final errorMessage = data['message'] ??
            data['error'] ??
            'Request failed with status ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to parse response: ${e.toString()}');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final headers = requiresAuth ? _authHeaders : _publicHeaders;
      final bodyJson = json.encode(body);

      print("📤 POST $url");
      print("📤 Headers: $headers");
      print("📤 Body: $bodyJson");

      final response = await http.post(
        url,
        headers: headers,
        body: bodyJson,
      );

      return _handleResponse(response);
    } catch (e) {
      print("❌ POST error: $e");
      if (e is Exception && !e.toString().contains('Network error')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      var url = Uri.parse('$baseUrl$endpoint');

      if (queryParameters != null && queryParameters.isNotEmpty) {
        url = url.replace(queryParameters: queryParameters);
      }

      final headers = requiresAuth ? _authHeaders : _publicHeaders;

      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = requiresAuth ? _authHeaders : _publicHeaders;

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = requiresAuth ? _authHeaders : _publicHeaders;

      final response = await http.delete(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Customer login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    final body = {
      'email': email,
      'password': password,
      if (deviceToken != null) 'deviceToken': deviceToken,
    };

    final response = await post('/login', body, requiresAuth: false);

    // Store token if login is successful
    if (response['success'] == true && response['token'] != null) {
      await _storage.setString('auth_token', response['token']);
    }

    return response;
  }

  // Customer signup
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String dateOfBirth,
    String? phone,
    String? address,
    String? country,
  }) async {
    try {
      final body = {
        'username': username,
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (country != null && country.isNotEmpty) 'country': country,
      };

      print('📤 Signup request body: $body');
      print('📤 Signup URL: $baseUrl/signup');

      final response = await post('/signup', body, requiresAuth: false);

      print('📥 Signup response: $response');

      return response;
    } catch (e) {
      print('❌ Signup error: $e');
      rethrow;
    }
  }

  // Logout - clear token
  static Future<void> logout() async {
    await _storage.remove('auth_token');
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String otp,
  }) async {
    final body = {
      'otp': otp,
    };

    final response = await post('/verify-otp', body, requiresAuth: false);

    // Store token if verification is successful
    if (response['success'] == true && response['token'] != null) {
      await _storage.setString('auth_token', response['token']);
    }

    return response;
  }

  // // Resend OTP
  // static Future<Map<String, dynamic>> resendOtp() async {
  //   final body = {};
  //   return await post('/resend-otp', body, requiresAuth: false);
  // }

  // Get banners
  static Future<Map<String, dynamic>> getBanners() async {
    // The endpoint is /web/banners which is outside the /customer path
    const url =
        'https://api.pointbox.me/api/customer/web/banners';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _publicHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get What's New items
  static Future<Map<String, dynamic>> getWhatsNew() async {
    const url =
        'https://api.pointbox.me/api/customer/web/whats-new';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _publicHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get recently joined companies
  static Future<Map<String, dynamic>> getRecentCompanies() async {
    const url =
        'https://api.pointbox.me/api/customer/web/recent-companies';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _publicHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get terms
  static Future<Map<String, dynamic>> getTerms() async {
    // The endpoint is /web/terms which is a public route
    const url =
        'https://api.pointbox.me/api/customer/web/terms';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _publicHeaders,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get brands
  static Future<Map<String, dynamic>> getBrands() async {
    return await get('/brands', requiresAuth: false);
  }

  // Get customer transactions
  static Future<Map<String, dynamic>> getTransactions() async {
    // Auth required – token is added via _authHeaders
    return await get('/transactions', requiresAuth: true);
  }

  // Get customer profile
  static Future<Map<String, dynamic>> getProfile() async {
    // Auth required – token is added via _authHeaders
    return await get('/profile', requiresAuth: true);
  }

  // Get linked brands
  // Update profile fields. Only non-null params are sent, so callers can
  // update a single field (e.g. just dateOfBirth) without resending the rest.
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? country,
  }) async {
    final body = {
      if (username != null) 'username': username,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (address != null) 'address': address,
      if (country != null) 'country': country,
    };

    return await put('/profile', body, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> getLinkedBrands() async {
    // Auth required – token is added via _authHeaders
    return await get('/linked-brands', requiresAuth: true);
  }

  // Contact support
  static Future<Map<String, dynamic>> contactSupport({
    required String brandId,
    required String subject,
    required String message,
  }) async {
    final body = {
      'brandId': brandId,
      'subject': subject,
      'message': message,
    };

    // Auth required – protectCustomer middleware
    return await post('/support', body, requiresAuth: true);
  }

  // Get products
  static Future<Map<String, dynamic>> getProducts() async {
    // Auth required – protectCustomer middleware
    return await get('/products', requiresAuth: true);
  }

  // Get top claim products (redeemed 5+ times) from linked companies
  static Future<Map<String, dynamic>> getTopClaimProducts() async {
    // Auth required – protectCustomer middleware
    return await get('/top-claim-products', requiresAuth: true);
  }

  // Get notifications for the logged-in customer (mobile-shaped: id, title,
  // body, timestamp, isRead). Backed by MySQL `notifications` +
  // `customer_notifications`, not Firestore.
  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final url = Uri.parse('$_notificationBaseUrl?page=$page&limit=$limit');
    final response = await http.get(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getUnreadNotificationCount() async {
    final url = Uri.parse('$_notificationBaseUrl/unread-count');
    final response = await http.get(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    final url = Uri.parse('$_notificationBaseUrl/$notificationId/read');
    final response = await http.put(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final url = Uri.parse('$_notificationBaseUrl/read-all');
    final response = await http.put(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteNotification(
    String notificationId,
  ) async {
    final url = Uri.parse('$_notificationBaseUrl/$notificationId');
    final response = await http.delete(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> clearAllNotifications() async {
    final url = Uri.parse(_notificationBaseUrl);
    final response = await http.delete(url, headers: _authHeaders);
    return _handleResponse(response);
  }

  // Submit review
  static Future<Map<String, dynamic>> submitReview({
    required int rating,
    required String review,
    String? userId,
  }) async {
    // Get userId from parameter, storage, or fetch from profile
    String? finalUserId = _storage.getString('user_id');

    final body = {
      'userId': finalUserId,
      'ratings': rating,
      'review': review,
    };

    print('📤 Request body: $body');

    // Use review API endpoint with full URL since it's a different base path
    try {
      const reviewBaseUrl =
          'https://api.pointbox.me/api/review';
      final url = Uri.parse('$reviewBaseUrl/');

      // IMPORTANT: Content-Type header is required for body parsing
      final headers = <String, String>{'Content-Type': 'application/json'};

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Send OTP for password change (forgot password flow)
  static Future<Map<String, dynamic>> sendOTPForPasswordChange({
    required String email,
  }) async {
    final body = {
      'email': email,
    };

    print('📤 Send OTP for password change request - email: $email');

    final response = await post('/check-email', body, requiresAuth: false);

    print('📥 Send OTP response: $response');

    return response;
  }

  // Verify OTP for password change
  static Future<Map<String, dynamic>> verifyOTPForPasswordChange({
    required String email,
    required String otp,
  }) async {
    final body = {
      'email': email,
      'otp': otp,
    };

    print('📤 Verify OTP for password change - email: $email');

    final response = await post('/verify-otp', body, requiresAuth: false);

    print('📥 Verify OTP response: $response');

    return response;
  }

  // Change password with OTP (for password reset flow)
  static Future<Map<String, dynamic>> changePasswordWithOTP({
    required String email,
    required String newPassword,
  }) async {
    final body = {
      'email': email,
      'newPassword': newPassword,
    };

    print(
        '📤 Change password request - email: $email, password length: ${newPassword.length}');

    final response = await post('/change-password', body, requiresAuth: false);

    print('📥 Change password response: $response');

    return response;
  }
}
