//
//  FileLogListTableViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/8/21.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZFileLogListTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var editPanel: UIView!
    
    var dataSource: [URL]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editClicked))
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    @objc func editClicked() {
        trashBtn.isEnabled = false
        selectAllBtn.isSelected = false
        tableView.isEditing = !tableView.isEditing
        editPanel.isHidden = !tableView.isEditing
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "完成" : "编辑"
    }
    
    @IBAction func selectAllClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for row in 0..<dataSource.count {
            if sender.isSelected {
                tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
                trashBtn.isEnabled = true
            } else {
                tableView.deselectRow(at: IndexPath(row: row, section: 0), animated: true)
                trashBtn.isEnabled = false
            }
        }
    }
    
    @IBAction func trashClicked(_ sender: UIButton) {
        if let selectedRows = tableView.indexPathsForSelectedRows?.sorted(by: { $0 > $1}) {
            editClicked()
            selectedRows.forEach { (idxPath) in
                JZFileLogger.shared.deleteLogFile(dataSource[idxPath.row])
                dataSource.remove(at: idxPath.row)
            }
            tableView.deleteRows(at: selectedRows, with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? JZFileLogTextViewController, let indexPath = tableView.indexPathForSelectedRow {
            let logFileUrl = dataSource[indexPath.row]
            vc.content = .url(logFileUrl)
            vc.title = logFileUrl.lastPathComponent
        }
    }
    
    deinit {
        print(#function, "JZFileLogListTableViewController")
    }
}

extension JZFileLogListTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "LogCell")
        cell.textLabel?.text = dataSource[indexPath.row].lastPathComponent
        if dataSource[indexPath.row] == JZFileLogger.shared.currLogFileURL {
            cell.textLabel?.text?.append("🔥")
        }
        let fileSize = try? FileManager.default.attributesOfItem(atPath: dataSource[indexPath.row].path)[.size] as? Int
        cell.detailTextLabel?.text = "\((fileSize ?? 0) / 1024) KB"
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing, tableView.indexPathsForSelectedRows == nil {
            trashBtn.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            trashBtn.isEnabled = true
            return
        }
    }
}
