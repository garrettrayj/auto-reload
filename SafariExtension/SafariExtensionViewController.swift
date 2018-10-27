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
    
    @IBAction func startStopAction(_ sender: NSButton) {
        SFSafariApplication.getActiveWindow { (window) in
            if let window = window {
                window.getActiveTab { (tab) in
                    if let tab = tab {
                        DispatchQueue.main.async {
                            if TabTimers.shared.getTabTimer(tab: tab) == nil {
                                self.startTabTimer(tab: tab)
                            } else {
                                self.stopTabTimer(tab: tab)
                            }
                        }
                        self.updateToolbarIcon(window: window)
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
    
    var updateTimer: Timer?
    
    func startTabTimer(tab: SFSafariTab) {
        let tabTimer: TabTimer = TabTimers.shared.createTabTimer(tab: tab, interval: self.intervalSlider.doubleValue)
        setMode(mode: "running")
        updatePopoverStatus(tabTimer: tabTimer)
        startUpdateTimer(tabTimer: tabTimer)
    }
    
    func stopTabTimer(tab: SFSafariTab) {
        stopUpdateTimer()
        TabTimers.shared.removeTabTimer(tab: tab)
        setMode(mode: "config")
        updatePopoverStatus()
    }
    
    func restoreTab(tabTimer: TabTimer) {
        NSLog("Restoring timer settings for tab \(tabTimer.tab.hash).")
        intervalSlider.doubleValue = tabTimer.interval
        setMode(mode: "running")
        updatePopoverStatus(tabTimer: tabTimer)
    }
    
    func resetPopover() {
        NSLog("Reseting popover.")
        intervalSlider.doubleValue = 60
        setMode(mode: "config")
        updatePopoverStatus()
    }
    
    func setMode(mode: String) {
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
    
    func updatePopoverStatus(tabTimer: TabTimer? = nil) {
        if let tabTimer = tabTimer {
            // Tab has an active timer. Use "running" status template
            let secondsUntilReload = tabTimer.getSecondsUntilReload()
            let formattedInterval = self.formatIntervalForStatus(interval: secondsUntilReload)
            self.statusTextField.stringValue = "Reloading\nin \(formattedInterval)"
            
            self.progressIndicator.minValue = 0;
            self.progressIndicator.maxValue = tabTimer.interval - 1
            self.progressIndicator.doubleValue = tabTimer.interval - secondsUntilReload
            return
        }
        
        let formattedInterval = self.formatIntervalForConfig(interval: self.intervalSlider.doubleValue)
        self.statusTextField.stringValue = "Reload\nevery" + " " + formattedInterval
    }
    
    func startUpdateTimer(tabTimer: TabTimer) {
        updateTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.fireUpdateStatus), userInfo: tabTimer, repeats: true)
        updateTimer?.tolerance = 0.2
        RunLoop.current.add(updateTimer!, forMode: RunLoop.Mode.common)
    }
    
    func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    @objc func fireUpdateStatus(timer: Timer) {
        guard let tabTimer = timer.userInfo as? TabTimer else { return }
        updatePopoverStatus(tabTimer: tabTimer)
    }
    
    func updateToolbarIcon(window: SFSafariWindow) {
        window.getToolbarItem { (toolbarItem) in
            window.getActiveTab { (tab) in
                if let tab = tab {
                    if TabTimers.shared.getTabTimer(tab: tab) === nil {
                        toolbarItem?.setImage(NSImage(named: "ToolbarItemIcon.pdf"))
                    } else {
                        toolbarItem?.setImage(NSImage(named: "ToolbarItemIconActive.pdf"))
                    }
                }
            }
        }
    }
    
    func setInterval(interval: Double) {
        intervalSlider.doubleValue = roundInterval(interval: interval);
    }
    
    func roundInterval(interval: Double) -> Double {
        if (interval < 60) {
            return ceil(interval)
        }
        
        let fractionNum = interval / 60.0
        let roundedNum = ceil(fractionNum)
        return roundedNum * 60
    }
    
    func formatIntervalForConfig(interval: Double) -> String {
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
    
    func formatIntervalForStatus(interval: Double) -> String {
        intervalFormatter.allowedUnits = [.hour, .minute, .second]
        
        if let formattedInterval = intervalFormatter.string(from: interval) {
            return formattedInterval
        } else {
            return "?"
        }
    }
}
