//
//  QRInputViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/9/26.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class QRInputViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if let text = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) {
            MenuController.shared().disimss()
            let resultPage = QROutputViewController.init(nibName: "QROutputViewController", bundle: nil)
            resultPage.text = text
            if let window = MenuController.shared().window {
                window.contentViewController = resultPage
                window.title = ""
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
            }
        }
    }

}
