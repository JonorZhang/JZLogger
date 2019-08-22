//
//  FileLogTextViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

@objc public class JZFileLogTextViewController: UIViewController {
    
    private let kFontSizeKey = "key.FontSize.JZFileLogTextViewController"
    
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
    
    @IBOutlet weak var moreSettingPanel: UIView!
    
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = JZFileLogger.shared.readLogFile(logFileURL) ?? Data()
        textView.text = String(data: data, encoding: .utf8)
        textView.isEditable = false
        textView.textColor = .black
        if let fontSize = UserDefaults.standard.value(forKey: kFontSizeKey) as? CGFloat {
            textView.font = .systemFont(ofSize: fontSize)
            fontSizeSlider.value = Float(fontSize)
        }

        observeKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function, self.classForCoder)
    }
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [unowned self](note) in
            if let endFrame = note.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let dy = endFrame.origin.y - self.toolbarView.frame.origin.y - self.toolbarView.frame.size.height
                self.toolbarBottomConstraint.constant = dy
                self.view.layoutIfNeeded()
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { [unowned self](note) in
            self.toolbarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
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
        let sx: CGFloat = 0.9, sy: CGFloat = 0.3
        let tx = moreSettingPanel.frame.size.width * (1.0 - sx) / 2.0
        let ty = moreSettingPanel.frame.size.height * (1.0 - sy) / 2.0
        moreSettingPanel.transform = CGAffineTransform(a: sx, b: 0, c: 0, d: sy, tx: tx, ty: ty)
        UIView.animate(withDuration: 0.3) {
            self.moreSettingPanel.isHidden = !self.moreSettingPanel.isHidden
            self.moreSettingPanel.transform = .identity
        }
    }
    
    @IBAction func fontSizeValueChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: kFontSizeKey)
        textView.font = .systemFont(ofSize: CGFloat(sender.value))
    }
}
