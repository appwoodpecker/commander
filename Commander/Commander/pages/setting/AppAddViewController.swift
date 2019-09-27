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
    var toolitem: ToolItem?
    var completionCallback: ((ToolItem) -> Void)?
    var cancelCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
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
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
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
    
}
