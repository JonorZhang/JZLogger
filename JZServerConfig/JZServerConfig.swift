//
//  JZServerConfig.swift
//  JZLogger
//
//  Created by Zhang on 2019/9/8.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

struct ServerConfig {
    let name: String
    let config: String
}

class JZServerConfig: NSObject {
    
    static let fileManager = FileManager.default
    
    /// cfg文件目录
    static let cfgDir: URL = {
        guard let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("JZServerConfig couldn't find documentDirectory")
        }
        
        // 创建配置目录
        let directoryURL = docDir.appendingPathComponent("com.jz.cfg")
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory( at: directoryURL, withIntermediateDirectories: true)
            } catch {
                fatalError("JZServerConfig couldn't create documentDirectory: \(directoryURL)")
            }
        }
        return directoryURL
    }()
    
    /// 所有cfg文件名
    static func cfgExists(name: String) -> Bool {
        let filename = (name + ".cfg").lowercased()
        if let subpaths = fileManager.subpaths(atPath: cfgDir.path) {
            for path in subpaths {
                if filename == path.lowercased() {
                    return true
                }
            }
        }
        return false
    }

    /// 所有cfg文件内容
    static func svrCfgContents() -> [ServerConfig] {
        let subpaths = fileManager.subpaths(atPath: cfgDir.path)
        let urls = subpaths?.map{ cfgDir.appendingPathComponent($0) } ?? []
        return urls.map { (url) -> ServerConfig in
            let name = url.deletingPathExtension().lastPathComponent
            let data = fileManager.contents(atPath: url.path) ?? Data()
            let cfg = String(data: data, encoding: .utf8) ?? ""
            return ServerConfig(name: name, config: cfg)
        }
    }
    
    static func deleteCfg(name: String) {
        let url = cfgDir.appendingPathComponent(name).appendingPathExtension("cfg")
        try? fileManager.removeItem(at: url)
    }
    
    static func updateCfg(oldName: String? = nil, newName: String, cfg: String) -> Error? {
        if let oldName = oldName {
            let oldurl = cfgDir.appendingPathComponent(oldName).appendingPathExtension("cfg")
            try? fileManager.removeItem(at: oldurl)
        }
        
        let newurl = cfgDir.appendingPathComponent(newName).appendingPathExtension("cfg")
        do {
            try cfg.write(to: newurl, atomically: true, encoding: .utf8)
            return nil
        } catch {
            return error
        }
    }
}
