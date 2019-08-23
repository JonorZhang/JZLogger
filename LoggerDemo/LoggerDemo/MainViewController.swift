//
//  MainViewController.swift
//  LoggerDemo
//
//  Created by JonorZhang on 2019/8/22.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit
import JZLogger

class MainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFiled: UITextField!
    
    @IBOutlet weak var insertLogMessageBtn: UIButton!
    
    @IBOutlet weak var shakeToShowLogsBtn: UIButton!
    
    var isShakeToShowLogs = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "使用示例"
        textFiled.clearButtonMode = .whileEditing
        textFiled.delegate = self
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake, isShakeToShowLogs {
            let logListVc = JZFileLogListTableViewController()
            navigationController?.pushViewController(logListVc, animated: true)
        }
    }
    
    @IBAction func insertLogMessageClicked(_ sender: UIButton) {
        var text = textFiled.text ?? "你没有输入内容，那我就占个位置啦～"
        if text.isEmpty { text = "你没有输入内容，那我就占个位置啦～" }
        JZFileLogger.shared.appendRecord(text)
    }
    
    @IBAction func shakeToShowLogsClicked(_ sender: UIButton) {
        isShakeToShowLogs = !isShakeToShowLogs
        sender.setTitle(isShakeToShowLogs ? "摇一摇显示日志【已开启】" : "摇一摇显示日志【已关闭】", for: .normal)
        sender.setTitleColor(isShakeToShowLogs ? #colorLiteral(red: 0.3054999709, green: 0.5893267989, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.05795724928, blue: 0.1601722556, alpha: 1), for: .normal)
    }
    
    @IBAction func openLogListClicked(_ sender: Any) {
        let logListVc = JZFileLogListTableViewController()
        navigationController?.pushViewController(logListVc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFiled.resignFirstResponder()
        return true
    }
}
