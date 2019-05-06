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
        let path = workPath()
        let toolset = ToolService.shared().loadTool(path: path)
        traverseAddMenuItem(toolSet: toolset, menu: menu)
        menuItem.title = "Add Cmd"
        menuItem.target = self;
        menuItem.action = #selector(StatusMenuController.addMenuSelected)
        menu.addItem(menuItem)
    }

    func workPath() -> String {
        return"/Users/zhangxiaogang/Documents/GitHub/Commander/workspace"
    }
    
    func traverseAddMenuItem(toolSet:ToolSet, menu: NSMenu) {
        let children = toolSet.children
        for item in children! {
            if item is ToolItem {
                let toolItem = item as! ToolItem
                let menuItem = menuItemWithTool(toolItem)
                menu.addItem(menuItem)
            }else if item is ToolSet {
                let toolSet = item as! ToolSet
                let menuItem = menuItemWithToolSet(toolSet)
                menu.addItem(menuItem)
                let subMenu = menuItem.submenu!
                traverseAddMenuItem(toolSet: toolSet, menu: subMenu)
            }
        }
    }
    
    func menuItemWithTool(_ toolItem :ToolItem) -> NSMenuItem {
        let menuItem = NSMenuItem.init()
        menuItem.title = toolItem.title
        menuItem.representedObject = toolItem
        menuItem.target = self
        menuItem.action = #selector(StatusMenuController.toolMenuSelected(menuItem:))
        return menuItem
    }
    
    func menuItemWithToolSet(_ toolSet :ToolSet) -> NSMenuItem {
        let menuItem = NSMenuItem.init()
        menuItem.title = toolSet.title
        let subMenu = NSMenu.init()
        menuItem.submenu = subMenu
        return menuItem
    }
    
    @objc func toolMenuSelected(menuItem: NSMenuItem) {
        let toolItem = menuItem.representedObject as! ToolItem
        let scriptPath = workPath().appendingPathComponent(toolItem.scriptPath)
        let exe = ToolService.shared().exeForScriptFile(scriptPath)
        if let exePath = exe {
            let task = Process.init()
            task.launchPath = exePath
            task.arguments = [scriptPath]
            task.launch()
        }
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
