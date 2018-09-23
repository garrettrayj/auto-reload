//
//  SafariExtensionViewController.swift
//  SafariExtension
//
//  Created by Garrett Johnson on 9/23/18.
//  Copyright © 2018 DevSci. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
