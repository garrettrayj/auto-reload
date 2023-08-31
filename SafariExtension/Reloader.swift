//
//  Reloader.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import Foundation
import SafariServices

class Reloader {
    private var timer: Timer?
    
    var window: SFSafariWindow
    var allTabs: Bool
    var interval: Double
    
    init(window: SFSafariWindow, allTabs: Bool, interval: Double) {
        self.window = window
        self.allTabs = allTabs
        self.interval = interval
        self.startTimer()
    }
    
    @objc func reload() {
        if allTabs {
            window.getAllTabs { tabs in
                for tab in tabs {
                    tab.getActivePage { page in
                        page?.reload()
                    }
                }
            }
        } else {
            window.getActiveTab { tab in
                tab?.getActivePage { page in
                    page?.reload()
                }
            }
        }
    }
    
    func startTimer() {
        NSLog("Adding a new timer with \(interval) second interval...")
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {_ in
            self.reload()
        }
    }
    
    func stopTimer() {
        NSLog("Stopping timer...")
        timer?.invalidate()
    }
    
    func getSecondsUntilReload() -> Double {
        if let timer = timer {
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.second], from: Date(), to: timer.fireDate)
            
            if let seconds = components.second {
                return Double(seconds) + 1.0;
            } else {
                return 0;
            }
        }
        
        return -1;
    }
}

extension Reloader: Hashable {
    static func == (lhs: Reloader, rhs: Reloader) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(window)
    }
}
