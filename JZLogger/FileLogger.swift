//
//  FileLogger.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/20.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class FileLogger: NSObject {
    
    let fileManager = FileManager.default
    
    lazy var fileHandle: FileHandle = {
        do {
            let handle = try FileHandle(forWritingTo: logFileURL as URL)
            return handle
        } catch {
            fatalError("FileLogger couldn't get fileWritingHandle: \(logFileURL)")
        }
    }()

    /// log文件目录
    lazy var logDir: URL = {
        guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("FileLogger couldn't find cachesDirectory")
        }
        // 创建日志目录
        let directoryURL = cachesDir.appendingPathComponent("com.jz.log")
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory( at: directoryURL, withIntermediateDirectories: true)
            } catch {
                fatalError("FileLogger couldn't create logDirectory: \(directoryURL)")
            }
        }
        return directoryURL
    }()

    /// 当前log文件URL
    lazy var logFileURL: URL = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd_HH:mm:ss"
        let filename = fmt.string(from: Date()) + ".log"
        let fileurl = logDir.appendingPathComponent(filename, isDirectory: false)
        
        let info = """
                    Incident Identifier: D76AA4D1-157E-49B4-BA8B-7922F7E6DD04
                    CrashReporter Key:   cfb5c4cfebc7fead3c5d4c7d1a926acad4daaa5d
                    Hardware Model:      iPhone8,1
                    Process:             Yoosee [21637]
                    Path:                \(fileurl)
                    Version:             1 (5.5)
                    Code Type:           ARM-64 (Native)

                    Date/Time:           2019-08-14 09:49:23.1606 +0800
                    Launch Time:         2019-08-14 09:48:42.4537 +0800
                    OS Version:          iPhone OS 12.1.4 (16D57)
                    """
        do {
            try info.write(to: fileurl, atomically: true, encoding: .utf8)
        } catch {
            fatalError("FileLogger couldn't create logFile: \(fileurl)")
        }
        
        return fileurl
    }()
    
    /// 所有历史log文件URL
    func allLogFiles() -> [URL] {
        return logDir.pathComponents.map{ logDir.appendingPathComponent($0) }
    }
    
    /// 读取一个log文件内容
    func readLog(_ url: URL) -> Data {
        return Data()
    }
    
    /// 追加一条记录到当前log文件
    func appendRecord(_ message: String) {
        do {
            if !fileManager.fileExists(atPath: logFileURL.path) {
                // 创建日志文件
                let line = message + "\n"
                try line.write(to: logFileURL, atomically: true, encoding: .utf8)
                
            } else {
                // 追加日志记录
                _ = fileHandle.seekToEndOfFile()
                let line = message + "\n"
                if let data = line.data(using: String.Encoding.utf8) {
                    fileHandle.write(data)
                }
            }
        } catch {
            print("FileLogger couldn't  write to file \(logFileURL).")
        }
    }
    
    /// 删除一个log文件
    func deleteLog(_ url: URL) {
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("FileLogger couldn't remove file \(url).")
        }
    }
}
