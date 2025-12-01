import 'package:flutter/material.dart';
import 'constants.dart';
// يجب أن يكون لديك ملف constants.dart في نفس المستوى أو مسار صحي

// ----------------------------------------------------
// 2. شاشة إنشاء حساب (Sign Up Screen)
// ----------------------------------------------------
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  // دالة مساعدة لإنشاء حقول الإدخال
  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap, // للسماح بالنقر لفتح منتقي التاريخ مثلاً
    TextEditingController? controller, // للتحكم بقيمة الحقل
    bool readOnly = false, // لمنع الكتابة المباشرة (مثل حقل التاريخ)
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textAlign: TextAlign.right, // محاذاة النص المدخل لليمين
      onTap: onTap,
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
      ),
      style: const TextStyle(color: darkTextColor),
    );
  }

  // دالة لاختيار التاريخ (يمكن أن تكون في حالة (Stateful) ولكن نضعها هنا للاختصار)
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  primaryBackgroundColor, // لون الخلفية الرئيسية كـ Primary
              onPrimary: accentColor, // لون النص على Primary كـ Accent
              onSurface: darkTextColor, // لون النص على السطح
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // تنسيق التاريخ ووضعه في المتحكم (Controller)
      controller.text = "${picked.year}/${picked.month}/${picked.day}";
    }
  }

  // دالة مساعدة لإنشاء منطقة تحميل الصور
  Widget _buildImageUploadArea(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkTextColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(color: darkTextColor, fontSize: 16),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 10),
              Icon(icon, color: darkTextColor.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: إضافة منطق تحميل الصورة
            },
            icon: const Icon(Icons.upload_file, color: buttonColor),
            label: const Text('اختر ملف', style: TextStyle(color: buttonColor)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: buttonColor.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // متحكم (Controller) لحقل تاريخ الميلاد
    final dateController = TextEditingController();

    // يجب تفعيل اتجاه النص من اليمين لليسار (RTL) هنا
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // الجزء العلوي مع التاج وعبارة "إنشاء حساب"
              Container(
                height: screenHeight * 0.35, // تقليل الارتفاع قليلاً
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // زر العودة للخلف
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // العودة للشاشة السابقة (Login)
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'العودة لتسجيل الدخول',
                          style: TextStyle(color: buttonColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // أيقونة التاج (تم استبدال Image.asset)
                    Icon(
                      Icons.house_rounded, // أو Icons.home
                      size: 120,
                      color: accentColor, // لون ذهبي #DDA15E
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // البطاقة السفلية (Sign Up Form)
              Container(
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
                  children: [
                    const Text(
                      'أدخل بياناتك',
                      style: TextStyle(
                        color: darkTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 30),

                    // الاسم الأول
                    _buildInputField(
                      hintText: 'الاسم الأول',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),

                    // الاسم الأخير
                    _buildInputField(
                      hintText: 'اسم العائلة',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // حقل البريد الإلكتروني
                    _buildInputField(
                      hintText: 'البريد الإلكتروني',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // حقل كلمة المرور
                    _buildInputField(
                      hintText: 'كلمة المرور',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    // حقل تأكيد كلمة المرور
                    _buildInputField(
                      hintText: 'تأكيد كلمة المرور',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    // تاريخ الميلاد (Read-Only مع خاصية onTap لفتح منتقي التاريخ)
                    _buildInputField(
                      controller: dateController,
                      hintText: 'تاريخ الميلاد (YYYY/MM/DD)',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context, dateController),
                    ),
                    const SizedBox(height: 20),

                    // صورة الهوية
                    _buildImageUploadArea(
                      'صورة الهوية الوطنية (أمامية)',
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 20),

                    // صورة شخصية
                    _buildImageUploadArea(
                      'صورة شخصية (للملف الشخصي)',
                      Icons.camera_alt,
                    ),
                    const SizedBox(height: 30),

                    // زر إنشاء حساب
                    ElevatedButton(
                      onPressed: () {
                        // منطق إنشاء الحساب والتحقق من صحة البيانات
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // لون الزر أغمق
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
