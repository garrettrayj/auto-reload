//
//  TabTimers.swift
//  SafariExtension
//
//  Created by Garrett Johnson on 9/20/18.
//  Copyright © 2018 DevSci. All rights reserved.
//

import Foundation
import SafariServices

class TabTimers {
    static let shared = TabTimers()
    var timers = [SFSafariTab: Timer]()
}
