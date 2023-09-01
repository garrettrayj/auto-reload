//
//  Window.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import Foundation
import Cocoa

class Window: NSWindow {
    override public var isMovableByWindowBackground: Bool {
        get {
            return true
        }
        set {
            super.isMovableByWindowBackground = newValue
        }
    }
}
