import 'package:dotted_border/dotted_border.dart' show DottedBorder;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DottedContainerAddImagesWidget extends StatelessWidget {
  final void Function() function;
  const DottedContainerAddImagesWidget({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      child: InkWell(
        onTap: function,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 50.w,
          height: 18.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withOpacity(0.05),
                Colors.grey.withOpacity(0.15),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_outlined,
                size: 10.w,
                color: Colors.black.withOpacity(0.7),
              ),
              SizedBox(height: 2.h),
              Text(
                "Upload photos",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
