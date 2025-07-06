import 'package:flutter/material.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';



class Homebar extends StatefulWidget {
  const Homebar({super.key});
  @override
  State<Homebar> createState() => _HomeBarState();
}

class _HomeBarState extends State<Homebar> with WindowListener {
  bool _isMaximized = true;
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncInitState();
  }

  Future<void> _syncInitState() async {
    _isMaximized = await windowManager.isMaximized();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

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
              onPanStart: (_) async {
                await windowManager.restore();
                windowManager.startDragging();
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  windowManager.minimize();
                },
                icon: Icon(Icons.minimize_outlined),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  (_isMaximized)
                      ? await windowManager.restore()
                      : await windowManager.maximize();
                  setState(() {
                    _isMaximized = !_isMaximized;
                  });
                },
                icon: (_isMaximized)
                    ? Icon(
                        Icons.filter_none,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : Icon(
                        Icons.rectangle_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
