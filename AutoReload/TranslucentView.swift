import Foundation
import Cocoa

class TranslucentView: NSVisualEffectView {
    override var  mouseDownCanMoveWindow: Bool {
        return true;
    }
}
