import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required TextEditingController controller,
      required String hintText,
      bool isPasswordField = false,
      InputBorder? inputBorder,
      BorderSide? outlineBorderSide,
      Widget? prefixIcon})
      : _controller = controller,
        _hintText = hintText,
        _isPasswordField = isPasswordField,
        _prefixIcon = prefixIcon,
        _inputBorder = inputBorder,
        _outlineBorderSide = outlineBorderSide;
  final TextEditingController _controller;
  final String _hintText;
  final bool _isPasswordField;
  final Widget? _prefixIcon;
  final InputBorder? _inputBorder;
  final BorderSide? _outlineBorderSide;

  @override
  Widget build(BuildContext context) {
    bool obsecureText = _isPasswordField;
    return SizedBox(
      width: 300.w,
      height: 51.h,
      // margin: EdgeInsets.symmetric(
      //     horizontal: MediaQuery.sizeOf(context).width * 0.07),
      child: StatefulBuilder(builder: (context, setState) {
        return TextField(
          obscureText: obsecureText,
          controller: _controller,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
              prefixIcon: _prefixIcon,
              suffixIcon: _isPasswordField
                  ? IconButton(
                      onPressed: () {
                        setState(
                          () {
                            obsecureText = !obsecureText;
                          },
                        );
                      },
                      icon: Icon(obsecureText
                          ? Icons.visibility_off
                          : Icons.visibility))
                  : null,
              hintText: _hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0XFF252525),
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0XFFFDF9F9),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              border: _inputBorder ??
                  OutlineInputBorder(
                    borderSide: _outlineBorderSide ?? BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  )),
        );
      }),
    );
  }
}
