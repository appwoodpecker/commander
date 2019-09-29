//
//  QRApp.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/9/26.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class QRApp: AppItem {
    
    override class func name() -> String {
        return "Pasteboard QRCode"
    }
    
    override func run() -> Void {
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
