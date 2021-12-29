import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:roman/services/constants.dart';

class StandartButton extends StatelessWidget {
  const StandartButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.color = colorGrey,
  }) : super(key: key);

  final String label;
  final Function() onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({
    Key? key,
    required this.label,
    required this.child,
    this.width,
    this.height = 300,
    this.popoverDirection = PopoverDirection.left,
  }) : super(key: key);

  final String label;
  final Widget child;

  final double? width;
  final double height;
  final PopoverDirection popoverDirection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: StandartButton(
        label: label,
        onTap: () => showPopover(
          context: context,
          width: width,
          height: height,
          direction: popoverDirection,
          bodyBuilder: (context) {
            return child;
          },
        ),
      ),
    );
  }
}
