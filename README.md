# MBAutomation

`MBAutomation` is a plugin libary for [MBurger](https://mburger.cloud), that lets you send automatic push notifications and in-app messages crated from the MBurger platform. It has as dependencies [MBMessages](https://github.com/Mumble-SRL/MBMessages-Flutter) and [MBAudience](https://github.com/Mumble-SRL/MBAudience-Flutter). With this library you can also track user events and views.

Using `MBAutomation` you can setup triggers for in-app messages and push notifications, in the MBurger dashboard and the SDK will show the coontent automatically when triggers are satisfied. 

It depends on `MBAudience` because messages can be triggered by location changes or tag changes, coming from this SDK.

It depends on `MBMessages` because it contains all the views for the in-app messages and the checks if a message has been already displayed or not.

The data flow from all the SDKs is manage entirely by MBurger, yuo don't have to worry about it.

MBAutomation depends on the following packages:

 - [mburger](https://pub.dev/packages/mburger)
 - [mbmessages](https://pub.dev/packages/mbmessages)
 - [mbaudience](https://pub.dev/packages/mbaudience)
 - [http](https://pub.dev/packages/http)
 - [path](https://pub.dev/packages/path)
 - [path_provider](https://pub.dev/packages/path_provider)
 - [shared_preferences](https://pub.dev/packages/shared_preferences)
 - [sqflite](https://pub.dev/packages/sqflite)

# Installation

You can install the MBAudience SDK using pub, add this to your pubspec.yaml file:

``` yaml
dependencies:
  mbautomation: ^2.0.0
```

And then install packages from the command line with:

``` bash
$ flutter pub get
```

# Initialization

To initialize automation you need to insert `MBAutomation` as an `MBurger` plugin, tipically automation is used in conjunction with the `MBMessages` and `MBAudience` plugins.

``` dart
MBManager.shared.plugins = [
  MBAutomation(),
  ... other plugins
];
```

MBAutomation can bbe initialized with 3 optional parameters:

* `trackingEnabled`: If the tracking is enabled or not, setting this to false all the tracking will be disabled
* `eventsTimerTime`: The frequency used to send events and views to MBurger

# Triggers

Every in-app message or push notification coming from MBurger can have an array of triggers, those are managed entirely by the MBAutomation SDK that evaluates them and show the mssage only when the conditioon defined by the triggers are matched. 

If thre are more than one trigger, they can be evaluated with 2 methods:

* `any`: once one of triggers becomes true the message is displayed to the user
* `all`: all triggers needs to be true in order to show the message.

Here's the list of triggers managed by automation SDK:


#### App opening

`MBAppOpeningTrigger`: Becoomes true when the app has been opened n times (`times` property), it's checked at the app startup.


#### Event

`MBEventTrigger`: Becomes true when an event happens n times (`times` property)

#### Inactive user

`MBInactiveUserTrigger`: Becomes true if a user has not opened the app for n days (`days` parameter)

#### Location

`MBLocationTrigger`: If a user enters a location, specified by `latitude`, `longitude` and `radius`. This trigger can be activated with a day delay defined as the `afterDays` property. The location data comes from the [MBAudience](https://github.com/Mumble-SRL/MBAudience-Flutter) SDK.

#### Tag change

`MBTagChangeTrigger`: If a tag of the [MBAudience](https://github.com/Mumble-SRL/MBAudience-Flutter) SDK changes and become equals or not to a value. It has a `tag` property (the tag that needs to be checked) and a `value` property (the value that needs to be equal or different in order to activate the trigger)

#### View

`MBViewTrigger`: it's activated when a user enters a view n times (`times` property). If the `secondsOnView` the user needs to stay the seconds defined in order to activate the trigger.

# Send events

You can send events with `MBAutomation` liike this:

``` dart
MBAutomation.sendEvent('EVENT_NAME');
```

You can specify 2 more parameters, both optional: `name` a name that will be displayed in the MBurger dashboard and a map of additional `metadata` to specifymore fields of the event

``` dart
MBAutomation.sendEvent(
  'purchase',
  name: "PURCHASE",
  metadata: {"quantity": 1},
);
```

Events are saved in a local database and sent to the server every 10 seconds, you can change the frequency setting the `eventsTimerTime` property.

# View Tracking

To track views automatically add an instance of `MBAutomationNavigatorObserver` to the `navigatorObservers` of your app, like this:

``` dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    navigatorObservers: [MBAutomationNavigatorObserver()],
    home: ...,
  );
}
```

The navigator observer will send the name of the `PageRoute` (`route.settings.name`) tto MBurger whenever a new route is pushed or popped.

If you don't wnat to use the navigator observer you can use this function, to track a view manually.


``` dart
MBAutomation.trackScreenView('VIEW');
```

As the events, views are saved in a local database and sent to the server every 10 seconds and you can change the frequency setting the `eventsTimerTime` property.

