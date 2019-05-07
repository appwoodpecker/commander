//
//  SettingCellView.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class SettingCellView: NSTableCellView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var toolButton: NSButton!
    @IBOutlet weak var toolsetButton: NSButton!
    @IBOutlet weak var moveupButton: NSButton!
    
    weak var delegate: SettingCellDelegate?
    
    func setData(_ item :Any) {
        if item is ToolItem {
            let toolItem = item as! ToolItem
            self.titleLabel.stringValue = toolItem.title
        }else if item is ToolSet {
            let toolSet = item as! ToolSet
            if toolSet.path == "/" {
                self.titleLabel.stringValue = "🏠"
            }else {
                self.titleLabel.stringValue = toolSet.title
            }
        }
    }
    
    @IBAction func toolAddButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.settingCellToolAddRequest(self)
        }
    }
    
    @IBAction func toolsetAddButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.settingCellToolsetAddRequest(self)
        }
    }
    
    @IBAction func moveupButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.settingCellMoveupRequest(self)
        }
    }
}

protocol SettingCellDelegate : AnyObject {
    
    func settingCellToolAddRequest(_ cell: SettingCellView)
    
    func settingCellToolsetAddRequest(_ cell: SettingCellView)
    
    func settingCellMoveupRequest(_ cell: SettingCellView)
    
}
