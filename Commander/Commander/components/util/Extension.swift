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
}
