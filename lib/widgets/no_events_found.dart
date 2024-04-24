import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoEventsFound extends StatelessWidget {
  const NoEventsFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            'lib/images/no_results_found.svg',
            semanticsLabel: 'No Events Found',
            height: size.height - 500,
            width: size.width,
          ),
          const Text(
            'No Events Found',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
