import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:pointbox_mobile/app/services/firebase_messaging_service.dart';


class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();
  late final nameController = TextEditingController();
  late final phoneController = TextEditingController();
  late final confirmPasswordController = TextEditingController();
  late final addressController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedCountry = RxString('');
  final selectedDateOfBirth = Rx<DateTime?>(null);
  static const int minSignupAge = 13;
  final isTermsAccepted = false.obs;
  final otpCode = ''.obs;
  final otpError = ''.obs;
  final signupError = ''.obs;
  final resetPasswordError = ''.obs;
  final checkEmailError = ''.obs;
  final loginError = ''.obs;
  final resendTimer = 0.obs;
  
  Timer? _resendTimer;

  // @override
  // void onClose() {
  //   // Dispose controllers
  //   try {
  //     emailController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   try {
  //     passwordController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   try {
  //     nameController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   try {
  //     phoneController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   try {
  //     confirmPasswordController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   try {
  //     addressController.dispose();
  //   } catch (e) {
  //     // Controller already disposed
  //   }
  //   _resendTimer?.cancel();
  //   super.onClose();
  // }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth.value ??
          DateTime(now.year - minSignupAge, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - minSignupAge, now.month, now.day),
    );
    if (picked != null) {
      selectedDateOfBirth.value = picked;
    }
  }

  int _ageFromDateOfBirth(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> login() async {
    // Clear previous errors
    loginError.value = '';
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      loginError.value = 'Please fill all fields';
      return;
    }

    isLoading.value = true;
    try {
      // Get FCM token from Firebase Messaging Service or storage
      String? deviceToken;
      try {
        final firebaseMessagingService = FirebaseMessagingService.instance();
        deviceToken = firebaseMessagingService.fcmToken ?? _storage.getString('fcm_token');
        print('📱 Using FCM token for login: ${deviceToken != null ? "Token found" : "No token"}');
      } catch (e) {
        // Fallback to storage if service is not available
        deviceToken = _storage.getString('fcm_token');
        print('⚠️ Fallback to stored FCM token: ${deviceToken != null ? "Token found" : "No token"}');
      }
      
      // Call the login API
      final response = await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        deviceToken: deviceToken,
      );
       print(response);
      if (response['success'] == true) {
        print(response);
        loginError.value = '';
        await _storage.setBool('is_logged_in', true);
        await _storage.setString('auth_token', response['token']);
         await _storage.setString('user_id', (response['user']['id'] ?? '').toString());

        Get.offAllNamed(AppRoutes.HOME);
      } else {
        // Set error message when API response success is false
        final errorMessage = response['message'] ?? response['error'] ?? 'Login failed';
        print('⚠️ Login failed - success: false, message: $errorMessage');
        loginError.value = errorMessage;
        return;
      }
    } catch (e) {
      print('❌ Login exception caught: $e');
      String errorMessage = 'Login failed';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('Invalid email or password')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains("You don't have an account")) {
        errorMessage = "You don't have an account. Please sign up.";
      } else if (e.toString().contains('Account is deactivated')) {
        errorMessage = 'Account is deactivated';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      print('⚠️ Setting error message: $errorMessage');
      loginError.value = errorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    // Clear previous errors
    signupError.value = '';
    
    // Check if running on iOS
    final isIOS = Platform.isIOS;
    
    // For iOS users, phone, address, and country are optional
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      signupError.value = 'Please fill the name, email, password and confirm password fields';

      return;
    }

    if (selectedDateOfBirth.value == null) {
      signupError.value = 'Please select your date of birth';
      Get.snackbar(
        'error'.tr,
        'Please select your date of birth',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    final age = _ageFromDateOfBirth(selectedDateOfBirth.value!);
    if (age < minSignupAge) {
      signupError.value = 'You must be at least $minSignupAge years old to sign up';
      Get.snackbar(
        'error'.tr,
        'You must be at least $minSignupAge years old to sign up',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    // For non-iOS users, phone, address, and country are required
    if (!isIOS) {
      if (phoneController.text.isEmpty ||
          addressController.text.isEmpty ||
          selectedCountry.value.isEmpty) {
        signupError.value = 'Please fill all fields';
        Get.snackbar(
          'error'.tr,
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (!isTermsAccepted.value) {
      signupError.value = 'Please accept the terms and conditions';
      Get.snackbar(
        'error'.tr,
        'Please accept the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      signupError.value = 'Passwords do not match';
      Get.snackbar(
        'error'.tr,
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Call the signup API
      // For iOS users, pass empty strings as null if fields are empty
      final response = await ApiService.signup(
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        dateOfBirth: selectedDateOfBirth.value!.toIso8601String().split('T').first,
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        country: selectedCountry.value.isEmpty ? null : selectedCountry.value,
      );
   print(response);
      if (response['success'] == true) {
        signupError.value = '';
        Get.offAllNamed(AppRoutes.OTP);
      } else {
        final errorMsg = response['message'] ?? response['error'] ?? 'Signup failed';
        signupError.value = errorMsg;
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = 'Signup failed';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('already exist')) {
        errorMessage = 'An account with this email already exists';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      signupError.value = errorMessage;
      
      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp, {BuildContext? context}) async {
    if (otp.length != 4) {
      otpError.value = 'please_enter_otp'.tr;
      return;
    }

    otpCode.value = otp;
    otpError.value = '';
    isLoading.value = true;

    try {
      final response = await ApiService.verifyOtp(otp: otp);

      if (response['success'] == true) {
        // Show success snackbar before navigation if context is provided
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account has been created.Please log in'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Wait a bit for the snackbar to be visible before navigating
          await Future.delayed(const Duration(milliseconds: 500));
        }
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        otpError.value = response['message'] ?? 'invalid_otp'.tr;
      }
    } catch (e) {
      String errorMessage = 'otp_verification_failed'.tr;
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('Invalid') || e.toString().contains('invalid')) {
        errorMessage = 'invalid_otp'.tr;
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      otpError.value = errorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOTPForPasswordChange() async {
    // Clear previous errors
    checkEmailError.value = '';
    
    // Safely get email text
    String emailText;
    try {
      emailText = emailController.text;
    } catch (e) {
      checkEmailError.value = 'Please refresh and try again';
      return;
    }
    
    if (emailText.isEmpty) {
      checkEmailError.value = 'Please enter your email';
      Get.snackbar(
        'error'.tr,
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    // Basic email validation
    if (!emailText.contains('@')) {
      checkEmailError.value = 'Please enter a valid email address';
      Get.snackbar(
        'error'.tr,
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Call the API to send OTP for password change
      final response = await ApiService.sendOTPForPasswordChange(
        email: emailText.trim(),
      );

      if (response['success'] == true) {
        checkEmailError.value = '';
        
        // Get email from response or use the one sent
        final responseEmail = response['email'];
        
        // Save email to storage for use in reset password
        await _storage.setString('email', responseEmail);
        
        // Also update the email controller with the response email
        try {
          emailController.text = responseEmail;
        } catch (e) {
          // Controller might be disposed, but email is saved in storage
        }
        
        Get.snackbar(
          'success'.tr,
          'Email verified successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate directly to reset password view (email is saved in storage and controller)
        Future.delayed(const Duration(seconds: 1), () {
          Get.toNamed(AppRoutes.RESET_PASSWORD);
        });
      } else {
        final errorMsg = response['message'] ?? response['error'] ?? 'Failed to send OTP';
        checkEmailError.value = errorMsg;
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = 'Failed to send OTP';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('not found') || e.toString().contains('does not exist')) {
        errorMessage = 'No account found with this email address';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      checkEmailError.value = errorMessage;
      
      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> resendOtp() async {
  //   isLoading.value = true;
  //   try {
  //     final response = await ApiService.resendOtp();
  //
  //     if (response['success'] == true) {
  //       Get.snackbar(
  //         'success'.tr,
  //         'otp_resent'.tr,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //       _startResendTimer();
  //     } else {
  //       Get.snackbar(
  //         'error'.tr,
  //         response['message'] ?? 'failed_to_resend_otp'.tr,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Get.theme.colorScheme.error,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'error'.tr,
  //       'failed_to_resend_otp'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Get.theme.colorScheme.error,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void _startResendTimer() {
    resendTimer.value = 60; // 60 seconds
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> showTermsDialog() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getTerms();
      
      Widget contentWidget;
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        
        if (data is List) {
          // Handle array response - display all active terms
          final List<Map<String, dynamic>> terms = data
              .where((item) => item is Map<String, dynamic> && (item['isActive'] == true || item['isActive'] == null))
              .map((item) => item as Map<String, dynamic>)
              .toList();
          
          if (terms.isEmpty) {
            contentWidget = Text(
              'No terms and conditions available.',
              style: const TextStyle(fontSize: 14),
            );
          } else {
            // Build a formatted list of terms
            contentWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: terms.map((term) {
                final title = term['title']?.toString() ?? '';
                final content = term['content']?.toString() ?? '';
                final section = term['section']?.toString() ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (section.isNotEmpty)
                        Text(
                          section.toUpperCase().replaceAll('-', ' '),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      if (title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          content,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          }
        } else if (data is Map<String, dynamic>) {
          // Handle single object response
          final content = data['content'] ?? 
                         data['terms'] ?? 
                         data['description'] ?? 
                         data['text'] ?? 
                         '';
          contentWidget = Text(
            content.toString(),
            style: const TextStyle(fontSize: 14),
          );
        } else if (data is String) {
          contentWidget = Text(
            data,
            style: const TextStyle(fontSize: 14),
          );
        } else {
          contentWidget = Text(
            'Terms and conditions content not available.',
            style: const TextStyle(fontSize: 14),
          );
        }
      } else {
        contentWidget = Text(
          response['message']?.toString() ?? 'Terms and conditions content not available.',
          style: const TextStyle(fontSize: 14),
        );
      }

      Get.dialog(
        AlertDialog(
          title: Text('terms_and_conditions'.tr),
          content: SingleChildScrollView(
            child: contentWidget,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('close'.tr),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to load terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    // Clear previous errors
    resetPasswordError.value = '';
    
    // Safely get password values
    String passwordText;
    String confirmPasswordText;
    
    try {
      passwordText = passwordController.text;
      confirmPasswordText = confirmPasswordController.text;
    } catch (e) {
      resetPasswordError.value = 'Please refresh and try again';
      return;
    }
    
    // Get email from storage service
    final emailText = _storage.getString('email');
    
    if (emailText == null || emailText.isEmpty) {
      resetPasswordError.value = 'Email not found. Please start the password reset process again.';
      Get.snackbar(
        'error'.tr,
        'Email not found. Please start the password reset process again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }
    
    if (passwordText.isEmpty || confirmPasswordText.isEmpty) {
      resetPasswordError.value = 'Please fill all fields';
      Get.snackbar(
        'error'.tr,
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordText.length < 6) {
      resetPasswordError.value = 'Password must be at least 6 characters';
      Get.snackbar(
        'error'.tr,
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordText != confirmPasswordText) {
      resetPasswordError.value = 'Passwords do not match';
      Get.snackbar(
        'error'.tr,
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Call the reset password API - POST /change-password
      final response = await ApiService.changePasswordWithOTP(
        email: emailText,
        newPassword: passwordText,
      );

      if (response['success'] == true) {
        resetPasswordError.value = '';
        
        // Clear stored email (optional - you may want to keep it)
        // await _storage.remove('email');
        
        // Clear password fields
        try {
          passwordController.clear();
          confirmPasswordController.clear();
        } catch (e) {
          // Controllers might be disposed
        }
        
        Get.snackbar(
          'success'.tr,
          'Password updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed(AppRoutes.LOGIN);
        });
      } else {
        final errorMsg = response['message'] ?? response['error'] ?? 'Failed to reset password';
        resetPasswordError.value = errorMsg;
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = 'Failed to reset password';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      resetPasswordError.value = errorMessage;
      
      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }
}

