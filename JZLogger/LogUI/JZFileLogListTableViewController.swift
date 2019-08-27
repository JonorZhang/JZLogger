//
//  FileLogListTableViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZFileLogListTableViewController: UITableViewController {
    
    var dataSource = JZFileLogger.shared.allLogFiles()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日志列表"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
    }
    
    @objc func close() {
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ?? UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = dataSource[indexPath.row].lastPathComponent
        if indexPath.row == 0 {
            cell.textLabel?.text?.append("🔥")
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .normal, title: "分享", handler: { _,_ in
                print("clicked分享")
                let logFileUrl = self.dataSource[indexPath.row]
                let actVc = UIActivityViewController.init(activityItems: [logFileUrl], applicationActivities: nil)
                self.present(actVc, animated: true)
            }),
            UITableViewRowAction(style: .destructive, title: "删除", handler: { _,_ in
                print("clicked删除")
                let alert = UIAlertController(title: nil, message: "确认删除？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { _ in
                    JZFileLogger.shared.deleteLogFile(self.dataSource[indexPath.row])
                    self.dataSource = JZFileLogger.shared.allLogFiles()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }))
                self.present(alert, animated: true)
            })
        ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logFileUrl = dataSource[indexPath.row]
        if let logData = JZFileLogger.shared.readLogFile(logFileUrl),
            let logText = String(data: logData, encoding: .utf8) {
            let logTextVc = JZFileLogTextViewController(logText: logText)
            logTextVc.title = logFileUrl.lastPathComponent
            navigationController?.pushViewController(logTextVc, animated: true)
        }
    }
    
    deinit {
        print(#function, "JZFileLogListTableViewController")
    }
}
