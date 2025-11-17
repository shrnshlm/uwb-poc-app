import UIKit
import Flutter
import NearbyInteraction

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var uwbManager: UWBManager?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let uwbChannel = FlutterMethodChannel(name: "com.uwbpoc/uwb",
                                              binaryMessenger: controller.binaryMessenger)

        uwbManager = UWBManager(channel: uwbChannel)

        uwbChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "checkUwbSupport":
                if #available(iOS 14.0, *) {
                    result(NISession.isSupported)
                } else {
                    result(false)
                }
            case "startUwbSession":
                self.uwbManager?.startSession(result: result)
            case "stopUwbSession":
                self.uwbManager?.stopSession(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

@available(iOS 14.0, *)
class UWBManager: NSObject, NISessionDelegate {
    private var niSession: NISession?
    private var channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    func startSession(result: @escaping FlutterResult) {
        guard NISession.isSupported else {
            result(FlutterError(code: "UNSUPPORTED",
                              message: "UWB is not supported on this device",
                              details: nil))
            return
        }

        niSession = NISession()
        niSession?.delegate = self

        // Note: In a real app, you would need to exchange discovery tokens
        // between devices using another communication method (BLE, WiFi, etc.)
        // For this POC, we'll just start the session

        result(nil)
    }

    func stopSession(result: @escaping FlutterResult) {
        niSession?.invalidate()
        niSession = nil
        result(nil)
    }

    // MARK: - NISessionDelegate

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let object = nearbyObjects.first else { return }

        var direction = "Unknown"
        if let objectDirection = object.direction {
            let azimuth = objectDirection.x
            let elevation = objectDirection.y
            direction = String(format: "Azimuth: %.2f, Elevation: %.2f", azimuth, elevation)
        }

        let distance = object.distance ?? -1.0

        channel.invokeMethod("onDistanceUpdate", arguments: [
            "distance": distance,
            "direction": direction
        ])
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        // Handle object removal
        print("Nearby object removed: \(reason)")
    }

    func sessionWasSuspended(_ session: NISession) {
        print("Session was suspended")
    }

    func sessionSuspensionEnded(_ session: NISession) {
        print("Session suspension ended")
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("Session invalidated: \(error.localizedDescription)")
        niSession = nil
    }
}
