import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        TabTimers.shared.prune()
        SafariExtensionViewController.shared.updateToolbarIcon(window: window)
        validationHandler(true, "")
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (tab) in
            if let tab = tab {
                DispatchQueue.main.async {
                    if let tabTimer = TabTimers.shared.getTabTimer(tab: tab) {
                        SafariExtensionViewController.shared.restoreTab(tabTimer: tabTimer)
                        SafariExtensionViewController.shared.startUpdateTimer(tabTimer: tabTimer)
                    } else {
                        SafariExtensionViewController.shared.resetPopover()
                    }
                }
            }
        }
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        SafariExtensionViewController.shared.stopUpdateTimer()
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
