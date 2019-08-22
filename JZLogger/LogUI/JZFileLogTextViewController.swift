//
//  FileLogTextViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

@objc public class JZFileLogTextViewController: UIViewController {
    
    var logFileURL: URL!
    
    @IBOutlet weak var regExpBtn: UIButton!
    
    @IBOutlet weak var caseSensitiveBtn: UIButton!
    
    @IBOutlet weak var wholeWordBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var moreSettingBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var toolbarView: UIStackView!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let data = JZFileLogger.shared.readLogFile(logFileURL) ?? Data()
        textView?.text = String(data: data, encoding: .utf8)
        textView?.isEditable = false
        textView?.textColor = .black
        
        observeKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function)
    }
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { (note) in
            print(#function, note.userInfo)
            if let endFrame = note.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let dy = endFrame.origin.y - self.toolbarView.frame.origin.y - self.toolbarView.frame.size.height
                self.toolbarBottomConstraint.constant = dy
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { (note) in
            print(#function, note.userInfo)
            self.toolbarBottomConstraint.constant = 0
        }
    }
    
    @IBAction func regExpClicked(_ sender: Any) {
        print(#function)
    }
    @IBAction func caseSensitiveClicked(_ sender: Any) {
        print(#function)
    }
    @IBAction func wholeWordClicked(_ sender: Any) {
        print(#function)
    }
    @IBAction func filterClicked(_ sender: Any) {
        print(#function)
    }
    @IBAction func moreSettingClicked(_ sender: Any) {
        print(#function)
    }
}
