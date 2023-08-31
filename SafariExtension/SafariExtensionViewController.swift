//
//  SafariExtensionViewController.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width: 140, height: 164)
        return shared
    }()
    
    @IBOutlet weak var intervalSlider: NSSlider!
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var scopeSwitch: NSSegmentedControl!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var decreaseIntervalButton: NSButton!
    @IBOutlet weak var increaseIntervalButton: NSButton!
    
    @IBAction func adjustIntervalAction(_ sender: NSSlider) {
        setInterval(interval: self.intervalSlider.doubleValue);
        updatePopoverStatus()
    }
    
    @IBAction func decreaseInterval(_ sender: NSButton) {
        let currentValue = self.intervalSlider.doubleValue;
        
        if (currentValue > 59 && currentValue - 60 > 59) {
            setInterval(interval: currentValue - 60);
        } else {
            setInterval(interval: currentValue - 1);
        }
        
        updatePopoverStatus()
    }
    
    @IBAction func increaseInterval(_ sender: NSButton) {
        let currentValue = self.intervalSlider.doubleValue;
        
        if (currentValue > 59) {
            setInterval(interval: currentValue + 60);
        } else {
            setInterval(interval: currentValue + 1);
        }

        updatePopoverStatus()
    }
    
    @IBAction func changeScope(_ sender: NSSegmentedControl) {
        UserDefaults.standard.set(scopeSwitch.integerValue, forKey: "scopeSwitchValue")
    }
    
    @IBAction func startStopAction(_ sender: NSButton) {
        SFSafariApplication.getActiveWindow { window in
            guard let window = window else { return }
            DispatchQueue.main.async {
                if let activeReloader = Reloaders.shared.forWindow(window: window) {
                    self.removeReloader(reloader: activeReloader)
                } else {
                    self.addReloader(window: window)
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
    
    private var countdownTimer: Timer?
    
    func loadPopover(window: SFSafariWindow) {
        if let activeReloader = Reloaders.shared.forWindow(window: window) {
            self.intervalSlider.doubleValue = activeReloader.interval
            self.scopeSwitch.intValue = activeReloader.allTabs ? 1 : 0
            self.setMode(mode: "running")
            self.updatePopoverStatus(reloader: activeReloader)
            self.startCountdownTimer(reloader: activeReloader)
        } else {
            let lastInterval = UserDefaults.standard.double(forKey: "intervalSliderValue")
            if lastInterval > 0 {
                self.intervalSlider.doubleValue = lastInterval
            } else {
                self.intervalSlider.doubleValue = 60
            }
            self.scopeSwitch.integerValue = UserDefaults.standard.integer(
                forKey: "scopeSwitchValue"
            )
            self.setMode(mode: "config")
            self.updatePopoverStatus()
        }
    }
    
    func stopCountdownTimer() {
        countdownTimer?.invalidate()
    }
    
    func updateToolbarIcon(window: SFSafariWindow) {
        let activeReloader = Reloaders.shared.forWindow(window: window)
        
        window.getToolbarItem { (toolbarItem) in
            if activeReloader != nil {
                toolbarItem?.setImage(NSImage(named: "ToolbarItemIconActive.pdf"))
            } else {
                toolbarItem?.setImage(NSImage(named: "ToolbarItemIcon.pdf"))
            }
        }
    }
    
    private func addReloader(window: SFSafariWindow) {
        let reloader = Reloaders.shared.createReloader(
            window: window,
            allTabs: scopeSwitch.intValue == 1,
            interval: self.intervalSlider.doubleValue
        )
        setMode(mode: "running")
        updatePopoverStatus(reloader: reloader)
        startCountdownTimer(reloader: reloader)
        updateToolbarIcon(window: window)
    }
    
    private func removeReloader(reloader: Reloader) {
        Reloaders.shared.remove(reloader: reloader)
        stopCountdownTimer()
        setMode(mode: "config")
        updatePopoverStatus()
        updateToolbarIcon(window: reloader.window)
    }
    
    private func setMode(mode: String) {
        switch mode {
        case "running":
            intervalSlider.isHidden = true
            increaseIntervalButton.isHidden = true
            decreaseIntervalButton.isHidden = true
            progressIndicator.isHidden = false
            progressIndicator.startAnimation("animate")
            startStopButton.state = .on
            break;
        default:
            // config mode
            intervalSlider.isHidden = false
            decreaseIntervalButton.isHidden = false
            increaseIntervalButton.isHidden = false
            progressIndicator.isHidden = true
            startStopButton.state = .off
        }
    }
    
    private func updatePopoverStatus(reloader: Reloader? = nil) {
        if let reloader = reloader {
            // Window has an active timer. Use "running" status template
            let secondsUntilReload = reloader.getSecondsUntilReload()
            let formattedInterval = self.formatIntervalForStatus(interval: secondsUntilReload)
            self.stateLabel.stringValue = "Reloading"
            self.timerLabel.stringValue = "in \(formattedInterval)"
            self.scopeSwitch.isEnabled = false
            
            self.progressIndicator.minValue = 0;
            self.progressIndicator.maxValue = reloader.interval - 1
            self.progressIndicator.doubleValue = reloader.interval - secondsUntilReload
            return
        }
        
        let formattedInterval = self.formatIntervalForConfig(interval: self.intervalSlider.doubleValue)
        self.stateLabel.stringValue = "Reload"
        self.timerLabel.stringValue = "every \(formattedInterval)"
        self.scopeSwitch.isEnabled = true
    }
    
    private func startCountdownTimer(reloader: Reloader) {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.updatePopoverStatus(reloader: reloader)
        }
    }
    
    private func setInterval(interval: Double) {
        intervalSlider.doubleValue = roundInterval(interval: interval);
        UserDefaults.standard.set(intervalSlider.doubleValue, forKey: "intervalSliderValue")
    }
    
    private func roundInterval(interval: Double) -> Double {
        if (interval < 60) {
            return ceil(interval)
        }
        
        let fractionNum = interval / 60.0
        let roundedNum = ceil(fractionNum)
        return roundedNum * 60
    }
    
    private func formatIntervalForConfig(interval: Double) -> String {
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
    
    private func formatIntervalForStatus(interval: Double) -> String {
        intervalFormatter.allowedUnits = [.hour, .minute, .second]
        
        if let formattedInterval = intervalFormatter.string(from: interval) {
            return formattedInterval
        } else {
            return "?"
        }
    }
}
