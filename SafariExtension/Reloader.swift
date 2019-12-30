import Foundation
import SafariServices

class Reloader: Hashable {
    var timer: Timer?
    var window: SFSafariWindow
    var interval: Double
    
    init(window: SFSafariWindow, interval: Double) {
        self.window = window
        self.interval = interval
        self.startTimer()
    }
    
    @objc func reload() {
        window.getActiveTab { (tab) in
            tab?.getActivePage { (page) in
                page?.reload()
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
                // Add a second to handle inevitable shifts between UI actions and rounding
                return Double(seconds) + 1.0;
            } else {
                return 0;
            }
        }
        
        return -1;
    }
    
    func getProgress() -> Double {
        return ceil(((interval - getSecondsUntilReload()) / interval) * 100)
    }
    
    // MARK: - <Hashable>
    
    static func == (lhs: Reloader, rhs: Reloader) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(window)
    }
}
