//
//  AppAddViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/9/26.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class AppAddViewController: NSViewController {
    
    
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var nameTextfield: NSTextField!
    @IBOutlet weak var appPopupButton: NSPopUpButton!
    
    var iconURL: URL?
    //add
    var toolset: ToolSet?
    //edit
    var toolItem: ToolItem?
    var completionCallback: ((ToolItem) -> Void)?
    var cancelCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadContent()
    }
    
    func setup() {
        appPopupButton.removeAllItems()
        let list = Config.shared().getAppList()
        for item in list {
            let className = Config.shared().defaultPackage() + "." + item
            let clazz = NSClassFromString(className) as! AppItem.Type
            let name = clazz.name()
            appPopupButton.addItem(withTitle: name)
        }
    }
    
    func isEdit() -> Bool {
        return (self.toolItem != nil)
    }
    
    func isAddNew() -> Bool {
        return !isEdit()
    }
    
    func loadContent() {
        if !isEdit() {
            return
        }
        let toolItem = self.toolItem!
        //icon
        let iconPath = toolItem.iconPath()
        let image = NSImage.init(contentsOfFile: iconPath)
        self.iconImageView.image = image
        //name
        self.nameTextfield.stringValue = toolItem.title
        //app
        if let appId = toolItem.appId {
            let list = Config.shared().getAppList()
            if let appIndex = list.firstIndex(of: appId) {
                self.appPopupButton.selectItem(at: appIndex)
            }
        }
    }
    
    @IBAction func iconButtonPressed(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.allowedFileTypes = ["png"]
        let result = panel.runModal()
        if result != NSApplication.ModalResponse.OK || panel.url == nil {
            return
        }
        if let fileURL = panel.url {
            self.iconURL = fileURL
            let image = NSImage.init(contentsOf: fileURL)
            self.iconImageView.image = image
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if isAddNew() {
            let title = self.nameTextfield.stringValue
            if title.count == 0 {
                return;
            }
            let appIndex = self.appPopupButton.indexOfSelectedItem
            let appId = Config.shared().getAppList()[appIndex]
            if let toolItem = ToolService.shared().doAddApp(title: title, appId: appId, iconURL: self.iconURL, parent: self.toolset!) {
                if let callback = self.completionCallback  {
                    callback(toolItem)
                }
            }
        }else {
            let title = self.nameTextfield.stringValue
            if title.count == 0 {
                return;
            }
            let appIndex = self.appPopupButton.indexOfSelectedItem
            let appId = Config.shared().getAppList()[appIndex]
            ToolService.shared().doEditApp(title: title, appId: appId, iconURL: self.iconURL, toolItem: self.toolItem!)
            if let callback = self.completionCallback  {
                callback(self.toolItem!)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let callback = self.cancelCallback {
            callback()
        }
    }
    
}
