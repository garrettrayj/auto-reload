/**
 * Thread-safe TabTimer collection class
 */
import Foundation
import SafariServices

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
