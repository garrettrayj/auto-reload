//
//  Window.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import Foundation
import SafariServices

/**
 * Thread-safe Reloader collection class
 */
class Reloaders {
    static let shared = Reloaders()

    var reloaders = Set<Reloader>()
    
    func createReloader(window: SFSafariWindow, interval: Double) -> Reloader {
        let insertedReloaders = self.reloaders.insert(Reloader(window: window, interval: interval))
        return insertedReloaders.1
    }
    
    func getReloaderForWindow(window: SFSafariWindow) -> Reloader? {
        return self.reloaders.first { (reloader) -> Bool in
            return window == reloader.window;
        }
    }
    
    func remove(reloader: Reloader) {
        reloader.stopTimer()
        self.reloaders.remove(reloader)
    }
}
