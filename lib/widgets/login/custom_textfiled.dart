import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFiled extends StatefulWidget {
  const CustomTextFiled({
    super.key,
    required this.controller,
    required this.icon,
    required this.type,
    required this.focusNode,
    required this.isPassword,
    required this.validator,
  });

  final TextEditingController controller;
  final IconData icon;
  final String type;
  final FocusNode focusNode;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  _CustomTextFiledState createState() => _CustomTextFiledState();
}

class _CustomTextFiledState extends State<CustomTextFiled> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            validator: widget.validator,
            style: TextStyle(fontSize: 18.sp, color: Colors.black),
            obscureText: widget.isPassword && isObscure,
            controller: widget.controller,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
                borderSide: BorderSide(color: Colors.red, width: 2.w),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
                borderSide: BorderSide(color: Colors.red, width: 2.w),
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
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12.sp,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
