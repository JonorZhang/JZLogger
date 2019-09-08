//
//  JZServerConfigListViewController.swift
//  JZLogger
//
//  Created by Zhang on 2019/9/7.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit


class JZServerConfigListViewController: UITableViewController {

    var dataSource: [ServerConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = JZServerConfig.svrCfgContents()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].name
        return cell
    }
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            JZServerConfig.deleteCfg(name: dataSource[indexPath.row].name)
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? JZNewServerConfigViewController {
            if segue.identifier == "EditConfig", let indexPath = tableView.indexPathForSelectedRow {
                vc.config = dataSource[indexPath.row]
            }
        }
    }
}
