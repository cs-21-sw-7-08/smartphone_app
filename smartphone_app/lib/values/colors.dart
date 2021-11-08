import 'dart:ui';

import 'package:flutter/material.dart';

const Color blue = Color(0xFF0067B0);
const Color lightBlue = Color(0xFF00AEEF);
const Color orange_1 = Color(0xFFF58220);
const Color orange_2 = Color(0xFFFFA500);
const Color transparent = Color(0x00000000);
const Color transparentWhite = Color(0x20FFFFFF);
const Color black = Color(0xFF202020);

const Color appBarColor = Color(0xFF202020);
const Color borderColor = Color(0xFF202020);
const Color appSafeAreaColor = Color(0xFF202020);

const Color yellow1 = Color(0xFFFFE87C);
const Color yellow2 = Color(0xFFFFDB58);

const Color yellowWhite1 = Color(0xFFFCFCEF);
const Color grey1 = Color(0xFFF0F0F0);

const LinearGradient loginBackground = LinearGradient(
    colors: <Color>[yellowWhite1, yellowWhite1],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const LinearGradient appBarBackground = LinearGradient(
    colors: <Color>[appBarColor, appBarColor],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));

const Gradient whiteGradient = LinearGradient(
    colors: <Color>[Colors.white, Colors.white],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient greyGradient = LinearGradient(
    colors: <Color>[grey1, grey1],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient orangeGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[orange_1, orange_2],
);

const Gradient buttonGradientDefault = LinearGradient(
    colors: <Color>[lightBlue, blue],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient buttonGradientDefault2 = LinearGradient(
    colors: <Color>[black, black],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0));
const Gradient buttonGradientPressedDefault = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[orange_1, orange_2],
);
const Gradient transparentGradient = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[transparent, transparent],
);
const Gradient backButtonGradientPressedDefault = LinearGradient(
  begin: Alignment(0.0, -1.0),
  end: Alignment(0.0, 1.0),
  colors: <Color>[transparentWhite, transparentWhite],
);