//
//  SafariExtensionHandler.swift
//  AutoRefreshExtension
//
//  Created by Garrett Johnson on 9/19/18.
//  Copyright © 2018 DevSci. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (tab) in
            if let tab = tab {
                if let timer = TabTimers.shared.timers[tab] {
                    SafariExtensionViewController.shared.restoreTab(tab: tab, timer: timer)
                } else {
                    SafariExtensionViewController.shared.resetPopover()
                }
            }
        }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    @objc func fireReload(timer: Timer) {
        NSLog("Refresh")
        
        guard let tab = timer.userInfo as? SFSafariTab else { return }
        tab.getActivePage { (page) in
            page?.reload()
        }
        
    }
}
