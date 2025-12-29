import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../cubit/appartment_cubit_cubit.dart';
import 'edit_or_delete_box_widget.dart';



class ListOfImage extends StatelessWidget {
  final List<dynamic> images;
  final AppartmentCubit appartmentCubit;
  const ListOfImage(
      {super.key, required this.images, required this.appartmentCubit});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          childAspectRatio: 1.2),
      itemCount: images.length,
      itemBuilder: (context, index) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.w),
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 18.h,
              width: 45.w,
              child: Image.file(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 1.h,
            left: 1.h,
            child: EditOrDeleteBoxWidget(
              iconColor: Colors.white,
              iconData: Icons.delete_rounded,
              onTap: () {
                appartmentCubit.removeImageFromList(
                  index: index,
                  imageId: appartmentCubit.images[index] is File
                      ? -1
                      : appartmentCubit.images[index].id,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
