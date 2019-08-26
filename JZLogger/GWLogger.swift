//
//  GWLogger.swift
//  Yoosee
//
//  Created by JonorZhang on 2019/4/10.
//  Copyright © 2019 Gwell. All rights reserved.
//

import Foundation

@objc public class GWLogger: NSObject {
    
    final class Log: NSObject {
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
                case .error:    return "❌"
                case .warning:  return "⚠️"
                case .info:     return "🔵"
                case .debug:    return "🚀"
                case .verbose:  return "🚀"
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
    
    // 日志级别
    public enum Level: Int, CustomStringConvertible {
        case error   = 0
        case warning = 1
        case info    = 2
        case debug   = 3
        case verbose = 4
    
        static let all: [Level] = [.error, .warning, .info, .debug, .verbose]
        
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
    
    /// 日志的最高级别, 默认Debug:.debug / Release:.info。 log.level > maxLevel 的将会忽略
    public static var maxLevel: Level = {
        #if DEBUG
        return .verbose
        #else
        return .info
        #endif
    }()
    
    static let serialQueue = DispatchQueue(label: "gw.logger.serialQueue")
    
    public static func log<T: Collection>(_ items: T, with level: Level = .debug, in path: String = #file, on function: String = #function, at line: Int = #line) {
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
            JZFileLogger.shared.appendRecord(log.description)
        }
    }
    
    public static func showLogList(with rootViewController: UIViewController) {
        DispatchQueue.main.async {
            let logListVc = JZFileLogListTableViewController()
            if let navVc = rootViewController as? UINavigationController {
                navVc.pushViewController(logListVc, animated: true)
            } else if let navVc = rootViewController.navigationController {
                navVc.pushViewController(logListVc, animated: true)
            } else {
                rootViewController.present(logListVc, animated: true)
            }
        }
    }
    
    public static var enableShakeToShowLogList: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "摇一摇显示日志")
        }
        get {
            return UserDefaults.standard.bool(forKey: "摇一摇显示日志")
        }
    }
}

public func logError(_ items: Any?..., file: String = #file, function: String = #function, line: Int = #line) {
    GWLogger.log(items, with: .error, in: file, on: function, at: line)
}

public func logWarning(_ items: Any?..., file: String = #file, function: String = #function, line: Int = #line) {
    GWLogger.log(items, with: .warning, in: file, on: function, at: line)
}

public func logInfo(_ items: Any?..., file: String = #file, function: String = #function, line: Int = #line) {
    GWLogger.log(items, with: .info, in: file, on: function, at: line)
}

public func logDebug(_ items: Any?..., file: String = #file, function: String = #function, line: Int = #line) {
    GWLogger.log(items, with: .debug, in: file, on: function, at: line)
}

public func logVerbose(_ items: Any?..., file: String = #file, function: String = #function, line: Int = #line) {
    GWLogger.log(items, with: .verbose, in: file, on: function, at: line)
}

public extension GWLogger {
    @objc static func error(_ items: [Any], file: String = #file, function: String = #function, line: Int = #line) {
        log(items, with: .error, in: file, on: function, at: line)
    }
    @objc static func warning(_ items: [Any], file: String = #file, function: String = #function, line: Int = #line) {
        log(items, with: .warning, in: file, on: function, at: line)
    }
    @objc static func info(_ items: [Any], file: String = #file, function: String = #function, line: Int = #line) {
        log(items, with: .info, in: file, on: function, at: line)
    }
    @objc static func debug(_ items: [Any], file: String = #file, function: String = #function, line: Int = #line) {
        log(items, with: .debug, in: file, on: function, at: line)
    }
    @objc static func verbose(_ items: [Any], file: String = #file, function: String = #function, line: Int = #line) {
        log(items, with: .verbose, in: file, on: function, at: line)
    }
    @objc static func log(_ items: [Any], level: Int = 0, file: String = #file, function: String = #function, line: Int = #line) {
        guard let lv = GWLogger.Level(rawValue: level) else { return }
        log(items, with: lv, in: file, on: function, at: line)
    }
}

