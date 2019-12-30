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
                let activeReloader = Reloaders.shared.getReloaderForWindow(window: window)
                DispatchQueue.main.async {
                    if activeReloader != nil {
                        self.removeWindowReloader(reloader: activeReloader!)
                    } else {
                        self.addWindowReloader(window: window)
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
    
    var countdown: Timer?
    
    func addWindowReloader(window: SFSafariWindow) {
        let reloader = Reloaders.shared.createReloader(window: window, interval: self.intervalSlider.doubleValue)
        setMode(mode: "running")
        updatePopoverStatus(reloader: reloader)
        startUpdateTimer(reloader: reloader)
        updateToolbarIcon(window: window)
    }
    
    func removeWindowReloader(reloader: Reloader) {
        Reloaders.shared.remove(reloader: reloader)
        stopUpdateTimer()
        setMode(mode: "config")
        updatePopoverStatus()
        updateToolbarIcon(window: reloader.window)
    }
    
    func loadPopover(window: SFSafariWindow) {
        let activeReloader = Reloaders.shared.getReloaderForWindow(window: window)
        
        if activeReloader != nil {
            self.intervalSlider.doubleValue = activeReloader!.interval
            self.setMode(mode: "running")
            self.updatePopoverStatus(reloader: activeReloader)
            self.startUpdateTimer(reloader: activeReloader!)
        } else {
            self.intervalSlider.doubleValue = 60
            self.setMode(mode: "config")
            self.updatePopoverStatus()
        }
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
    
    func updatePopoverStatus(reloader: Reloader? = nil) {
        if let reloader = reloader {
            // Window has an active timer. Use "running" status template
            let secondsUntilReload = reloader.getSecondsUntilReload()
            let formattedInterval = self.formatIntervalForStatus(interval: secondsUntilReload)
            self.statusTextField.stringValue = "Reloading\nin \(formattedInterval)"
            
            self.progressIndicator.minValue = 0;
            self.progressIndicator.maxValue = reloader.interval - 1
            self.progressIndicator.doubleValue = reloader.interval - secondsUntilReload
            return
        }
        
        let formattedInterval = self.formatIntervalForConfig(interval: self.intervalSlider.doubleValue)
        self.statusTextField.stringValue = "Reload\nevery" + " " + formattedInterval
    }
    
    func startUpdateTimer(reloader: Reloader) {
        countdown?.invalidate()
        countdown = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.updatePopoverStatus(reloader: reloader)
        }
    }
    
    func stopUpdateTimer() {
        countdown?.invalidate()
    }

    func updateToolbarIcon(window: SFSafariWindow) {
        let activeReloader = Reloaders.shared.getReloaderForWindow(window: window)
        
        window.getToolbarItem { (toolbarItem) in
            if activeReloader != nil {
                toolbarItem?.setImage(NSImage(named: "ToolbarItemIconActive.pdf"))
            } else {
                toolbarItem?.setImage(NSImage(named: "ToolbarItemIcon.pdf"))
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
    
    deinit {
        stopUpdateTimer()
    }
}
