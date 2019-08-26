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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("numberOfRowsInSection:\(section)", dataSource.count)
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ?? UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        print("cellForRowAt:\(indexPath)", dataSource.count)
        cell.textLabel?.text = dataSource[indexPath.row].lastPathComponent
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            JZFileLogger.shared.deleteLogFile(dataSource[indexPath.row])
            dataSource = JZFileLogger.shared.allLogFiles()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logFileName = dataSource[indexPath.row]
        if let logData = JZFileLogger.shared.readLogFile(logFileName),
            let logText = String(data: logData, encoding: .utf8) {
            let logTextVc = JZFileLogTextViewController(logText: logText)
            logTextVc.title = logFileName.lastPathComponent
            navigationController?.pushViewController(logTextVc, animated: true)
        }
    }
}
