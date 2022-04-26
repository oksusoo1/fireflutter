import 'package:example/services/global.dart';
import 'package:flutter/material.dart';
import 'package:example/widgets/layout/layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int versionCount = 0;
  int customerServiceCount = 0;
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Settings Screen',
        style: TextStyle(color: Colors.blue),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              versionCount++;
            },
            onLongPress: () {
              if (versionCount > 3) {
                service.router.openTest();
              }
            },
            child: Text('Version x.x.x'),
          ),
          TextButton(
            onPressed: () {
              customerServiceCount++;
            },
            onLongPress: () {
              if (customerServiceCount > 3) {
                service.router.openAdmin();
              }
            },
            child: Text('Customer Service: 010-8693-4225'),
          ),
        ],
      ),
    );
  }
}
