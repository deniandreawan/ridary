import Foundation
import os

enum RidaryLog {
    static let app = Logger(subsystem: "app.ridary.ios", category: "app")
    static let capture = Logger(subsystem: "app.ridary.ios", category: "capture")
    static let ai = Logger(subsystem: "app.ridary.ios", category: "ai")
    static let sync = Logger(subsystem: "app.ridary.ios", category: "sync")
}
