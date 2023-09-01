//
//  SafariExtensionHandler.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//
//  SPDX-License-Identifier: MIT
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    let viewController: SafariExtensionViewController
    
    override init() {
        viewController = SafariExtensionViewController.shared
        viewController.preferredContentSize = NSSize(width: 140, height: 164)
        
        super.init()
    }
    
    /// Called when Safari's state has changed in a way that requires the toolbar item to be revalidated.
    override func validateToolbarItem(
        in window: SFSafariWindow,
        validationHandler: @escaping ((Bool, String) -> Void)
    ) {
        viewController.updateToolbarIcon(window: window)
        validationHandler(true, "")
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        self.viewController.loadPopover(window: window)
    }

    override func popoverDidClose(in window: SFSafariWindow) {
        viewController.stopCountdownTimer()
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return viewController
    }
}
