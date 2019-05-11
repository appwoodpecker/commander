//
//  SettingCellView.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class SettingCellView: BaseCellView {
    
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    weak var item: AnyObject?
    
    func setData(_ item :AnyObject) {
        if item is ToolItem {
            let toolItem = item as! ToolItem
            self.titleLabel.stringValue = toolItem.title
            self.iconImageView.image = NSImage.init(named: "tool")
        }else if item is ToolSet {
            let toolSet = item as! ToolSet
            self.titleLabel.stringValue = toolSet.title
            self.iconImageView.image = NSImage.init(named:NSImage.folderName);

        }
        self.item = item
    }
    
}

protocol SettingCellDelegate : BaseCellViewDelegate {
    
}
