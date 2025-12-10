import Flutter
import UIKit
import UserNotifications

public class SwiftMbautomationPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "mbautomation", binaryMessenger: registrar.messenger())
        let instance = SwiftMbautomationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addSceneDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "showNotification" {
            showNotification(call, result: result)
        } else if call.method == "cancelNotification" {
            cancelNotification(call, result: result)
        }
    }

    private func showNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }

        guard let id = arguments["id"] as? Int,
            let timestamp = arguments["date"] as? Int
        else {
            result(false)
            return
        }

        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else {
                    return
                }

                let content = UNMutableNotificationContent()

                content.title = arguments["title"] as? String ?? ""
                content.body = arguments["body"] as? String ?? ""
                if let badge = arguments["badge"] as? Int {
                    content.badge = NSNumber(value: badge)
                }
                if let launchImage = arguments["launchImage"] as? String {
                    content.launchImageName = launchImage
                }
                if let sound = arguments["sound"] as? String {
                    content.sound = UNNotificationSound(
                        named: UNNotificationSoundName(rawValue: sound))
                } else {
                    content.sound = UNNotificationSound.default
                }

                let media = arguments["media"] as? String
                let mediaType = arguments["mediaType"] as? String

                let date = Date(timeIntervalSince1970: Double(timestamp))

                if let media = media {
                    let fileUrl = URL(fileURLWithPath: media)
                    var options: [String: String]?
                    if let mediaType = mediaType {
                        options = [String: String]()
                        options?[UNNotificationAttachmentOptionsTypeHintKey] = mediaType
                    }
                    if let attachment = try? UNNotificationAttachment(
                        identifier: "media." + fileUrl.pathExtension, url: fileUrl, options: options
                    ) {
                        content.attachments = [attachment]
                    }
                }
                self.sendPush(
                    id: id,
                    date: date,
                    content: content,
                    result: result)
            }
        } else {
            //TODO: implement for older version if supported
            result(false)
        }
    }

    @available(iOS 10.0, *)
    private func sendPush(
        id: Int,
        date: Date,
        content: UNNotificationContent,
        result: @escaping FlutterResult
    ) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            let existingRequest = requests.first(where: { $0.identifier == String(id) })
            guard existingRequest == nil else {  // If I have already a request don't schedule another
                result(true)
                return
            }

            let trigger = UNTimeIntervalNotificationTrigger.init(
                timeInterval: abs(date.timeIntervalSinceNow), repeats: false)

            let request = UNNotificationRequest(
                identifier: String(id),
                content: content,
                trigger: trigger)

            notificationCenter.add(request) { (error) in
                if let error = error {
                    result(false)
                    print("Error \(error.localizedDescription)")
                } else {
                    result(true)
                }
            }
        }

    }

    private func cancelNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        guard let id = arguments["id"] as? Int else {
            result(false)
            return
        }

        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [String(id)])
            result(true)
        } else {
            //TODO: implement for older version if supported
            result(false)
        }
    }
}
