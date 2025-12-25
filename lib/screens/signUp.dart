import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/providers/authoProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_8/screens/welcomeScreen2.dart';
import 'package:flutter_application_8/services/signUp-serves.dart' show Signupserves;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants.dart';
import '../Theme/theme_cubit.dart';
import '../Theme/theme_state.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
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
    required Color iconColor,
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
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildUserTypeDropdown(Color textColor, Color fillColor) {
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        items: _userTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value == 'owner' ? 'مالك' : 'مستأجر',
              style: TextStyle(color: textColor),
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: _isLoading
            ? null
            : (String? newValue) {
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
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: darkTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}/${picked.month}/${picked.day}";
      });
    }
  }

  Future<void> _pickImage(bool isIdImage) async {
    if (_isLoading) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
      if (image != null) {
        setState(() {
          if (isIdImage) _idImageFile = File(image.path);
          else _profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء اختيار الصورة');
    }
  }

  Future<void> _takePhoto(bool isIdImage) async {
    if (_isLoading) return;
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 800);
      if (photo != null) {
        setState(() {
          if (isIdImage) _idImageFile = File(photo.path);
          else _profileImageFile = File(photo.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء التقاط الصورة');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _showImagePickerOptions(bool isIdImage) async {
    if (_isLoading) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.black54),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(isIdImage);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.black54),
                  title: const Text('التقاط صورة'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(isIdImage);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('إلغاء'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageUploadArea(String title, IconData icon, bool isIdImage, Color textColor, Color fillColor) {
    final imageFile = isIdImage ? _idImageFile : _profileImageFile;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: textColor.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text(title, style: TextStyle(color: textColor, fontSize: 16), textAlign: TextAlign.right), const SizedBox(width: 10), Icon(icon, color: textColor.withOpacity(0.7))],
          ),
          const SizedBox(height: 10),
          if (imageFile != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 150, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading ? null : () => setState(() => isIdImage ? _idImageFile = null : _profileImageFile = null),
                      icon: Icon(Icons.delete, color: _isLoading ? Colors.red.withOpacity(0.5) : Colors.red),
                      label: Text('حذف', style: TextStyle(color: _isLoading ? Colors.red.withOpacity(0.5) : Colors.red)),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: _isLoading ? null : () => _showImagePickerOptions(isIdImage),
                      icon: Icon(Icons.edit, color: _isLoading ? accentColor.withOpacity(0.5) : accentColor),
                      label: Text('تغيير', style: TextStyle(color: _isLoading ? accentColor.withOpacity(0.5) : accentColor)),
                    ),
                  ],
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _showImagePickerOptions(isIdImage),
              icon: Icon(Icons.upload_file, color: _isLoading ? accentColor.withOpacity(0.5) : accentColor),
              label: Text('اختر صورة', style: TextStyle(color: _isLoading ? accentColor.withOpacity(0.5) : accentColor)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: _isLoading ? accentColor.withOpacity(0.3) : accentColor.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    _isLoading = authProvider.isLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is DarkState;
        final backgroundColor = isDark ? Colors.grey[900]! : primaryBackgroundColor;
        final cardColor = isDark ? Colors.grey[800]! : Colors.white;
        final textColor = isDark ? Colors.white : darkTextColor;

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
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                                  icon: Icon(Icons.arrow_forward_ios, color: accentColor, size: 18),
                                  label: Text('العودة لتسجيل الدخول', style: TextStyle(color: accentColor, fontSize: 16)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Icon(Icons.home_work, size: 150, color: accentColor)],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                        ),
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('أدخل بياناتك', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                            const SizedBox(height: 30),
                            _buildInputField(hintText: 'الاسم الأول', icon: Icons.person, controller: _firstNameController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildInputField(hintText: 'اسم العائلة', icon: Icons.person_outline, controller: _lastNameController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildUserTypeDropdown(textColor, cardColor),
                            const SizedBox(height: 20),
                            _buildInputField(hintText: 'رقم الهاتف (09XXXXXXXX)', icon: Icons.phone, keyboardType: TextInputType.phone, controller: _phoneController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildInputField(hintText: 'كلمة المرور (8 أحرف على الأقل)', icon: Icons.lock, isPassword: true, controller: _passwordController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildInputField(hintText: 'تأكيد كلمة المرور', icon: Icons.lock, isPassword: true, controller: _confirmPasswordController, textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildInputField(controller: _dateController, hintText: 'تاريخ الميلاد (YYYY/MM/DD)', icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context), textColor: textColor, fillColor: cardColor, iconColor: textColor),
                            const SizedBox(height: 20),
                            _buildImageUploadArea('صورة الهوية الوطنية (أمامية)', Icons.credit_card, true, textColor, cardColor),
                            const SizedBox(height: 20),
                            _buildImageUploadArea('صورة شخصية (للملف الشخصي)', Icons.camera_alt, false, textColor, cardColor),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _isLoading ? null : () {},
                              style: ElevatedButton.styleFrom(backgroundColor: accentColor, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2))
                                  : const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
