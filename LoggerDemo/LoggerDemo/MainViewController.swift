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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "使用示例"
        textFiled.clearButtonMode = .whileEditing
        textFiled.delegate = self
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            JZLogger.showLogList(with: self)
        }
    }
    
    @IBAction func insertLogMessageClicked(_ sender: UIButton) {
        var text = textFiled.text ?? "你没有输入内容，那我就占个位置啦～"
        if text.isEmpty { text = "你没有输入内容，那我就占个位置啦～" }
        JZLogger.log(.warning, items: text)
    }
        
    @IBAction func openLogListClicked(_ sender: Any) {
        JZLogger.showLogList(with: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFiled.resignFirstResponder()
        return true
    }
}
