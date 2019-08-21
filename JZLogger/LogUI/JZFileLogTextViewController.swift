//
//  FileLogTextViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

@objc open class JZFileLogTextViewController: UIViewController {

    var text: String?
    private var textView: UITextView!
        
    override open func viewDidLoad() {
        super.viewDidLoad()
        textView = UITextView(frame: view.bounds)
        textView.isEditable = false
        textView.text = text
        textView.textColor = .black
        view.addSubview(textView)
    }
}
