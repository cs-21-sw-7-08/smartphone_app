import 'package:flutter/material.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

import 'custom_button.dart';

class ImageFullScreenWrapper extends StatelessWidget {
  final Image child;

  const ImageFullScreenWrapper({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenPage(
                child: child
              );
            },
          ),
        );
      },
      child: Align(child: child, alignment: Alignment.center),
    );
  }
}

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({
    Key? key,
    required this.child
  }) : super(key: key);

  final Image child;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: custom_colors.black,
      body: Stack(
        children: [
          Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: widget.child,
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: CustomButton(
                  height: 44,
                  width: 44,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  imagePadding: const EdgeInsets.all(10),
                  showBorder: false,
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                  defaultBackground: custom_colors.transparentGradient,
                  pressedBackground:
                  custom_colors.backButtonGradientPressedDefault,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop()),
            ),
          ),
        ],
      ),
    );
  }
}
