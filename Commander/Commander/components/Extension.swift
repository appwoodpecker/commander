//
//  Extension.swift
//  Commander
//
//  Created by zhangxiaogang on 2019/5/6.
//  Copyright © 2019 woodpecker. All rights reserved.
//

import Foundation


extension String {
    
    func appendingPathComponent(_ path: String) -> String {
        let url = URL.init(string: self)?.appendingPathComponent(path)
        let resultPath = url?.absoluteString
        return resultPath!
    }
    
    //test.py -> py
    func pathExtension() -> String? {
        let path = self
        let components = path.components(separatedBy: ".")
        var ext :String?
        if components.count > 1 {
            ext = components.last
        }
        return ext
    }
}
