import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BaseButton extends StatefulWidget {
  final Function() callback;
  final String text;
  const BaseButton({super.key, required this.callback, required this.text});

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: SizedBox(
        width: 70.w,
        height: 5.h,
        child: ElevatedButton(
          onPressed: widget.callback,
          child: Text(widget.text),
        ),
      ),
    );
  }
}
