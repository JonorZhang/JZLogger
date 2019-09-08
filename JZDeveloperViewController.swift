//
//  JZDeveloperViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/9/6.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZDeveloperViewController: UITableViewController {

    private lazy var exitBtn: UIBarButtonItem = {
        let btn = UIButton()
        let image = UIImage(named: "back", in: JZFileLogger.resourceBundle, compatibleWith: nil)
        btn.setTitle("关闭", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(exit), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = exitBtn
    }
    
    @objc func exit() {
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as JZFileLogListTableViewController:
            vc.dataSource = JZFileLogger.shared.getAllFileURLs()
        default:
            break
        }
    }
    
    deinit {
        print(#function, "JZDeveloperViewController")
    }
}
