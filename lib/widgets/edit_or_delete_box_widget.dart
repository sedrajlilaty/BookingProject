import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EditOrDeleteBoxWidget extends StatelessWidget {
  final IconData iconData;
  final double iconSize, backgroundColorOpacity;
  final Color iconColor, backgroundColor;
  final double boxH, boxW, radius, elevation;
  final void Function() onTap;
  const EditOrDeleteBoxWidget({super.key, 
    required this.iconData,
    required this.onTap,
    required this.iconColor,
    this.iconSize = 15,
    this.boxH = 3.5,
    this.boxW = 3.4,
    this.backgroundColorOpacity = 0.5,
    this.radius = 1.5,
    this.backgroundColor = Colors.black,
    this.elevation = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(radius.w),
      color: Colors.transparent,
      elevation: elevation,
      child: Container(
        width: boxW.h,
        height: boxH.h,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(backgroundColorOpacity),
          borderRadius: BorderRadius.circular(radius.w),
        ),
        alignment: Alignment.center,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius.w),
          child: Icon(
            iconData,
            color: iconColor,
            size: iconSize.sp,
          ),
        ),
      ),
    );
  }
}
