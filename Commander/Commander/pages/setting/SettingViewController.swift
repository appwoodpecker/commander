//
//  SettingViewController.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/7.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController,NSOutlineViewDataSource,NSOutlineViewDelegate, SettingCellDelegate {
    
    var mToolset: ToolSet?
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var outlineLayout: NSView!
    @IBOutlet weak var editLayout: NSView!
    @IBOutlet weak var editDefaultLayout: NSTextField!
    
    @IBOutlet weak var settingButton: NSButton!
    
    
    var editVC: AnyObject?
    var editView: NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadContent()
        self.outlineView.expandItem(self.mToolset)
    }
    
    func setup() {
        let nib = NSNib.init(nibNamed: "SettingCellView", bundle: nil)
        self.outlineView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SettingCellView"))
        self.outlineView.rowHeight = 24.0
        self.outlineView.usesAlternatingRowBackgroundColors = true
        setEditAreaWidth(preferedEditAreaWidth())
        
    }

    func setToolset(toolset: ToolSet) {
        self.mToolset = toolset
    }
    
    func loadContent() {
        self.outlineView.reloadData()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var count = 0
        if item == nil {
            if let toolSet = self.mToolset {
                count = toolSet.children.count
            }
        }else if item is ToolSet {
            let tSet = item as! ToolSet
            count = tSet.children.count
        }
        return count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var childItem: Any?
        if item == nil {
            if let toolSet = self.mToolset {
                childItem = toolSet.children[index]
            }
        }else {
            if item is ToolSet {
                let tSet = item as! ToolSet
                childItem = tSet.children[index]
            }
        }
        return childItem!
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        var expandable = false
        if item is ToolSet {
            expandable = true
        }
        return expandable
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SettingCellView"), owner: nil)  as! SettingCellView
        cell.setData(item as AnyObject)
        cell.delegate = self
        return cell
    }
    
    func cellClicked(_ cell: BaseCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolItem {
            doEditTool(item as! ToolItem)
        }else if item is ToolSet {
            let toolset = item as! ToolSet
            if !toolset.isRoot() {
                doEditToolset(toolset)
            }else {
                resetEditArea()
            }
        }else {
            resetEditArea()
        }
    }
    
    func cellDoubleClicked(_ cell: BaseCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolSet {
            if !self.outlineView.isItemExpanded(item) {
                self.outlineView.expandItem(item, expandChildren: false)
            }else {
                self.outlineView.collapseItem(item, collapseChildren: false)
            }
        }
    }
    
    func cellRightClicked(_ cell: BaseCellView, position: NSPoint) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolSet {
            doActionWithToolset(item as! ToolSet,sender: cell, point: position)
        }else if item is ToolItem {
            doActionWithTool(item as! ToolItem, sender: cell, point: position)
        }
    }
    
    func doActionWithToolset(_ toolset: ToolSet, sender: NSView, point: NSPoint) {
        if toolset.isRoot() {
            return
        }
        let menu = NSMenu.init()
        //add tool
        let toolItem = NSMenuItem.init()
        toolItem.title = "Add Tool"
        toolItem.representedObject = toolset
        toolItem.target = self
        toolItem.action = #selector(SettingViewController.addToolMenuClicked(_:))
        menu.addItem(toolItem)
        //add toolset
        let setItem = NSMenuItem.init()
        setItem.title = "Add Toolset"
        setItem.representedObject = toolset
        setItem.target = self
        setItem.action = #selector(SettingViewController.addToolsetMenuClicked(_:))
        menu.addItem(setItem)
        //edit
        let editItem = NSMenuItem.init()
        editItem.title = "Edit"
        editItem.representedObject = toolset
        editItem.target = self
        editItem.action = #selector(SettingViewController.editMenuClicked(_:))
        menu.addItem(editItem)
        //move up
        let index = outlineView.childIndex(forItem: toolset)
        if index > 0 {
            let upItem = NSMenuItem.init()
            upItem.title = "Move Up"
            upItem.representedObject = toolset
            upItem.target = self
            upItem.action = #selector(SettingViewController.moveupMenuClicked(_:))
            menu.addItem(upItem)
        }
        //remove
        let removeItem = NSMenuItem.init()
        removeItem.title = "Delete"
        removeItem.representedObject = toolset
        removeItem.target = self
        removeItem.action = #selector(SettingViewController.deleteMenuClicked(_:))
        menu.addItem(removeItem)
        //show in finder
        let finderItem = NSMenuItem.init()
        finderItem.title = "Show in Finder"
        finderItem.representedObject = toolset
        finderItem.target = self
        finderItem.action = #selector(SettingViewController.finderMenuClicked(_:))
        menu.addItem(finderItem)
        
        menu.popUp(positioning: nil, at:point, in: sender)
    }
    
    func doActionWithTool(_ toolItem: ToolItem, sender: NSView, point: NSPoint) {
        let menu = NSMenu.init()
        //edit
        let editItem = NSMenuItem.init()
        editItem.title = "Edit"
        editItem.representedObject = toolItem
        editItem.target = self
        editItem.action = #selector(SettingViewController.editMenuClicked(_:))
        menu.addItem(editItem)
        //move up
        let index = outlineView.childIndex(forItem: toolItem)
        if index > 0 {
            let upItem = NSMenuItem.init()
            upItem.title = "Move Up"
            upItem.representedObject = toolItem
            upItem.target = self
            upItem.action = #selector(SettingViewController.moveupMenuClicked(_:))
            menu.addItem(upItem)
        }
        //remove
        let removeItem = NSMenuItem.init()
        removeItem.title = "Delete"
        removeItem.representedObject = toolItem
        removeItem.target = self
        removeItem.action = #selector(SettingViewController.deleteMenuClicked(_:))
        menu.addItem(removeItem)
        //show in finder
        let finderItem = NSMenuItem.init()
        finderItem.title = "Show in Finder"
        finderItem.representedObject = toolItem
        finderItem.target = self
        finderItem.action = #selector(SettingViewController.finderMenuClicked(_:))
        menu.addItem(finderItem)
        
        menu.popUp(positioning: nil, at: point, in: sender)
    }
    
    func doActionWithRootset(sender: NSView, point: NSPoint) {
        if let toolset = self.mToolset {
            let menu = NSMenu.init()
            //add tool
            let toolItem = NSMenuItem.init()
            toolItem.title = "Add Tool"
            toolItem.representedObject = toolset
            toolItem.target = self
            toolItem.action = #selector(SettingViewController.addToolMenuClicked(_:))
            menu.addItem(toolItem)
            //add toolset
            let setItem = NSMenuItem.init()
            setItem.title = "Add Toolset"
            setItem.representedObject = toolset
            setItem.target = self
            setItem.action = #selector(SettingViewController.addToolsetMenuClicked(_:))
            menu.addItem(setItem)
            //startup on computer launch
            let autorun = AutorunUtil.applicationIsInStartUpItems()
            if !autorun {
                let launchItem = NSMenuItem.init()
                launchItem.title = "Enable auto launch"
                launchItem.representedObject = toolset
                launchItem.target = self
                launchItem.action = #selector(SettingViewController.toggleAutorunMenuClicked(_:))
                menu.addItem(launchItem)
            }
            //show in finder
            let finderItem = NSMenuItem.init()
            finderItem.title = "Show in Finder"
            finderItem.representedObject = toolset
            finderItem.target = self
            finderItem.action = #selector(SettingViewController.finderMenuClicked(_:))
            menu.addItem(finderItem)
            
            menu.popUp(positioning: nil, at: point, in: sender)
        }
    }
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        let point = NSZeroPoint
        let sender = self.settingButton
        let row = self.outlineView.selectedRow
        if row >= 0 {
            if let item = self.outlineView.item(atRow: row) {
                if item is ToolSet {
                    doActionWithToolset(item as! ToolSet,sender: sender!,point: point)
                }else if item is ToolItem {
                    doActionWithTool(item as! ToolItem, sender: sender!,point: point)
                }
            }else {
                doActionWithRootset(sender: sender!,point: point)
            }
        }else {
            doActionWithRootset(sender: sender!,point: point)
        }
    }
    
    @IBAction func reloadActionButtonPressed(_ sender: Any) {
        MenuController.shared().reloadMenu()
    }
    
    //add tool
    @objc func addToolMenuClicked(_ menuItem: NSMenuItem) {
        let item = menuItem.representedObject
        if item == nil {
            return;
        }
        if item is ToolSet {
            doAddTool(item as! ToolSet)
        }
    }
    
    //add toolset
    @objc func addToolsetMenuClicked(_ menuItem: NSMenuItem) {
        let item = menuItem.representedObject
        if item == nil {
            return;
        }
        if item is ToolSet {
            doAddToolset(item as! ToolSet)
        }
    }
    
    //move up
    @objc func moveupMenuClicked(_ menuItem: NSMenuItem) {
        let item = menuItem.representedObject
        if item == nil {
            return;
        }
        var toolSet: ToolSet?
        if item is ToolItem {
            let toolItem = item as! ToolItem
            toolSet = toolItem.toolset
        }else if item is ToolSet {
            let thisItem = item as! ToolSet
            toolSet = thisItem.parentSet
        }
        if toolSet != nil {
            let index = self.outlineView.childIndex(forItem: item!)
            if index >= 1 {
                let targetIndex = index-1
                toolSet!.children.remove(at: index)
                toolSet!.children.insert(item!, at: targetIndex)
                if((toolSet?.isRoot())!) {
                    self.outlineView.reloadItem(nil, reloadChildren: true)
                }else {
                    self.outlineView.reloadItem(toolSet, reloadChildren: true)
                }
                //save sorted order
                ToolService.shared().doSaveToolsetOrder(toolSet!)
            }
        }
    }
    
    //edit
    @objc func editMenuClicked(_ menuItem: NSMenuItem) {
        let item = menuItem.representedObject
        if item == nil {
            return;
        }
        if item is ToolItem {
            let toolItem = item as! ToolItem
            doEditTool(toolItem)
        }else if item is ToolSet {
            let toolSet = item as! ToolSet
            doEditToolset(toolSet)
        }
    }
    
    //delete
    @objc func deleteMenuClicked(_ menuItem: NSMenuItem) {
        let alert = NSAlert.init()
        alert.messageText = "Are you sure to delete it"
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        if result.rawValue != 1000 {
            return
        }
        
        let item = menuItem.representedObject
        if item == nil {
            return;
        }
        var toolSet: ToolSet?
        if item is ToolItem {
            let toolItem = item as! ToolItem
            toolSet = toolItem.toolset
        }else if item is ToolSet {
            let thisItem = item as! ToolSet
            toolSet = thisItem.parentSet
        }
        if toolSet != nil {
            let index = self.outlineView.childIndex(forItem: item!)
            if index >= 0 {
                toolSet?.children.remove(at: index)
                if((toolSet?.isRoot())!) {
                    self.outlineView.reloadItem(nil, reloadChildren: true)
                }else {
                    self.outlineView.reloadItem(toolSet, reloadChildren: true)
                }
                //delete local file
                if item is ToolItem {
                    let toolItem = item as! ToolItem
                    ToolService.shared().doDeleteTool(toolItem)
                }else if item is ToolSet {
                    let toolset = item as! ToolSet
                    ToolService.shared().doDeleteToolset(toolset)
                }
                //save sorted order
                ToolService.shared().doSaveToolsetOrder(toolSet!)
                resetEditArea()
            }
        }
    }
    
    //enable auto run
    @objc func toggleAutorunMenuClicked(_ menuItem: NSMenuItem) {
        AutorunUtil.toggleLaunchAtStartup()
    }
    
    //show in finder
    @objc func finderMenuClicked(_ menuItem: NSMenuItem) {
        let item = menuItem.representedObject
        if item is ToolSet {
            let toolset = item as!ToolSet
            NSWorkspace.shared.openFile(toolset.absolutePath())
        }else if item is ToolItem {
            let toolItem = item as!ToolItem
            let fileURL = URL.init(fileURLWithPath: toolItem.path())
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        }
        
    }
    
    //add tool
    func doAddTool(_ toolset: ToolSet) {
        resetEditArea()
        let addVC = ToolAddViewController.init(nibName: "ToolAddViewController", bundle: nil)
        addVC.toolset = toolset
        self.editVC = addVC
        let view = addVC.view
        self.editLayout.addSubview(view)
        self.editView = view
        setEditAreaWidth(preferedEditAreaWidth())
        view.frame = self.editLayout.bounds
        addVC.completionCallback = {(toolItem: ToolItem) -> Void in
            if(toolset.isRoot()) {
                self.outlineView.reloadItem(nil, reloadChildren: true)
                self.outlineView.expandItem(nil)
            }else {
                self.outlineView.reloadItem(toolset, reloadChildren: true)
                self.outlineView.expandItem(toolset)
            }
            self.resetEditArea()
            self.outlineView.deselectAll(nil)
            let toolIndex = self.outlineView.row(forItem: toolItem)
            self.outlineView.selectRowIndexes(IndexSet.init(integer: toolIndex), byExtendingSelection: false)
            //save sorted order
            ToolService.shared().doSaveToolsetOrder(toolset)
        }
        self.editDefaultLayout.isHidden = true
    }
    
    //edit tool
    func doEditTool(_ toolItem: ToolItem) {
        resetEditArea()
        let addVC = ToolAddViewController.init(nibName: "ToolAddViewController", bundle: nil)
        addVC.toolitem = toolItem
        self.editVC = addVC
        let view = addVC.view
        self.editLayout.addSubview(view)
        self.editView = view
        setEditAreaWidth(preferedEditAreaWidth())
        view.frame = self.editLayout.bounds
        addVC.completionCallback = {(toolItem: ToolItem) -> Void in
            self.outlineView.reloadItem(toolItem)
            self.resetEditArea()
        }
        self.editDefaultLayout.isHidden = true
    }
    
    //edit tooset
    func doAddToolset(_ parentSet: ToolSet) {
        resetEditArea()
        let addVC = ToolsetAddViewController.init(nibName: "ToolsetAddViewController", bundle: nil)
        addVC.parentSet = parentSet
        self.editVC = addVC
        let view = addVC.view
        self.editLayout.addSubview(view)
        self.editView = view
        setEditAreaWidth(preferedEditAreaWidth())
        view.frame = self.editLayout.bounds
        addVC.completionCallback = {(toolset: ToolSet) -> Void in
            if parentSet.isRoot() {
                self.outlineView.reloadItem(nil, reloadChildren: true)
                self.outlineView.expandItem(nil)
            }else {
                self.outlineView.reloadItem(parentSet, reloadChildren: true)
                self.outlineView.expandItem(parentSet)
            }
            self.resetEditArea()
            self.outlineView.deselectAll(nil)
            let setIndex = self.outlineView.row(forItem: toolset)
            self.outlineView.selectRowIndexes(IndexSet.init(integer: setIndex), byExtendingSelection: false)
            //save sorted order
            ToolService.shared().doSaveToolsetOrder(parentSet)
        }
        self.editDefaultLayout.isHidden = true
    }
    
    //edit toolset
    func doEditToolset(_ toolset: ToolSet) {
        resetEditArea()
        let addVC = ToolsetAddViewController.init(nibName: "ToolsetAddViewController", bundle: nil)
        addVC.toolSet = toolset
        self.editVC = addVC
        let view = addVC.view
        self.editLayout.addSubview(view)
        self.editView = view
        setEditAreaWidth(preferedEditAreaWidth())
        view.frame = self.editLayout.bounds
        addVC.completionCallback = { (toolset: ToolSet) -> Void in
            self.outlineView.reloadItem(toolset)
            self.resetEditArea()
        }
        self.editDefaultLayout.isHidden = true
    }
    
    func resetEditArea() {
        if self.editView != nil {
            self.editView?.removeFromSuperview()
            self.editView = nil
            self.editDefaultLayout.isHidden = false
        }
    }
    
    func setEditAreaWidth(_ width: CGFloat) {
        //tree frame
        let totalWidth = self.splitView.bounds.size.width
        var treeFrame = self.outlineLayout.frame
        var treeSize = treeFrame.size
        treeSize.width = totalWidth - width - self.splitView.dividerThickness;
        treeFrame.size = treeSize;
        self.outlineLayout.frame = treeFrame
        //edit frame
        var frame = self.editLayout.frame
        var size = frame.size
        size.width = width;
        frame.size = size
        self.editLayout.frame = frame
        self.splitView.needsLayout = true
    }
    
    func preferedEditAreaWidth() -> CGFloat {
        return 520
    }
    
}
