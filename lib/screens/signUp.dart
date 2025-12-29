import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/Theme/theme_cubit.dart';
import 'package:flutter_application_8/Theme/theme_state.dart';
import 'package:flutter_application_8/screens/welcomeScreen2.dart';
import 'package:flutter_application_8/services/signUp-serves.dart'
    show Signupserves;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _userType;
  final List<String> _userTypes = ['tenant', 'owner'];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _idImageFile;
  File? _profileImageFile;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static final RegExp _phoneRegExp = RegExp(r'^09[0-9]{8}$');

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    TextEditingController? controller,
    bool readOnly = false,
    String? errorText,
    required Color textColor,
    required Color fillColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: textColor.withOpacity(0.7)),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildUserTypeDropdown({
    required Color textColor,
    required Color fillColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _userType,
        decoration: InputDecoration(
          hintText: 'اختر نوع الحساب',
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.person_pin, color: textColor.withOpacity(0.7)),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
        items:
            _userTypes.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: textColor),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
        onChanged:
            _isLoading
                ? null
                : (newValue) {
                  setState(() {
                    _userType = newValue;
                  });
                },
        dropdownColor: fillColor,
        icon: Icon(Icons.arrow_drop_down, color: textColor.withOpacity(0.7)),
        isExpanded: true,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: darkTextColor,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage(bool isIdImage, {bool fromCamera = false}) async {
    if (_isLoading) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image != null) {
        setState(() {
          if (isIdImage)
            _idImageFile = File(image.path);
          else
            _profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء اختيار الصورة');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String? _validateForm() {
    if (_firstNameController.text.trim().isEmpty)
      return 'الرجاء إدخال الاسم الأول';
    if (_lastNameController.text.trim().isEmpty)
      return 'الرجاء إدخال اسم العائلة';
    if (_userType == null) return 'الرجاء اختيار نوع الحساب';
    if (_phoneController.text.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
    if (!_phoneRegExp.hasMatch(_phoneController.text.trim()))
      return 'رقم الهاتف غير صحيح (09XXXXXXXX)';
    if (_passwordController.text.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (_passwordController.text.length < 8)
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (_confirmPasswordController.text.isEmpty)
      return 'الرجاء تأكيد كلمة المرور';
    if (_passwordController.text != _confirmPasswordController.text)
      return 'كلمات المرور غير متطابقة';
    if (_dateController.text.isEmpty) return 'الرجاء اختيار تاريخ الميلاد';
    if (_idImageFile == null) return 'الرجاء تحميل صورة الهوية الوطنية';
    if (_profileImageFile == null) return 'الرجاء تحميل صورة شخصية';
    return null;
  }

  Widget _buildImageUploadArea(
    String title,
    IconData icon,
    bool isIdImage,
    Color textColor,
    Color fillColor,
  ) {
    final imageFile = isIdImage ? _idImageFile : _profileImageFile;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 10),
              Icon(icon, color: textColor.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 10),
          if (imageFile != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                setState(() {
                                  if (isIdImage)
                                    _idImageFile = null;
                                  else
                                    _profileImageFile = null;
                                });
                              },
                      icon: Icon(
                        Icons.delete,
                        color:
                            _isLoading
                                ? Colors.red.withOpacity(0.5)
                                : Colors.red,
                      ),
                      label: Text(
                        'حذف',
                        style: TextStyle(
                          color:
                              _isLoading
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed:
                          _isLoading ? null : () => _pickImage(isIdImage),
                      icon: Icon(
                        Icons.edit,
                        color:
                            _isLoading
                                ? buttonColor.withOpacity(0.5)
                                : buttonColor,
                      ),
                      label: Text(
                        'تغيير',
                        style: TextStyle(
                          color:
                              _isLoading
                                  ? buttonColor.withOpacity(0.5)
                                  : buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _pickImage(isIdImage),
              icon: Icon(
                Icons.upload_file,
                color: _isLoading ? buttonColor.withOpacity(0.5) : buttonColor,
              ),
              label: Text(
                'اختر صورة',
                style: TextStyle(
                  color:
                      _isLoading ? buttonColor.withOpacity(0.5) : buttonColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color:
                      _isLoading
                          ? buttonColor.withOpacity(0.3)
                          : buttonColor.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final validationError = _validateForm();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Signupserves.Signup(
        context,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
        _dateController.text,
        _userType!,
        _idImageFile!,
        _profileImageFile!,
      );

      if (response != null && response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الحساب بنجاح كـ $_userType'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen2()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء إنشاء الحساب');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSubmitButton(Color textColor, Color buttonBg) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSignUp(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child:
          _isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'جاري التسجيل...',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              )
              : Text(
                'إنشاء حساب جديد',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        bool isDark = state is DarkState;

        Color backgroundColor =
            isDark ? Colors.grey[900]! : primaryBackgroundColor;
        Color cardColor = isDark ? Colors.grey[800]! : cardBackgroundColor;
        Color textColor = isDark ? Colors.white : darkTextColor;
        Color inputFillColor = isDark ? Colors.grey[700]! : Colors.white;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.35,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 40,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color:
                                        _isLoading
                                            ? Colors.white.withOpacity(0.5)
                                            : accentColor,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'العودة لتسجيل الدخول',
                                    style: TextStyle(
                                      color:
                                          _isLoading
                                              ? buttonColor.withOpacity(0.5)
                                              : buttonColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.home_work,
                                  size: 150,
                                  color:
                                      _isLoading
                                          ? accentColor.withOpacity(0.7)
                                          : accentColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'أدخل بياناتك',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 30),
                            _buildInputField(
                              hintText: 'الاسم الأول',
                              icon: Icons.person,
                              controller: _firstNameController,
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: 'اسم العائلة',
                              icon: Icons.person_outline,
                              controller: _lastNameController,
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildUserTypeDropdown(
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: 'رقم الهاتف (09XXXXXXXX)',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: 'كلمة المرور (8 أحرف على الأقل)',
                              icon: Icons.lock,
                              isPassword: true,
                              controller: _passwordController,
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: 'تأكيد كلمة المرور',
                              icon: Icons.lock,
                              isPassword: true,
                              controller: _confirmPasswordController,
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              hintText: 'تاريخ الميلاد (YYYY/MM/DD)',
                              icon: Icons.calendar_today,
                              controller: _dateController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              textColor: textColor,
                              fillColor: inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildImageUploadArea(
                              'صورة الهوية الوطنية (أمامية)',
                              Icons.credit_card,
                              true,
                              textColor,
                              inputFillColor,
                            ),
                            const SizedBox(height: 20),
                            _buildImageUploadArea(
                              'صورة شخصية (للملف الشخصي)',
                              Icons.camera_alt,
                              false,
                              textColor,
                              inputFillColor,
                            ),
                            const SizedBox(height: 30),
                            _buildSubmitButton(Colors.white, accentColor),
                          ],
                        ),
                      ),
                    ],
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
        );
      },
    );
  }
}
