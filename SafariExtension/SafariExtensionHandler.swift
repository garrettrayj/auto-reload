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
        SafariExtensionViewController.shared.updateToolbarIcon(window: window)
        validationHandler(true, "")
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (tab) in
            if let tab = tab {
                DispatchQueue.main.async {
                    if let timer = TabTimers.shared.timers[tab] {
                        SafariExtensionViewController.shared.restoreTab(tab: tab, timer: timer)
                    } else {
                        SafariExtensionViewController.shared.resetPopover()
                    }
                }
            }
        }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
