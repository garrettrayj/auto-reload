/**
 * Thread-safe TabTimer collection class
 */
import Foundation
import SafariServices

class TabTimers {
    static let shared = TabTimers()
    
    var tabTimers = Set<TabTimer>()
    
    func createTabTimer(tab: SFSafariTab, interval: Double) -> TabTimer {
        let tabTimer = self.tabTimers.insert(TabTimer(tab: tab, interval: interval))
        return tabTimer.1
    }
    
    func getTabTimer(tab: SFSafariTab) -> TabTimer? {
        return self.tabTimers.first { (tabTimer) -> Bool in
            return tab.hashValue == tabTimer.hashValue;
        }
    }
    
    func removeTabTimer(tab: SFSafariTab) {
        if let tabTimer = getTabTimer(tab: tab) {
            NSLog("Removing timer for tab \(tab.hash)")
            tabTimer.stopTimer();
            self.tabTimers.remove(tabTimer)
        }
    }
    
    func prune() {
        for tabTimer in tabTimers {
            tabTimer.tab.getActivePage { (page) in
                if (page == nil) {
                    NSLog("Pruning timer for tab \(tabTimer.tab.hash)")
                    self.removeTabTimer(tab: tabTimer.tab)
                }
            }
        }
    }
}
