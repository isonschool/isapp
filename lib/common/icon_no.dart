import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class IconNo {
  static IconData iconData(int no) {
    switch (no) {
      case 1:
        return Mdi.numeric1Box;
      case 2:
        return Mdi.numeric2Box;
      case 3:
        return Mdi.numeric3Box;
      case 4:
        return Mdi.numeric4Box;
      case 5:
        return Mdi.numeric5Box;
      case 6:
        return Mdi.numeric6Box;
      case 7:
        return Mdi.numeric7Box;
      case 8:
        return Mdi.numeric8Box;
      case 9:
        return Mdi.numeric9Box;
    }
    return Mdi.numeric9PlusBox;
  }

  static String alphabet(int no) {
    return '-ABCDEFGHIJKL'[no];
  }

  static IconData alphabetIconData(int no) {
    switch (no) {
      case 1:
        return Mdi.alphaA;
      case 2:
        return Mdi.alphaB;
      case 3:
        return Mdi.alphaC;
      case 4:
        return Mdi.alphaD;
      case 5:
        return Mdi.alphaE;
      case 6:
        return Mdi.alphaF;
      case 7:
        return Mdi.alphaG;
      case 8:
        return Mdi.alphaH;
      case 9:
        return Mdi.alphaI;
      case 10:
        return Mdi.alphaJ;
      case 11:
        return Mdi.alphaK;
      case 12:
        return Mdi.alphaL;
    }
    return Mdi.circle;
  }

  static IconData alphabetCircleIconData(int no) {
    switch (no) {
      case 0:
        return Mdi.alphaACircleOutline;
      case 1:
        return Mdi.alphaBCircleOutline;
      case 2:
        return Mdi.alphaCCircleOutline;
      case 3:
        return Mdi.alphaDCircleOutline;
      case 4:
        return Mdi.alphaECircleOutline;
      case 5:
        return Mdi.alphaFCircleOutline;
      case 6:
        return Mdi.alphaGCircleOutline;
      case 7:
        return Mdi.alphaHCircleOutline;
      case 8:
        return Mdi.alphaICircleOutline;
      case 9:
        return Mdi.alphaJCircleOutline;
      case 10:
        return Mdi.alphaKCircleOutline;
      case 11:
        return Mdi.alphaLCircleOutline;
    }
    return Mdi.circle;
  }
}
