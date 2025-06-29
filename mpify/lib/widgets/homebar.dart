import 'package:flutter/material.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class Homebar extends StatelessWidget {
  const Homebar({super.key});
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
                child: Consumer<SettingsModels>(
                  builder: (context, settings, child) {
                    return IconButton(
                      icon: (settings.isOpenSettings)
                          ? Icon(Icons.close)
                          : Icon(Icons.settings),
                      onPressed: () {
                        settings.flipIsOpenSetting();
                        debugPrint('${settings.isOpenSettings}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await windowManager.minimize();
                },
                icon: Icon(Icons.minimize_outlined),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  await windowManager.maximize();
                },
                icon: Icon(Icons.rectangle_outlined),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  await windowManager.close();
                },
                icon: Icon(Icons.close_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
