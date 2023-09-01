//
//  TranslucentView.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import Foundation
import Cocoa

class TranslucentView: NSVisualEffectView {
    override var  mouseDownCanMoveWindow: Bool {
        return true
    }
}
