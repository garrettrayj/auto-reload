//
//  SafariExtensionHandler.swift
//  AutoReload
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 Garrett Johnson.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
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
