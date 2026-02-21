import Foundation

enum AppLogger {
    static func info(_ message: String) {
#if DEBUG
        print("[INFO] \(message)")
#endif
    }

    static func error(_ message: String) {
#if DEBUG
        print("[ERROR] \(message)")
#endif
    }
}
