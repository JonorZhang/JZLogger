//
//  FileLogTextViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZFileLogTextViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI控件

    @IBOutlet weak var regExpBtn: UIButton!
    
    @IBOutlet weak var caseSensitiveBtn: UIButton!
    
    @IBOutlet weak var wholeWordBtn: UIButton!
    
    @IBOutlet weak var searchBar: UITextField!
    
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var moreSettingBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var symbolCollView: UICollectionView!
    
    @IBOutlet weak var toolbarView: UIStackView!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moreSettingPanel: UIView!
    
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    @IBOutlet weak var searchResultView: UIView!
    
    @IBOutlet weak var resultCountLabel: UILabel!
    
    // MARK: - 其他变量

    private let kFontSizeKey = "key.FontSize.JZFileLogTextViewController"
    
    private let regExpSymbols = [".", "*", "?", "^", "$", "-", "+", ",", "{", "}", "[", "]", "(", ")", ":", "\\", "/", "<", ">"]

    var logText: String

    var regExp: NSRegularExpression?
    
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
        }
    }
    
    // MARK: - 生命周期

    init(logText: String) {
        self.logText = logText
        super.init(nibName: "JZFileLogTextViewController", bundle: JZFileLogger.resourceBundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = logText
        textView.isEditable = false
        textView.textColor = .black
        if let fontSize = UserDefaults.standard.value(forKey: kFontSizeKey) as? CGFloat {
            textView.font = .systemFont(ofSize: fontSize)
            fontSizeSlider.value = Float(fontSize)
        }
                
        symbolCollView.register(JZSymbolCollViewCell.self, forCellWithReuseIdentifier: "JZSymbolCollViewCell")
        symbolCollView.collectionViewLayout = JZSymbolCollViewLayout()
        
        observeKeyboard()
        
        if let regExp = regExp {
            searchBar.text = regExp.pattern
            search(in: logText, regExp: regExp)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#function, self.classForCoder)
    }

    // MARK: - 私有函数

    private func observeKeyboard() {
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
    
    private func makeToast(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    private func search(in string: String, regExp: NSRegularExpression) {
        let strRange = NSRange(location: 0, length: string.count)
        let results = regExp.matches(in: string, options: .reportCompletion, range: strRange)
        textView.textStorage.removeAttribute(.backgroundColor, range: strRange)
        results.forEach({ (res) in
            textView.textStorage.addAttributes([.backgroundColor : UIColor.yellow], range: res.range)
        })
        searchResultView.isHidden = !(results.count > 0)
        view.bringSubviewToFront(searchResultView)

        if results.count > 0 {
            matcheResults = (0, results)
            if moreSettingBtn.isSelected { moreSettingClicked(moreSettingBtn) }
            if regExpBtn.isSelected { regExpClicked(regExpBtn) }
        } else {
            makeToast("无搜索结果")
        }
    }
    
    // MARK: - 按键处理

    @IBAction func regExpClicked(_ sender: UIButton) {
        print(#function)
        sender.isSelected = !sender.isSelected
        symbolCollView.isHidden = !sender.isSelected
        view.bringSubviewToFront(symbolCollView)
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
        sender.isSelected = !sender.isSelected
        let sx: CGFloat = 0.5, sy: CGFloat = 0.3
        let tx = moreSettingPanel.frame.size.width * (1.0 - sx) / 2.0
        let ty = moreSettingPanel.frame.size.height * (1.0 - sy) / 2.0
        moreSettingPanel.transform = CGAffineTransform(a: sx, b: 0, c: 0, d: sy, tx: tx, ty: ty)
        view.bringSubviewToFront(moreSettingPanel)
        UIView.animate(withDuration: 0.2) {
            self.moreSettingPanel.isHidden = !sender.isSelected
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
            makeToast("最后一个")
        }
    }
    
    @IBAction func nextSearchResultClicked(_ sender: Any) {
        guard let resultAll = matcheResults.all else { return }
        if matcheResults.curIdx < resultAll.count - 1 {
            matcheResults.curIdx += 1
        } else {
            matcheResults.curIdx = 0
            makeToast("第一个")
        }
    }
    
    @IBAction func showSearchResultsClicked(_ sender: Any) {
        if let regExp = matcheResults.all?.first?.regularExpression {
            let linePattern = #"^.*\#(regExp.pattern).*\n"#
            
            if let lineRegExp = try? NSRegularExpression(pattern: linePattern, options: regExp.options) {
                
                let strRange = NSRange(location: 0, length: logText.count)
                let results = lineRegExp.matches(in: logText, options: .reportCompletion, range: strRange)

                var matchsLines: String = ""
                results.forEach({ (res) in
                    if let range = Range<String.Index>(res.range, in: logText) {
                        matchsLines += logText[range]
                    }
                })
                
                let logTextVc = JZFileLogTextViewController(logText: matchsLines)
                logTextVc.title = linePattern
                logTextVc.regExp = regExp
                navigationController?.pushViewController(logTextVc, animated: true)
            } else {
                makeToast("正则表达式不正确")
            }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        if let string = textView.text, var pattern = searchBar.text, pattern.count > 0 {
            var options: NSRegularExpression.Options = [.anchorsMatchLines]
            if !caseSensitiveBtn.isSelected { options.insert(.caseInsensitive) }
            if wholeWordBtn.isSelected { pattern = #"\b\#(pattern)\b"# }
            if let regExp = try? NSRegularExpression(pattern: pattern, options: options) {
                search(in: string, regExp: regExp)
            } else {
                makeToast("正则表达式不正确")
            }
        }
        return true
    }    
}

extension JZFileLogTextViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return regExpSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JZSymbolCollViewCell", for: indexPath) as! JZSymbolCollViewCell
        cell.textLabel.text = regExpSymbols[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.insertText(regExpSymbols[indexPath.item])
    }
}

class JZSymbolCollViewCell: UICollectionViewCell {
    
    lazy var textLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.2389338315, green: 0.4465256333, blue: 1, alpha: 1)
        lb.backgroundColor = #colorLiteral(red: 0.8558645442, green: 0.8643384506, blue: 0.8643384506, alpha: 1)
        lb.layer.cornerRadius = 10
        lb.layer.masksToBounds = true
        lb.font = UIFont.systemFont(ofSize: 23)
        lb.textAlignment = .center
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        textLabel.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JZSymbolCollViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
        itemSize = CGSize(width: 40, height: 40)
        estimatedItemSize = CGSize(width: 40, height: 40)
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
