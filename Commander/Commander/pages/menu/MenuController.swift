//
//  StatusMenuController.swift
//  Commander
//
//  Created by 张小刚 on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class MenuController: NSObject {
    
    var statusItem: NSStatusItem!
    var toolSet: ToolSet!
    var menu: NSMenu!
    var window: NSWindow!
    var contentVC: NSViewController?
    
    private override init() {
        
    }
    
    private static let sharedInstance = MenuController.init()
    
    class func shared() -> MenuController {
        return sharedInstance
    }
    
    func setup() {
        //setup status item
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "CMD"
        self.statusItem = statusItem
        //
        loadContent()
    }
    
    func loadContent() {
        //load tools
        let toolset = ToolService.shared().loadTool()
        self.toolSet = toolset
        //load menu
        reloadMenu()
    }
    
    func reloadMenu() {
        if let toolSet = self.toolSet {
            //menu
            let menu = NSMenu.init()
            statusItem.menu = menu
            self.menu = menu;
            traverseAddMenuItem(toolSet:toolSet, menu: menu)
            //separator
            if menu.items.count > 0 {
                let lineItem = NSMenuItem.separator()
                menu.addItem(lineItem)
            }
            //setting
            let settingItem = NSMenuItem.init()
            settingItem.title = "Setting"
            settingItem.target = self;
            settingItem.action = #selector(MenuController.settingMenuSelected)
            menu.addItem(settingItem)
        }
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
        let iconPath = toolItem.iconPath()
        if let image = NSImage.init(contentsOfFile: iconPath) {
            image.size = NSMakeSize(16, 16)
            menuItem.image = image
        }
        menuItem.representedObject = toolItem
        menuItem.target = self
        menuItem.action = #selector(MenuController.toolMenuSelected(menuItem:))
        return menuItem
    }
    
    func menuItemWithToolSet(_ toolSet :ToolSet) -> NSMenuItem {
        let menuItem = NSMenuItem.init()
        menuItem.title = toolSet.title
        let iconPath = toolSet.iconPath()
        if let image = NSImage.init(contentsOfFile: iconPath) {
            image.size = NSMakeSize(16, 16)
            menuItem.image = image
        }
        let subMenu = NSMenu.init()
        menuItem.submenu = subMenu
        return menuItem
    }
    
    @objc func toolMenuSelected(menuItem: NSMenuItem) {
        let toolItem = menuItem.representedObject as! ToolItem
        let scriptPath = toolItem.scriptPath()
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
