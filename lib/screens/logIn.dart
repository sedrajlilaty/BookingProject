import 'package:flutter/material.dart';
import 'package:flutter_application_8/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';

// import 'package:flutter_application_8/screens/owner/AddApartement.dart';
import 'package:flutter_application_8/main_navigation_screen.dart';
import 'package:flutter_application_8/screens/signUp.dart';
import 'package:flutter_application_8/services/logIn_serves.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Future<void> saveToken(String token) async {
  // Add these constants at the top
  const String kToken = 'auth_token';
  const String kIsLoggedIn = 'is_logged_in';

  try {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    await prefs.setString(kToken, token);

    // Save login status
    await prefs.setBool(kIsLoggedIn, true);

    // ✅ Save time to track token validity
    await prefs.setString('token_saved_at', DateTime.now().toIso8601String());

    print('✅ Token saved successfully: ${token.substring(0, 20)}...');
    print('📅 Save time: ${DateTime.now()}');

    // Verify save
    final savedToken = prefs.getString(kToken);
    if (savedToken == token) {
      print('✅ Verification: Token saved correctly');
    } else {
      print('❌ Verification: There is a problem saving the token');
    }
  } catch (e) {
    print('❌ Error saving token: $e');
    rethrow;
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _userType;
  final List<String> _userTypes = ['tenant', 'owner'];
  bool _isLoading = false;
  static final RegExp _phoneRegExp = RegExp(r'^09[0-9]{8}$');

  String? _validateForm() {
    if (_phoneController.text.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!_phoneRegExp.hasMatch(_phoneController.text.trim())) {
      return 'Phone number is incorrect (must start with 09 and consist of 10 digits)';
    }

    if (_passwordController.text.isEmpty) {
      return 'Please enter password';
    }
    if (_passwordController.text.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (_userType == null) {
      return 'Please select account type';
    }

    return null;
  }

  Future<void> _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final validationError = _validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setLoading(true);
    setState(() => _isLoading = true);

    try {
      print('📞 Logging in...');
      print('📱 Phone number: ${_phoneController.text}');
      print('🔑 Account type: $_userType');

      // Call login service
      final response = await LoginServes.logIn(
        context,
        _phoneController.text,
        _passwordController.text,
        _userType!,
      );

      print('✅ Response status: ${response?.statusCode}');
      print('📥 Server response: ${response?.data}');

      if (response == null) {
        throw Exception('Failed to connect to server');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Login failed: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      print('✅ Received data: $data');

      final message = data['message'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      final token = data['token'] as String?;

      // ⚠️ **Verify basic data**
      if (token == null || token.isEmpty) {
        print('❌ token is null or empty');
        throw Exception('No authentication token in response');
      }

      if (userData == null) {
        print('❌ userData is null');
        throw Exception('No user data in response');
      }

      print('🔐 Token received: ${token.substring(0, 20)}...');
      print('👤 User data: $userData');

      // ✅ **1. Save token using saveToken**
      await saveToken(token);

      // ✅ **2. Update AuthProvider**
      String baseUrl = 'http://192.168.137.101:8000';
      String? profileImageUrl;
      String? idImageUrl;

      if (userData['personal_image'] != null) {
        profileImageUrl = '$baseUrl/storage/${userData['personal_image']}';
        print('🖼️ Profile image URL: $profileImageUrl');
      }

      if (userData['national_id_image'] != null) {
        idImageUrl = '$baseUrl/storage/${userData['national_id_image']}';
        print('🆔 ID image URL: $idImageUrl');
      }

      // Extract data
      await authProvider.login(
        userId: userData['id']?.toString() ?? '0',
        firstName: userData['name']?.toString() ?? '',
        lastName: userData['last_name']?.toString() ?? '',
        phone: userData['phone']?.toString() ?? _phoneController.text,
        email:
            userData['email']?.toString() ??
            '${_phoneController.text}@temp.com',
        userType: userData['account_type']?.toString() ?? _userType!,
        birthDate: userData['birthdate']?.toString() ?? '',
        personalImage: profileImageUrl,
        idImageUrl: idImageUrl,
        token: token,
      );

      // ✅ **3. Show success message**
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Login successful'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // ✅ **4. Navigate after confirming save**
      // Wait a bit to ensure data is saved
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify token save
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(kToken);

      if (savedToken == token) {
        print('✅ Final verification: Token saved and ready for use');

        final accountType = userData['account_type']?.toString() ?? _userType!;
        print('🎯 Account type for navigation: $accountType');

        // Navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MainNavigationScreen(isOwner: accountType == 'owner'),
          ),
        );
      } else {
        throw Exception('Failed to save token permanently');
      }
    } on FormatException catch (e) {
      print('❌ Data format error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data format error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception catch (e) {
      print('❌ General error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      authProvider.setLoading(false);
      setState(() => _isLoading = false);
    }
  }

  Widget _buildUserTypeDropdown() {
        final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _userType,
        decoration: InputDecoration(
          hintText: loc.selectAccountType,
          hintStyle: TextStyle(color: darkTextColor.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.person_pin,
            color: darkTextColor.withOpacity(0.7),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        items:
            _userTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'owner' ? loc.owner : loc.tenant,
                  style: const TextStyle(color: darkTextColor),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
        onChanged:
            _isLoading
                ? null
                : (String? newValue) {
                  setState(() {
                    _userType = newValue;
                  });
                },
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: darkTextColor.withOpacity(0.7),
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: !_isLoading,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: darkTextColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: darkTextColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: TextStyle(
        color: darkTextColor,
        decoration: _isLoading ? TextDecoration.none : null,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleLogin(context),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isLoading ? accentColor.withOpacity(0.7) : accentColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child:
          _isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loc.loggingIn,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              )
              :  Text(
                loc.login,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final loc = AppLocalizations.of(context)!;
    _isLoading = authProvider.isLoading;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF005F73),
                Color(0xFF005F73),
                Color(0xFF005F73),
                Color(0xFFF1F3F5),

                Color(0xFFF1F3F5),
                Color(0xFFF1F3F5),
                Color(0xFF005F73),
                Color(0xFF005F73),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                    minWidth: screenWidth,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.35,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 40,
                        ),
                        alignment: Alignment.bottomRight,
                        decoration: const BoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons.home_work,
                              size: 150,
                              color: cardBackgroundColor,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: screenHeight * 0.65,
                        ),
                        decoration: const BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loc.login,
                              style: TextStyle(
                                color: darkTextColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 30),
                            _buildUserTypeDropdown(),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: loc.phoneNumber,
                              icon: Icons.phone,
                              controller: _phoneController,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: loc.enterPassword,
                              icon: Icons.lock,
                              isPassword: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () {
                                          print(loc.forgotPassword);
                                        },
                                child: Text(
                                  loc.forgotPassword,
                                  style: TextStyle(
                                    color:
                                        _isLoading
                                            ? darkTextColor.withOpacity(0.3)
                                            : darkTextColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildLoginButton(context),
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    loc.dontHaveAccount,
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? darkTextColor.withOpacity(0.3)
                                              : darkTextColor.withOpacity(0.7),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const SignUpScreen(),
                                                ),
                                              );
                                            },
                                    child: Text(
                                      loc.createAccount,
                                      style: TextStyle(
                                        color:
                                            _isLoading
                                                ? accentColor.withOpacity(0.5)
                                                : accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
