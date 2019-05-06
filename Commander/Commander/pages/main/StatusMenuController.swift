//
//  StatusMenuController.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var indexVC: IndexViewController?
    var window: NSWindow!
    
    func setup() {
        //setup status item
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "CMD"
        self.statusItem = statusItem
        //
        loadContent()
    }
    
    func loadContent() {
        //main menu
        let menu = NSMenu.init()
        let menuItem = NSMenuItem.init()
        statusItem.menu = menu
        self.menu = menu;
        //load tools
        let path = "/Users/zhangxiaogang/Desktop/workspace"
        let toolset = ToolService.shared().loadTool(path: path)
        
        menuItem.title = "Add Cmd"
        menuItem.target = self;
        menuItem.action = #selector(StatusMenuController.addMenuSelected)
        menu.addItem(menuItem)
        
    }
    
    
    @objc func addMenuSelected() {
        let indexVC = IndexViewController.init(nibName: "IndexViewController", bundle: nil)
        self.indexVC = indexVC
        self.window.contentViewController = self.indexVC
        self.window .makeKeyAndOrderFront(nil)
    }
    
    func runShell(file path: String) {
        let task = Process.init()
        task.launchPath = "/bin/bash"
        task.arguments = [path]
        task.launch()
    }
    
    func runPython(file path: String) {
        let task = Process.init()
        task.launchPath = "/usr/bin/python"
        task.arguments = [path]
        task.launch()
    }
    
}
