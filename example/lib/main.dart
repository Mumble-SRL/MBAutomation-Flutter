import 'package:flutter/material.dart';

import 'package:mbautomation/mbautomation.dart';
import 'package:mburger/mburger.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mbmessages/mbmessages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
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
          print(button);
        },
      ),
    ];

    _configurePushNotifications();

    super.initState();
  }

  Future<void> _configurePushNotifications() async {
    MBMessages.pushToken = 'YOUR_PUSH_API_KEY';
    MBMessages.onToken = (token) async {
      print("Token received $token");
      await MBMessages.registerDevice(token).catchError(
        (error) => print(error),
      );
      await MBMessages.registerToTopics(
        [
          await MBMessages.projectPushTopic(),
          await MBMessages.devicePushTopic(),
          MPTopic(code: 'Topic'),
        ],
      ).catchError(
        (error) => print(error),
      );
      print('Registered');
    };

    MBMessages.configurePush(
      onNotificationArrival: (notification) {
        print("Notification arrived: $notification");
      },
      onNotificationTap: (notification) {
        print("Notification tapped: $notification");
      },
      androidNotificationsSettings: MPAndroidNotificationsSettings(
        channelId: 'mpush_example',
        channelName: 'mpush',
        channelDescription: 'mpush',
        icon: '@mipmap/icon_notif',
      ),
    );

    MBMessages.requestToken();

    Map<String, dynamic>? launchNotification =
        await MBMessages.launchNotification();
    print(launchNotification);
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
              child: Text('Send Event'),
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
