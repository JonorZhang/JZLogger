//
//  JZFileLogger.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/20.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

protocol JZFileLoggerDelegate: class {
    func fileLogger(_ logger: JZFileLogger, didInsert text: String)
}

class JZFileLogger: NSObject {
    
    static let shared = JZFileLogger()
    private override init() {}
    
    weak var delegate: JZFileLoggerDelegate?
    
    static let resourceBundle: Bundle? = {
        let fwBundle = Bundle(for: JZFileLogger.self)
        if let srcPath = fwBundle.path(forResource: "Resource", ofType: "bundle") {
            return Bundle(path: srcPath)
        }
        return nil
    }()
    
    let fileManager = FileManager.default
    
    lazy var fileHandle: FileHandle = {
        do {
            let handle = try FileHandle(forWritingTo: curLogFileURL as URL)
            return handle
        } catch {
            fatalError("JZFileLogger couldn't get fileWritingHandle: \(curLogFileURL)")
        }
    }()
    
    /// log文件目录
    lazy var logDir: URL = {
        guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("JZFileLogger couldn't find cachesDirectory")
        }

        // 创建日志目录
        let directoryURL = cachesDir.appendingPathComponent("com.jz.log")
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory( at: directoryURL, withIntermediateDirectories: true)
            } catch {
                fatalError("JZFileLogger couldn't create logDirectory: \(directoryURL)")
            }
        }
        return directoryURL
    }()

    func getDeviceInfo() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let datetime = fmt.string(from: Date())
        let dev = UIDevice.current
        
        let appVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?").\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")"
        
        return """
                ➤ Date/Time:                \(datetime)
                ➤ name:                     \(dev.name)
                ➤ model:                    \(dev.model)
                ➤ systemName:               \(dev.systemName)
                ➤ systemVersion:            \(dev.systemVersion)
                ➤ identifierForVendor:      \(dev.identifierForVendor?.uuidString ?? "?")
                ➤ bundleIdentifier:         \(Bundle.main.bundleIdentifier ?? "?")
                ➤ AppVersion:               \(appVersion)
                ➤ preferredLanguages:       \(Locale.preferredLanguages.first ?? "?")
                ➤ infoDictionary:           \(Bundle.main.infoDictionary ?? [:])
                ----------------------------------------------------------------------------------------
                \n\n
                """
    }
    
    /// 当前log文件URL
    lazy var curLogFileURL: URL = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = fmt.string(from: Date()) + ".log"
        let fileurl = logDir.appendingPathComponent(filename, isDirectory: false)
        
        do {
            try getDeviceInfo().write(to: fileurl, atomically: true, encoding: .utf8)
            print("日志路径：", fileurl.path)
        } catch {
            fatalError("JZFileLogger couldn't create logFile: \(fileurl)")
        }
        
        return fileurl
    }()
    
    /// 所有历史log文件URL
    func getAllFileURLs() -> [URL] {
        let subpaths = fileManager.subpaths(atPath: logDir.path)
        let fullpaths = subpaths?.map{ logDir.appendingPathComponent($0) }
        return fullpaths?.sorted { $0.absoluteString > $1.absoluteString } ?? []
    }
    
    /// 读取一个log文件内容
    func readLogFile(_ url: URL) -> Data? {
        let data = fileManager.contents(atPath: url.path)
        return data
    }
        
    /// 追加一条记录到当前log文件
    func insertText(_ message: String) {
        do {
            if !fileManager.fileExists(atPath: curLogFileURL.path) {
                // 创建日志文件
                let line = message + "\n"
                try line.write(to: curLogFileURL, atomically: true, encoding: .utf8)
                
            } else {
                // 追加日志记录
                _ = fileHandle.seekToEndOfFile()
                let line = message + "\n"
                if let data = line.data(using: String.Encoding.utf8) {
                    fileHandle.write(data)
                }
                delegate?.fileLogger(self, didInsert: line)
            }
        } catch {
            print("JZFileLogger couldn't  write to file \(curLogFileURL).")
        }
    }
    
    /// 删除一个log文件
    func deleteLogFile(_ url: URL) {
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("JZFileLogger couldn't remove file \(url).")
        }
    }    
}
