//
//  QRApp.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/9/26.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class QRApp: AppItem {
    
    override
    class func name() -> String {
        return "Text to qrcode"
    }
    
    override
    class func inputView() -> String {
        return "QRInputViewController"
    }
    
    override
    class func ouputView() -> String {
        return "QROutputViewController"
    }
}
