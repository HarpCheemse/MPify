import 'package:flutter/material.dart';
import 'package:mpify/screen/settings_screen.dart';
import 'package:window_manager/window_manager.dart';

class Homebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20),
                child: IconButton(
                  icon: Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                ),
              ),
            ],
          ),
          Expanded(child: GestureDetector(
            onPanStart: (_) => windowManager.startDragging(),
          )),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await windowManager.minimize();
                },
                icon: Icon(Icons.minimize_outlined),
                color: Colors.white,
              ),
              SizedBox(width: 10,),
              IconButton(
                onPressed: () async {
                  await windowManager.maximize();
                },
                icon: Icon(Icons.rectangle_outlined),
                color: Colors.white,
              ),
              SizedBox(width: 10,),
              IconButton(
                onPressed: () async {
                  await windowManager.close();
                },
                icon: Icon(Icons.close_outlined),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
