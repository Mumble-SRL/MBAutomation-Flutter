import 'package:flutter/material.dart';

import 'package:mbautomation/mbautomation.dart';
import 'package:mburger/mburger.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mbmessages/mbmessages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    MBManager.shared.apiToken = 'YOUR_API_TOKEN';
    MBManager.shared.plugins = [
      MBAutomation(),
      MBAudience(),
      MBMessages(
        onButtonPressed: (button) {
          debugPrint(button.toString());
        },
      ),
    ];

    _configurePushNotifications();

    super.initState();
  }

  Future<void> _configurePushNotifications() async {
    MBMessages.pushToken = 'YOUR_PUSH_API_KEY';
    MBMessages.onToken = (token) async {
      debugPrint("Token received $token");
      await MBMessages.registerDevice(token).catchError(
        (error) => debugPrint(error),
      );
      await MBMessages.registerToTopics(
        [
          await MBMessages.projectPushTopic(),
          await MBMessages.devicePushTopic(),
          const MPTopic(code: 'Topic'),
        ],
      ).catchError(
        (error) => debugPrint(error),
      );
      debugPrint('Registered');
    };

    MBMessages.configurePush(
      onNotificationArrival: (notification) {
        debugPrint("Notification arrived: $notification");
      },
      onNotificationTap: (notification) {
        debugPrint("Notification tapped: $notification");
      },
      androidNotificationsSettings: const MPAndroidNotificationsSettings(
        channelId: 'mpush_example',
        channelName: 'mpush',
        channelDescription: 'mpush',
        icon: '@mipmap/icon_notif',
      ),
    );

    MBMessages.requestToken();

    Map<String, dynamic>? launchNotification =
        await MBMessages.launchNotification();
    debugPrint(launchNotification?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MBAutomationNavigatorObserver()],
      home: MBMessagesBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('MBAutomation example app'),
          ),
          body: Center(
            child: TextButton(
              child: const Text('Send Event'),
              onPressed: () => _sendEvent(),
            ),
          ),
        ),
      ),
    );
  }

  void _sendEvent() {
    MBAutomation.sendEvent('EVENT_NAME');
  }
}
