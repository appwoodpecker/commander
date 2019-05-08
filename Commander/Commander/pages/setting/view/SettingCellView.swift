//
//  SettingCellView.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class SettingCellView: BaseCellView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var toolButton: NSButton!
    @IBOutlet weak var toolsetButton: NSButton!
    @IBOutlet weak var moveupButton: NSButton!
    
    weak var item: AnyObject?
    
    func setData(_ item :AnyObject) {
        toolButton.isHidden = true
        toolsetButton.isHidden = true
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
            toolButton.isHidden = false
            toolsetButton.isHidden = false
        }
        self.item = item
    }
    
    func setMovable(_ movable: Bool) {
        self.moveupButton.isHidden = !movable
    }
    
    @IBAction func toolAddButtonPressed(_ sender: Any) {
        if let delegate = self.delegate as? SettingCellDelegate {
            delegate.settingCellToolAddRequest(self)
        }
    }
    
    @IBAction func toolsetAddButtonPressed(_ sender: Any) {
        if let delegate = self.delegate as? SettingCellDelegate {
            delegate.settingCellToolsetAddRequest(self)
        }
    }
    
    @IBAction func moveupButtonPressed(_ sender: Any) {
        if let delegate = self.delegate as? SettingCellDelegate {
            delegate.settingCellMoveupRequest(self)
        }
    }
}

protocol SettingCellDelegate : BaseCellViewDelegate {
    
    func settingCellToolAddRequest(_ cell: SettingCellView)
    
    func settingCellToolsetAddRequest(_ cell: SettingCellView)
    
    func settingCellMoveupRequest(_ cell: SettingCellView)
    
}
