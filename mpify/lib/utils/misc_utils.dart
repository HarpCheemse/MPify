import 'package:flutter/material.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';

import 'package:top_snackbar_flutter/top_snack_bar.dart';

class MiscUtils {
  static void showNotification(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      FolderUtils.writeLog('Error: Main App Context Is Null. Unable To Show Notification');
      return;
    }
    showTopSnackBar(Overlay.of(context), Material(
      color: Colors.transparent,
      child: Align(
        child: Container(
          width: 800,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 24, 24, 24),
          ),
          child: Center(child: Text(message, style: montserratStyle(),)),
        ),
      ),
    ));
  }
  static void showError(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      FolderUtils.writeLog('Error: Main App Context Is Null. Unable To Show Notification');
      return;
    }
    showTopSnackBar(Overlay.of(context), Material(
      color: Colors.transparent,
      child: Align(
        child: Container(
          width: 800,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(164, 177, 41, 41),
          ),
          child: Center(child: Text(message, style: montserratStyle(),)),
        ),
      ),
    ));
  }
  static void showSuccess(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      FolderUtils.writeLog('Error: Main App Context Is Null. Unable To Show Notification');
      return;
    }
    showTopSnackBar(Overlay.of(context), Material(
      color: Colors.transparent,
      child: Align(
        child: Container(
          width: 800,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(166, 2, 132, 12),
          ),
          child: Center(child: Text(message, style: montserratStyle(),)),
        ),
      ),
    ));
  }
  static void showWarning(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      FolderUtils.writeLog('Error: Main App Context Is Null. Unable To Show Notification');
      return;
    }
    showTopSnackBar(Overlay.of(context), Material(
      color: Colors.transparent,
      child: Align(
        child: Container(
          width: 800,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(218, 150, 138, 0),
          ),
          child: Center(child: Text(message, style: montserratStyle(),)),
        ),
      ),
    ));
  }
}
