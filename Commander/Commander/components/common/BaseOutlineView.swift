//
//  BaseOutlineView.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/8.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class BaseOutlineView: NSOutlineView {
    
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        return true
    }
    
    
    
    
    
}
