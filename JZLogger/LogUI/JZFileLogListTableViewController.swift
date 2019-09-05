//
//  FileLogListTableViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZFileLogListTableViewController: UITableViewController {
    
    var dataSource = JZFileLogger.shared.getAllFileURLs()
    
    private lazy var editBtn = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editClicked))
    private lazy var exitBtn = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(exit))
    private lazy var trashBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashClicked))
        btn.tintColor = .red
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日志列表"
        navigationItem.leftBarButtonItem = exitBtn
        navigationItem.rightBarButtonItem = editBtn
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    @objc func exit() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func editClicked() {
        trashBtn.isEnabled = false
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            navigationItem.leftBarButtonItem = trashBtn
            navigationItem.rightBarButtonItem?.title = "取消"
        } else {
            navigationItem.leftBarButtonItem = exitBtn
            navigationItem.rightBarButtonItem?.title = "编辑"
        }
    }
    
    @objc func trashClicked() {
        if let selectedRows = tableView.indexPathsForSelectedRows?.sorted(by: { $0 > $1}) {
            editClicked()
            selectedRows.forEach { (idxPath) in
                JZFileLogger.shared.deleteLogFile(dataSource[idxPath.row])
                dataSource.remove(at: idxPath.row)
            }
            tableView.deleteRows(at: selectedRows, with: .automatic)
        }
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
        if dataSource[indexPath.row] == JZFileLogger.shared.curLogFileURL {
            cell.textLabel?.text?.append("🔥")
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除", handler: { _,_ in
            print("clicked删除")
            let alert = UIAlertController(title: nil, message: "确认删除？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { _ in
                JZFileLogger.shared.deleteLogFile(self.dataSource[indexPath.row])
                self.dataSource = JZFileLogger.shared.getAllFileURLs()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            self.present(alert, animated: true)
        })
        
        let shared = UITableViewRowAction(style: .normal, title: "分享", handler: { _,_ in
            print("clicked分享")
            let logFileUrl = self.dataSource[indexPath.row]
            let actVc = UIActivityViewController.init(activityItems: [logFileUrl], applicationActivities: nil)
            self.present(actVc, animated: true)
        })
        
        return [delete, shared]
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing, tableView.indexPathsForSelectedRows == nil {
            trashBtn.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            trashBtn.isEnabled = true
            return
        }
        let logFileUrl = dataSource[indexPath.row]
        let logTextVc = JZFileLogTextViewController(content: .url(logFileUrl))
        logTextVc.title = logFileUrl.lastPathComponent
        navigationController?.pushViewController(logTextVc, animated: true)
    }
    
    deinit {
        print(#function, "JZFileLogListTableViewController")
    }
}
