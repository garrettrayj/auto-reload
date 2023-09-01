//
//  SafariExtensionHandler.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    /// Called when Safari's state has changed in a way that requires the toolbar item to be revalidated.
    override func validateToolbarItem(
        in window: SFSafariWindow,
        validationHandler: @escaping ((Bool, String) -> Void)
    ) {
        SafariExtensionViewController.shared.updateToolbarIcon(window: window)
        validationHandler(true, "")
    }

    override func popoverWillShow(in window: SFSafariWindow) {
        SafariExtensionViewController.shared.loadPopover(window: window)
    }

    override func popoverDidClose(in window: SFSafariWindow) {
        SafariExtensionViewController.shared.stopCountdownTimer()
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
