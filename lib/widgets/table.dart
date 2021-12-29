import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:roman/services/constants.dart';

class BottomTable extends StatelessWidget {
  const BottomTable({
    Key? key,
    required this.page,
    required this.firstPage,
    required this.prePage,
    required this.nextPage,
    required this.lastPage,
  }) : super(key: key);

  final int page;
  final Function() firstPage;
  final Function() prePage;
  final Function() nextPage;
  final Function() lastPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: radius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: firstPage,
            icon: const Icon(LineIcons.angleDoubleLeft),
          ),
          IconButton(
            onPressed: prePage,
            icon: const Icon(LineIcons.angleLeft),
          ),
          Text(
            page.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: nextPage,
            icon: const Icon(LineIcons.angleRight),
          ),
          IconButton(
            onPressed: lastPage,
            icon: const Icon(LineIcons.angleDoubleRight),
          ),
        ],
      ),
    );
  }
}
