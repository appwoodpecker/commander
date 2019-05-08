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
    var toolSet: ToolSet!
    var menu: NSMenu!
    var window: NSWindow!
    var contentVC: NSViewController?
    
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
        let toolset = ToolService.shared().loadTool()
        self.toolSet = toolset
        traverseAddMenuItem(toolSet: toolset, menu: menu)
        menuItem.title = "Setting"
        menuItem.target = self;
        menuItem.action = #selector(StatusMenuController.settingMenuSelected)
        menu.addItem(menuItem)
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
        let scriptPath = Config.shared().workPath().appendingPathComponent(toolItem.scriptPath())
        let exe = Config.shared().exeForScriptFile(scriptPath)
        if let exePath = exe {
            let task = Process.init()
            task.launchPath = exePath
            task.arguments = [scriptPath]
            task.launch()
        }
    }
    
    @objc func settingMenuSelected() {
        let vc = SettingViewController.init(nibName: "SettingViewController", bundle: nil)
        self.contentVC = vc
        vc.setToolset(toolset: self.toolSet)
        self.window.contentViewController = self.contentVC
        self.window.title = "Setting"
        self.window.makeKeyAndOrderFront(nil)
    }
    
}
