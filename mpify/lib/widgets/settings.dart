import 'package:flutter/material.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/widgets/homebar.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SettingsCategory _selectedCategory = SettingsCategory.general;
  bool isDarkmodeToggled = true;
  Widget _buildContent() {
    switch (_selectedCategory) {
      case SettingsCategory.general:
        return Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Darkmode',
                  style: montserratStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Switch(
                  value: isDarkmodeToggled,
                  activeTrackColor: Colors.green,
                  onChanged: (bool newVal) {
                    setState(() {
                      isDarkmodeToggled = newVal;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case SettingsCategory.audio:
        return Text('Audio');
      case SettingsCategory.backup:
        return Text('Backup');
      case SettingsCategory.troubleshooter:
        return Text('Troubleshooter');
      case SettingsCategory.about:
        return Text('About');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Homebar(),
        Container(
          width: 1400,
          height: 700,
          color: Colors.transparent,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    hoverFontColor: const Color.fromARGB(255, 175, 175, 175),
                    borderRadius: 0,
                    onPressed: () {
                      setState(() {
                        _selectedCategory = SettingsCategory.general;
                      });
                    },
                    width: 200,
                    height: 80,
                    child: Center(
                      child: Text(
                        'General',
                        style: montserratStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      setState(() {
                        _selectedCategory = SettingsCategory.audio;
                      });
                    },
                    width: 250,
                    height: 80,
                    child: Center(
                      child: Text(
                        'Audio',
                        style: montserratStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      setState(() {
                        _selectedCategory = SettingsCategory.backup;
                      });
                    },
                    width: 250,
                    height: 80,
                    child: Center(
                      child: Text(
                        'Back Up & Restore',
                        style: montserratStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      setState(() {
                        _selectedCategory = SettingsCategory.troubleshooter;
                      });
                    },
                    width: 250,
                    height: 80,
                    child: Center(
                      child: Text(
                        'Troubleshooter',
                        style: montserratStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      _selectedCategory = SettingsCategory.about;
                    },
                    width: 200,
                    height: 80,
                    child: Center(
                      child: Text(
                        'About',
                        style: montserratStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Container(height: double.infinity, width: 1, color: Colors.white),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ],
    );
  }
}
