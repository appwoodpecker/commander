//
//  ToolsetAddViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class ToolsetAddViewController: NSViewController {

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var nameTextfield: NSTextField!
    
    //add
    var parentSet: ToolSet?
    //edit
    var toolSet: ToolSet?
    var completionCallback: ((ToolSet) -> Void)?
    var cancelCallback: (() -> Void)?
    var iconURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadContent()
    }
    
    func setup() {
        
    }
    
    func loadContent() {
        if isEdit() {
            if let toolset = self.toolSet {
                //icon
                let iconPath = toolset.iconPath()
                let image = NSImage.init(contentsOfFile: iconPath)
                self.iconImageView.image = image
                //name
                self.nameTextfield.stringValue = toolset.title
            }
        }
    }
    
    func isEdit() -> Bool {
        return (self.toolSet != nil)
    }
    
    func isAddNew() -> Bool {
        return !isEdit()
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
                return
            }
            //1. create folder
            let parentURL = self.parentSet!.absoluteURL()
            let setURL = parentURL.appendingPathComponent(title)
            let fm = FileManager.default
            do {
                try fm.createDirectory(at: setURL, withIntermediateDirectories: true, attributes: nil)
            }catch {
                print(error)
            }
            //2. icon
            if let iconURL = self.iconURL {
                let targetURL = setURL.appendingPathComponent("icon.png")
                try? fm.copyItem(at: iconURL, to: targetURL)
            }
            let toolSet = ToolSet.init()
            toolSet.title = title;
            toolSet.path = self.parentSet?.path.appendingPathComponent(title)
            toolSet.children = [Any].init()
            toolSet.parentSet = self.parentSet
            self.parentSet?.children.append(toolSet)
            
            if let callback = self.completionCallback  {
                callback(toolSet)
            }
        }else {
            if let toolset = self.toolSet {
                let title = self.nameTextfield.stringValue
                if title.count == 0 {
                    return
                }
                //1. name
                let fm = FileManager.default
                let parentURL = toolset.parentSet!.absoluteURL()
                let setURL = parentURL.appendingPathComponent(title)
                if title != toolSet?.title {
                    let oldSetURL = parentURL.appendingPathComponent(toolset.title)
                    try? fm.moveItem(at: oldSetURL, to: setURL)
                    toolset.title = title
                    toolset.path = toolset.parentSet?.path.appendingPathComponent(title)
                }
                //2. icon
                if let iconURL = self.iconURL {
                    let targetURL = setURL.appendingPathComponent("icon.png")
                    //remove old icon
                    try? fm.removeItem(at: targetURL)
                    try? fm.copyItem(at: iconURL, to: targetURL)
                }
                if let callback = self.completionCallback  {
                    callback(toolset)
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
