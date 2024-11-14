import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFiled extends StatefulWidget {
  const TextFiled({
    super.key,
    required this.controller,
    required this.icon,
    required this.type,
    required this.focusNode,
    required this.isPassword,
  });

  final TextEditingController controller;
  final IconData icon;
  final String type;
  final FocusNode focusNode;
  final bool isPassword;

  @override
  _TextFiledState createState() => _TextFiledState();
}

class _TextFiledState extends State<TextFiled> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: TextField(
          style: TextStyle(fontSize: 18.sp, color: Colors.black),
          obscureText: widget.isPassword && isObscure,
          controller: widget.controller,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: widget.type,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
            prefixIcon: Icon(
              widget.icon,
              color: widget.focusNode.hasFocus ? Colors.black : Colors.grey,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: Colors.grey, width: 2.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: Colors.grey, width: 2.w),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: isObscure
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () => setState(() {
                      isObscure = !isObscure;
                    }),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
