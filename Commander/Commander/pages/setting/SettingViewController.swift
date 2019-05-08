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
            count = 1;
        }
        if item is ToolSet {
            let tSet = item as! ToolSet
            count = tSet.children.count
        }
        return count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var childItem: Any?
        if item == nil {
            childItem = self.mToolset
        }
        if item is ToolSet {
            let tSet = item as! ToolSet
            childItem = tSet.children[index]
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
        let index = outlineView.childIndex(forItem: item)
        cell.setMovable(index != 0)
        cell.delegate = self
        return cell
    }
    
    func settingCellToolAddRequest(_ cell: SettingCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolSet {
            doAddTool(item as! ToolSet)
        }
    }
    
    func settingCellToolsetAddRequest(_ cell: SettingCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolSet {
            doAddToolset(item as! ToolSet)
        }
    }
    
    func settingCellMoveupRequest(_ cell: SettingCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
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
                self.outlineView.reloadItem(toolSet, reloadChildren: true)
                //save sorted order
                doSaveToolsetOrder(toolSet!)
            }
        }
    }
    
    func cellClicked(_ cell: BaseCellView) {
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if item is ToolItem {
            doEditTool(item as! ToolItem)
        }else if item is ToolSet {
            doEditToolset(item as! ToolSet)
        }else {
            resetEditArea()
            self.setEditAreaWidth(0)
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
        
    }
    
    func resetEditArea() {
        if self.editView != nil {
            self.editView?.removeFromSuperview()
            self.editView = nil
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
        addVC.completionCallback = {
            self.setEditAreaWidth(0)
            self.outlineView.reloadData()
        }
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
        addVC.completionCallback = {
            self.setEditAreaWidth(0)
            self.outlineView.reloadData()
        }
    }
    
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
        addVC.completionCallback = {
            self.setEditAreaWidth(0)
            self.outlineView.reloadData()
        }
    }
    
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
        addVC.completionCallback = {
            self.setEditAreaWidth(0)
            self.outlineView.reloadData()
        }
    }
    
    func doSaveToolsetOrder(_ toolset: ToolSet) {
        var configData: [String:Any]?
        let configPath = toolset.configPath()
        if let data = NSData.init(contentsOfFile: configPath) {
            configData = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String:Any]
        }
        var sortList = [String].init()
        for item in toolset.children {
            if item is ToolItem {
                let toolItem = item as! ToolItem
                sortList.append(toolItem.fileName())
            }else if item is ToolSet {
                let toolSet = item as! ToolSet
                sortList.append(toolSet.title)
            }
        }
        if configData == nil {
            configData = [String:Any].init()
        }
        configData!["sort"] = sortList
        let fm = FileManager.default
        if !fm.fileExists(atPath: configPath) {
            fm.createFile(atPath: configPath, contents: nil, attributes: nil)
        }
        if let fileData = try? JSONSerialization.data(withJSONObject: configData!, options: JSONSerialization.WritingOptions.init(rawValue: 0)) {
            let fileURL = URL.init(fileURLWithPath: configPath)
            try? fileData.write(to: fileURL)
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
