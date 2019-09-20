//
//  GWLogger.swift
//  Yoosee
//
//  Created by JonorZhang on 2019/4/10.
//  Copyright © 2019 Gwell. All rights reserved.
//

import Foundation

// 日志级别
@objc public enum Level: Int, CustomStringConvertible {
    case error   = 0
    case warning = 1
    case info    = 2
    case debug   = 3
    case verbose = 4
    
    public var description: String {
        switch self {
        case .error:    return " [E]"
        case .warning:  return " [W]"
        case .info:     return " [I]"
        case .debug:    return " [D]"
        case .verbose:  return " [V]"
        }
    }
}

fileprivate class Log: NSObject {
    var date: Date
    var level: Level
    var message: String
    var file: String
    var function: String
    var line: Int
    
    var dateDesc: String {
        return Log.dateFormatter.string(from: date)
    }
    
    var lineDesc: String {
        return "\(line)"
    }
    
    convenience override init() {
        self.init(date: Date(), level: .verbose, message: "", file: "", function: "", line: 0)
    }
    
    init(date: Date, level: Level, message: String, file: String, function: String, line: Int) {
        self.date   = date
        self.level  = level
        self.message   = message
        self.file   = file
        self.function = function
        self.line   = line
        super.init()
    }
    
    // 2019-05-17 08:30:53.004 [D] <BaseViewController.m:22> -[BaseViewController dealloc] 🚀 控制器销毁 MineController
    override var description: String {
        let location = " <\(file):\(line)> \(function) "
        var mark: String {
            switch level {
            case .error:    return "~> "
            case .warning:  return "~> "
            case .info:     return "~> "
            case .debug:    return "~> "
            case .verbose:  return "~> "
            }
        }
        return dateDesc + level.description + location + mark + message
    }
    
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func < (lhs: Log, rhs: Log) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func > (lhs: Log, rhs: Log) -> Bool {
        return lhs.date > rhs.date
    }
    
    private static let dateFormatter: DateFormatter = {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.locale = NSLocale.current
        defaultDateFormatter.dateFormat = "HH:mm:ss.SSS" //"yyyy-MM-dd HH:mm:ss.SSS"
        return defaultDateFormatter
    }()
}

@objc public class JZLogger: NSObject {
        
    /// 日志的最高级别, 默认Debug:.debug / Release:.info。 log.level > maxLevel 的将会忽略
    public static var maxLevel: Level = {
        #if DEBUG
        return .verbose
        #else
        return .info
        #endif
    }()
    
    /// Swift建议用这个接口
    public static func log(_ level: Level = .debug, path: String = #file, function: String = #function, line: Int = #line, items: Any?...) {
        JZLogger._log(level, path: path, function: function, line: line, items: items)
    }
    
    /// OC用这个接口
    @objc public static func log_oc(_ level: Level = .debug, path: String = #file, function: String = #function, line: Int = #line, items: [Any]) {
        JZLogger._log(level, path: path, function: function, line: line, items: items)
    }
    
    /// 显示日志列表
    @objc public static func showLogList(with rootViewController: UIViewController) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "JZDeveloperViewController", bundle: JZFileLogger.resourceBundle)
            let navVc = storyboard.instantiateInitialViewController() as! UINavigationController
            rootViewController.present(navVc, animated: true)
        }
    }
    
    private static let serialQueue = DispatchQueue(label: "gw.logger.serialQueue")
    
    private static func _log<T: Collection>(_ level: Level, path: String, function: String, line: Int, items: T) {
        // 级别限制
        if level.rawValue > maxLevel.rawValue { return }
        // 模型转换
        let message = items.map { $0 as? String ?? "\($0)" }.joined(separator: " ")
        let fileName = (path as NSString).lastPathComponent
        let log = Log(date: Date(), level: level, message: message, file: fileName, function: function, line: line)
        #if DEBUG
        // 打印
        print(log.description)
        #endif
        // 记录
        serialQueue.async {
            JZFileLogger.shared.insertText(log.description)
        }
    }
}

    

