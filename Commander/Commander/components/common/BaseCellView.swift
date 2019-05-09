//
//  BaseCellView.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/8.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class BaseCellView: NSTableCellView {

    weak var delegate: BaseCellViewDelegate?
    
    override func mouseDown(with event: NSEvent) {
        let clickCount = event.clickCount;
        if clickCount == 1 {
            if let delegate = self.delegate {
                delegate.cellClicked(self)
            }
            super.mouseDown(with: event)
        }else if(clickCount == 2){
            if let delegate = self.delegate {
                delegate.cellDoubleClicked(self)
            }
        }
    }
    
    override func rightMouseUp(with event: NSEvent) {
        let windowPos = event.locationInWindow;
        let point = self.convert(windowPos, from: nil)
        if let delegate = self.delegate {
            delegate.cellRightClicked(self,position: point)
        }
        super.rightMouseUp(with: event)
    }
    
}


protocol BaseCellViewDelegate : AnyObject {
    
    func cellClicked(_ cell: BaseCellView)
    func cellDoubleClicked(_ cell: BaseCellView)
    func cellRightClicked(_ cell: BaseCellView, position: NSPoint)
    
}
