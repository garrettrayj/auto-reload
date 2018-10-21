import Foundation
import Cocoa

class Window: NSWindow {
    override public var isMovableByWindowBackground: Bool {
        get {
            return true;
        }
        set {
            super.isMovableByWindowBackground = newValue
        }
    }
}
