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
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var settingButton: NSButton!
    
    weak var item: AnyObject?
    
    func setData(_ item :AnyObject) {
        self.refreshButton.isHidden = true
        self.settingButton.isHidden = true
        if item is ToolItem {
            let toolItem = item as! ToolItem
            self.titleLabel.stringValue = toolItem.title
            self.iconImageView.image = NSImage.init(named: NSImage.applicationIconName)
        }else if item is ToolSet {
            let toolSet = item as! ToolSet
            if toolSet.isRoot() {
                self.titleLabel.stringValue = ""
                self.iconImageView.image = NSImage.init(named:NSImage.homeTemplateName)
                self.refreshButton.isHidden = false
                self.settingButton.isHidden = false
            }else {
                self.titleLabel.stringValue = toolSet.title
                self.iconImageView.image = NSImage.init(named:NSImage.folderName)
            }
        }
        self.item = item
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        let delegate = self.delegate as? SettingCellDelegate
        if delegate != nil {
            delegate?.settingCellRefreshRequest(self)
        }
    }
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        let delegate = self.delegate as? SettingCellDelegate
        if delegate != nil {
            let cgpoint = self.settingButton.frame.origin
            let point = NSPointFromCGPoint(cgpoint)
            delegate?.settingCellSettingRequest(self, position: point)
        }
    }
    
}

protocol SettingCellDelegate : BaseCellViewDelegate {
    
    func settingCellRefreshRequest(_ cell: SettingCellView)
    func settingCellSettingRequest(_ cell: SettingCellView, position: NSPoint)
    
}
