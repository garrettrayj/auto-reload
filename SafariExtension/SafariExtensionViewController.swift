//
//  SafariExtensionViewController.swift
//  SafariExtension
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 DevSci. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:80, height:98)
        
        return shared
    }()
    
    @IBOutlet weak var intervalSlider: NSSlider!

    @IBOutlet weak var statusTextField: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var startStopButton: NSButton!
    
    @IBAction func adjustIntervalAction(_ sender: NSSlider) {
        updatePopoverStatus()
    }
    
    @IBAction func startStopAction(_ sender: NSButton) {
        SFSafariApplication.getActiveWindow { (window) in
            if let window = window {
                window.getActiveTab { (tab) in
                    if let tab = tab {
                        DispatchQueue.main.async {
                            if let timer = TabTimers.shared.timers[tab] {
                                self.stopTabTimer(tab: tab, timer: timer)
                            } else {
                                self.startTabTimer(tab: tab)
                            }
                            
                            self.updateToolbarIcon(window: window)
                        }
                    }
                }
            }
        }
    }
    
    let intervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        return formatter
    }()
    
    func startTabTimer(tab: SFSafariTab) {
        NSLog("Adding a new timer for tab. \(tab.hash) with \(self.intervalSlider.doubleValue) second interval.")
        
        let timer = Timer(timeInterval: self.intervalSlider.doubleValue, target: self, selector: #selector(self.fireReload), userInfo: tab, repeats: true)
        timer.tolerance = 1.0
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        TabTimers.shared.timers[tab] = timer
        
        self.intervalSlider.isHidden = true
        self.progressIndicator.isHidden = false
        self.progressIndicator.startAnimation(tab)
        
        self.updatePopoverStatus(tab: tab)
    }
    
    func stopTabTimer(tab: SFSafariTab, timer: Timer) {
        NSLog("Stopping timer for tab \(tab.hash).")
        
        timer.invalidate()
        TabTimers.shared.timers[tab] = nil
        
        self.intervalSlider.isHidden = false
        self.progressIndicator.isHidden = true
        
        self.updatePopoverStatus(tab: tab)
    }
    
    func restoreTab(tab: SFSafariTab, timer: Timer) {
        NSLog("Restoring timer settings for tab \(tab.hash).")
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(tab)
        intervalSlider.isHidden = true
        intervalSlider.doubleValue = timer.timeInterval
        startStopButton.state = .on
        
        updatePopoverStatus(tab: tab)
    }
    
    
    func resetPopover() {
        NSLog("Reseting popover.")
        progressIndicator.isHidden = true
        intervalSlider.isHidden = false
        intervalSlider.doubleValue = 60
        startStopButton.state = .off
        
        updatePopoverStatus()
    }
    
    func updatePopoverStatus(tab: SFSafariTab? = nil) {
        if let tab = tab {
            if let timer = TabTimers.shared.timers[tab] {
                // Tab has an active timer. Use "running" status template
                let formattedInterval = self.formatInterval(interval: timer.timeInterval)
                self.statusTextField.stringValue = "Reloading\nevery \(formattedInterval)"
                return
            }
        }
        
        let formattedInterval = self.formatInterval(interval: self.intervalSlider.doubleValue)
        self.statusTextField.stringValue = "Reload\nevery" + " " + formattedInterval
    }
    
    func updateToolbarIcon(window: SFSafariWindow) {
        window.getActiveTab { (tab) in
            window.getToolbarItem { (toolbarItem) in
                if TabTimers.shared.timers[tab!] === nil {
                    toolbarItem?.setImage(NSImage(named: "ToolbarItemIcon.pdf"))
                } else {
                    toolbarItem?.setImage(NSImage(named: "ToolbarItemIconActive.pdf"))
                }
            }
        }
    }
    
    func formatInterval(interval: Double) -> String {
        if interval > 60 && interval < 3600 {
            intervalFormatter.allowedUnits = [.minute]
        } else {
            intervalFormatter.allowedUnits = [.hour, .minute, .second]
        }
        
        if let formattedInterval = intervalFormatter.string(from: interval) {
            return formattedInterval
        } else {
            return "?"
        }
    }
    
    @objc func fireReload(timer: Timer) {
        guard let tab = timer.userInfo as? SFSafariTab else { return }
        tab.getActivePage { (page) in
            if let page = page {
                NSLog("Refreshing tab \(tab.hash)")
                page.reload()
            } else {
                NSLog("Active page for tab \(tab.hash) not available. Removing timer.")
                TabTimers.shared.timers[tab]?.invalidate()
                TabTimers.shared.timers[tab] = nil
            }
        }
    }
}
