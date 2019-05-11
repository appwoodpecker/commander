//
//  AddViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/5.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolAddViewController: NSViewController {
    
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var nameTextfield: NSTextField!
    @IBOutlet var codeTextView: NSTextView!
    @IBOutlet weak var scriptTypeButton: NSPopUpButton!
    
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
        loadContent()
    }
    
    func setup() {
        //script types
        scriptTypeButton.removeAllItems()
        let scriptTypes = Config.shared().selectScriptTypes()
        for type in scriptTypes {
            scriptTypeButton.addItem(withTitle: type)
        }
    }
    
    func isEdit() -> Bool {
        return (self.toolitem != nil)
    }
    
    func isAddNew() -> Bool {
        return !isEdit()
    }
    
    func loadContent() {
        if isEdit() {
            if let toolItem = self.toolitem {
                //icon
                let iconPath = toolItem.iconPath()
                let image = NSImage.init(contentsOfFile: iconPath)
                self.iconImageView.image = image
                //name
                self.nameTextfield.stringValue = toolItem.title
                //script type
                let scriptFile = toolItem.scriptFile
                if let ext = scriptFile!.pathExtension() {
                    let scriptTypes = Config.shared().supportScriptTypes()
                    if let scriptIndex = scriptTypes.firstIndex(of: ext) {
                        self.scriptTypeButton.selectItem(at: scriptIndex)
                    }
                }
                //script code
                let scriptPath = toolItem.scriptPath()
                if let data = NSData.init(contentsOfFile: scriptPath) {
                    if let text = String.init(data: data as Data, encoding: String.Encoding.utf8) {
                        self.codeTextView.string = text
                    }
                }
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
    
    @IBAction func scriptFileButtonPressed(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.allowedFileTypes = Config.shared().supportScriptTypes()
        let result = panel.runModal()
        if result != NSApplication.ModalResponse.OK || panel.url == nil {
            return
        }
        var text : String?
        let fileURL = panel.url
        let data = try? Data.init(contentsOf: fileURL!)
        if data != nil {
            text = String.init(data: data!, encoding: String.Encoding.utf8)
        }
        if text != nil {
            self.codeTextView.string = text!
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if isAddNew() {
            let scriptText = self.codeTextView.string
            let title = self.nameTextfield.stringValue
            if title.count == 0 || scriptText.count == 0 {
                return;
            }
            let scriptIndex = self.scriptTypeButton.indexOfSelectedItem
            let scriptType = Config.shared().supportScriptTypes()[scriptIndex]
            if let toolItem = ToolService.shared().doAddTool(title:title, scriptType: scriptType, scriptText: scriptText, iconURL: self.iconURL, parent: self.toolset!) {
                if let callback = self.completionCallback  {
                    callback(toolItem)
                }
            }
        }else {
            if let toolItem = self.toolitem {
                let scriptText = self.codeTextView.string
                let title = self.nameTextfield.stringValue
                if title.count == 0 || scriptText.count == 0 {
                    return;
                }
                let scriptIndex = self.scriptTypeButton.indexOfSelectedItem
                let scriptType = Config.shared().supportScriptTypes()[scriptIndex]
                ToolService.shared().doEditTool(title: title, scriptType: scriptType, scriptText: scriptText, iconURL: self.iconURL, toolItem: toolItem)
                if let callback = self.completionCallback  {
                    callback(toolItem)
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let callback = self.cancelCallback {
            callback()
        }
    }
    
    
}
