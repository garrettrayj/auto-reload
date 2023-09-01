//
//  Reloaders.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SafariServices

/**
 * Container for window Reloader objects
 */
class Reloaders {
    static let shared = Reloaders()

    private var reloaders = Set<Reloader>()

    func createReloader(window: SFSafariWindow, allTabs: Bool, interval: Double) -> Reloader {
        let insertedReloaders = self.reloaders.insert(
            Reloader(window: window, allTabs: allTabs, interval: interval)
        )
        return insertedReloaders.1
    }

    func forWindow(window: SFSafariWindow) -> Reloader? {
        return self.reloaders.first { (reloader) -> Bool in
            return window == reloader.window
        }
    }

    func remove(reloader: Reloader) {
        reloader.stopTimer()
        self.reloaders.remove(reloader)
    }
}
