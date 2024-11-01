import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgFromCodeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Código SVG como string
    const String svgCode = '''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
    </svg>
    ''';

    return Scaffold(
      appBar: AppBar(
        title: Text('SVG from Code'),
      ),
      body: Center(
        child: SvgPicture.string(
          svgCode, // Passa o código SVG como string
          height: 200.0,
          width: 200.0,
        ),
      ),
    );
  }
}
