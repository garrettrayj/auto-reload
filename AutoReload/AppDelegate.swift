//
//  AppDelegate.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 DevSci. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }
}
