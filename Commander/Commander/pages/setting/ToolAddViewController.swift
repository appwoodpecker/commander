//
//  AddViewController.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/5.
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
            let name = self.nameTextfield.stringValue
            if name.count == 0 || scriptText.count == 0 {
                return;
            }
            let scriptIndex = self.scriptTypeButton.indexOfSelectedItem
            let scriptType = Config.shared().supportScriptTypes()[scriptIndex]
            let groupPath = Config.shared().workPath().appendingPathComponent((self.toolset?.path)!)
            let groupURL = URL.init(fileURLWithPath: groupPath)
            
            ///everything is okay, now let's create it
            //1.tool bundle
            let bundleName = name + ".bundle"
            let bundleURL = groupURL.appendingPathComponent(bundleName)
            let fm = FileManager.default
            try? fm.createDirectory(at: bundleURL, withIntermediateDirectories: true, attributes: nil)
            //2.save code
            let scriptName = "main." + scriptType
            let scriptURL = bundleURL.appendingPathComponent(scriptName)
            let scriptPath = scriptURL.path
            let scriptData = scriptText.data(using: String.Encoding.utf8)
            let result = fm.createFile(atPath: scriptPath, contents: scriptData, attributes: nil)
            if !result {
                return;
            }
            //3.icon
            if let iconURL = self.iconURL {
                let targetURL = bundleURL.appendingPathComponent("icon.png")
                try? fm.copyItem(at: iconURL, to: targetURL)
            }
            let toolItem = ToolItem.init()
            toolItem.title = name
            toolItem.scriptFile = scriptName
            toolItem.toolset = self.toolset
            self.toolset?.children.append(toolItem)
            if let callback = self.completionCallback  {
                callback(toolItem)
            }
        }else {
            if let toolItem = self.toolitem {
                let scriptText = self.codeTextView.string
                let name = self.nameTextfield.stringValue
                if name.count == 0 || scriptText.count == 0 {
                    return;
                }
                let scriptIndex = self.scriptTypeButton.indexOfSelectedItem
                let scriptType = Config.shared().supportScriptTypes()[scriptIndex]
                let setURL = toolItem.toolset.absoluteURL()
                let newFileName = name + ".bundle"
                let fm = FileManager.default
                //1.name
                if toolItem.title != name {
                    let oldURL = setURL.appendingPathComponent(toolItem.path())
                    let newURL = setURL.appendingPathComponent(newFileName)
                    try? fm.moveItem(at: oldURL, to: newURL)
                    toolItem.title = name
                }
                let bundleURL = toolItem.toolset.absoluteURL().appendingPathComponent(newFileName)
                //2.code
                let scriptName = "main." + scriptType
                if let scriptData = scriptText.data(using: String.Encoding.utf8) {
                    let scriptURL = bundleURL.appendingPathComponent(scriptName)
                    try? scriptData.write(to:scriptURL)
                    toolItem.scriptFile = scriptName
                }
                //3.icon
                if let iconURL = self.iconURL {
                    let targetURL = bundleURL.appendingPathComponent("icon.png")
                    //remove old icon
                    try? fm.removeItem(at: targetURL)
                    try? fm.copyItem(at: iconURL, to: targetURL)
                }
                
                if let callback = self.completionCallback  {
                    callback(toolItem)
                }
            }
        }
    }
    
}