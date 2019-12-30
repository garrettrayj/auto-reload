import Foundation
import SafariServices

class TabTimer: Hashable {
    var timer: Timer?
    var tab: SFSafariTab
    var interval: Double
    
    init(tab: SFSafariTab, interval: Double) {
        self.tab = tab
        self.interval = interval
        self.startTimer()
    }
    
    @objc func reload() {
        tab.getActivePage { (page) in
            if let page = page {
                NSLog("Refreshing tab \(self.tab.hash)")
                page.reload()
            } else {
                NSLog("Active page for tab \(self.tab.hash) not available")
                self.stopTimer()
            }
        }
    }
    
    func startTimer() {
        NSLog("Adding a new timer for tab \(tab.hash) with \(interval) second interval")
        timer = Timer(timeInterval: interval, target: self, selector: #selector(self.reload), userInfo: tab, repeats: true)
        timer?.tolerance = 0.2
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func stopTimer() {
        NSLog("Stopping timer for tab \(self.tab.hash)")
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
    
    static func == (lhs: TabTimer, rhs: TabTimer) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tab.hashValue)
    }
}
