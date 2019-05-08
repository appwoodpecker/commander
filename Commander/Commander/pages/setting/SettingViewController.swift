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
        setEditAreaWidth(0)
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
        cell.setData(item)
        cell.delegate = self
        return cell
    }
    
    func settingCellToolAddRequest(_ cell: SettingCellView) {
        if self.editView != nil {
            self.editView?.removeFromSuperview()
            self.editView = nil
        }
        let addVC = ToolAddViewController.init(nibName: "ToolAddViewController", bundle: nil)
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if (item is ToolSet) {
            addVC.toolset = item as? ToolSet
        }else {
            addVC.toolitem = item as? ToolItem
        }
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
    
    func settingCellToolsetAddRequest(_ cell: SettingCellView) {
        if self.editView != nil {
            self.editView?.removeFromSuperview()
            self.editView = nil
        }
        let addVC = ToolsetAddViewController.init(nibName: "ToolsetAddViewController", bundle: nil)
        let row = self.outlineView.row(for: cell)
        let item = self.outlineView.item(atRow: row)
        if (item is ToolSet) {
            addVC.toolset = item as? ToolSet
        }
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
    
    func settingCellMoveupRequest(_ cell: SettingCellView) {
        
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
