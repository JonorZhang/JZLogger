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
    
    @IBOutlet weak var searchResultView: UIView!
    
    @IBOutlet weak var resultCountLabel: UILabel!
    
    private var matcheResults: (curIdx: Int, all: [NSTextCheckingResult]?) = (0, nil) {
        didSet {
            guard let resultAll = matcheResults.all, resultAll.count > 0 else { return }
            
            // 1. 如果是prev/next进来需要还原当前文本为未选中颜色
            if let oldResultAll = oldValue.all, oldResultAll == resultAll {
                textView.textStorage.addAttributes([.backgroundColor : UIColor.yellow], range: oldResultAll[oldValue.curIdx].range)
            }
            // 2. 更新prev/next文本为选中颜色
            let range = resultAll[matcheResults.curIdx].range
            resultCountLabel.text = "\(matcheResults.curIdx + 1)/\(resultAll.count)"
            textView.scrollRangeToVisible(range)
            textView.textStorage.addAttributes([.backgroundColor : UIColor.red], range: range)
            if matcheResults.curIdx == 0 { makeToast("第一个") }
        }
    }
    
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

        searchBar.delegate = self
        
        observeKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function, self.classForCoder)
    }
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [weak self](note) in
            guard let `self` = self else { return }
            if let endFrame = note.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                let dy = endFrame.origin.y - self.toolbarView.frame.origin.y - self.toolbarView.frame.size.height
                self.toolbarBottomConstraint.constant += dy
                self.view.layoutIfNeeded()
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { [weak self](note) in
            guard let `self` = self else { return }
            self.toolbarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func makeToast(_ msg: String) {
        let alert = UIAlertController(title: nil, message: "无搜索结果", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    func search(in string: String, pattern: String, regExp: NSRegularExpression) {
        let strRange = NSRange(location: 0, length: string.count)
        let results = regExp.matches(in: string, options: .reportCompletion, range: strRange)
        print(pattern, strRange, results.count, results)
        textView.textStorage.removeAttribute(.backgroundColor, range: strRange)
        results.forEach({ (res) in
            textView.textStorage.addAttributes([.backgroundColor : UIColor.yellow], range: res.range)
        })
        searchResultView.isHidden = !(results.count > 0)

        if results.count > 0 {
            matcheResults = (0, results)
        } else {
            makeToast("无搜索结果")
        }
    }
    
    @IBAction func regExpClicked(_ sender: UIButton) {
        print(#function)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func caseSensitiveClicked(_ sender: UIButton) {
        print(#function)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func wholeWordClicked(_ sender: UIButton) {
        print(#function)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func filterClicked(_ sender: UIButton) {
        print(#function)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func moreSettingClicked(_ sender: UIButton) {
        let sx: CGFloat = 0.9, sy: CGFloat = 0.3
        let tx = moreSettingPanel.frame.size.width * (1.0 - sx) / 2.0
        let ty = moreSettingPanel.frame.size.height * (1.0 - sy) / 2.0
        moreSettingPanel.transform = CGAffineTransform(a: sx, b: 0, c: 0, d: sy, tx: tx, ty: ty)
        view.bringSubviewToFront(moreSettingPanel)
        UIView.animate(withDuration: 0.3) {
            self.moreSettingPanel.isHidden = !self.moreSettingPanel.isHidden
            self.moreSettingPanel.transform = .identity
        }
    }
    
    @IBAction func fontSizeValueChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: kFontSizeKey)
        textView.font = .systemFont(ofSize: CGFloat(sender.value))
    }
    
    @IBAction func prevSearchResultClicked(_ sender: Any) {
        guard let resultAll = matcheResults.all else { return }
        if matcheResults.curIdx > 0 {
            matcheResults.curIdx -= 1
        } else {
            matcheResults.curIdx = resultAll.count - 1
        }
    }
    
    @IBAction func nextSearchResultClicked(_ sender: Any) {
        guard let resultAll = matcheResults.all else { return }
        if matcheResults.curIdx < resultAll.count - 1 {
            matcheResults.curIdx += 1
        } else {
            matcheResults.curIdx = 0
        }
    }
    
    @IBAction func toggleSearchResultViewClicked() {
        searchResultView.isHidden = !searchResultView.isHidden
        view.bringSubviewToFront(searchResultView)
        if let string = self.textView.text, searchResultView.isHidden {
            let strRange = NSRange(location: 0, length: string.count)
            self.textView.textStorage.removeAttribute(.backgroundColor, range: strRange)
        }
    }
}

extension JZFileLogTextViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let string = textView.text, var pattern = searchBar.text {
            var options: NSRegularExpression.Options = [.anchorsMatchLines]
            if !caseSensitiveBtn.isSelected { options.insert(.caseInsensitive) }
            if wholeWordBtn.isSelected { pattern = #"\b\#(pattern)\b"# }
            if let regExp = try? NSRegularExpression(pattern: pattern, options: options) {
                search(in: string, pattern: pattern, regExp: regExp)
            }
        }
    }
}

