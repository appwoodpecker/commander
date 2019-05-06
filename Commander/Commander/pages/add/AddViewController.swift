//
//  AddViewController.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/5.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class AddViewController: NSViewController {
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var nameTextfield: NSTextField!
    
    @IBOutlet var codeTextView: NSTextView!
    @IBOutlet weak var scriptTypeButton: NSPopUpButton!
    
    var groupURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        //script types
        scriptTypeButton.removeAllItems()
        let scriptTypes = Config.shared().selectScriptTypes()
        for type in scriptTypes {
            scriptTypeButton.addItem(withTitle: type)
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
    
    @IBAction func toolsetButtonPressed(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.showsHiddenFiles = false
        let path = Config.shared().workPath()
        panel.directoryURL = URL.init(fileURLWithPath: path)
        let result = panel.runModal()
        if result != NSApplication.ModalResponse.OK || panel.url == nil {
            return
        }
        self.groupURL = panel.url
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let scriptText = self.codeTextView.string
        let name = self.nameTextfield.stringValue
        if name.count == 0 || scriptText.count == 0 {
            return;
        }
        let scriptIndex = self.scriptTypeButton.indexOfSelectedItem
        let scriptType = Config.shared().supportScriptTypes()[scriptIndex]
        var groupURL = self.groupURL
        if groupURL == nil {
            groupURL = URL.init(fileURLWithPath:Config.shared().workPath())
        }
        ///everything is okay, now let's create it
        //1.tool bundle
        let bundleName = name + ".bundle"
        let bundleURL = groupURL?.appendingPathComponent(bundleName)
        let fm = FileManager.default
        try? fm.createDirectory(at: bundleURL!, withIntermediateDirectories: true, attributes: nil)
        //2.save code
        let scriptName = "main." + scriptType
        let scriptURL = bundleURL?.appendingPathComponent(scriptName)
        let scriptPath = scriptURL?.path
        let scriptData = scriptText.data(using: String.Encoding.utf8)
        var result = fm.createFile(atPath: scriptPath!, contents: scriptData, attributes: nil)
        if !result {
            return;
        }
        //3.manifest
        let configData = ["title" : name]
        let manifestData = try? JSONSerialization.data(withJSONObject: configData, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let manifestURL = bundleURL?.appendingPathComponent("manifest.json")
        let manifestPath = manifestURL?.path
        result = fm.createFile(atPath: manifestPath!, contents: manifestData, attributes: nil)
        if !result {
            return;
        }
        //4.icon
        //finish
        
    }
    
}
