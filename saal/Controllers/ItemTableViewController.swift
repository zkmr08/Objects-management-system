//
//  ItemTableViewController.swift
//  saal
//
//  Created by Marouf, Zakaria on 19/05/2020.
//  Copyright © 2020 Marouf, Zakaria. All rights reserved.
//

import UIKit
import RealmSwift

class ItemTableViewController: UITableViewController {
    
    var items = [Item]()
    let realm = try! Realm()
    var rowsNmb = [3]
    let sections = ["Details", "Relations"]
    var relations = [String]()
    var i = 0, j = 1
    var selectedItem : Item? {
        didSet {
            rowsNmb.append(selectedItem?.relations.count ?? 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedItem?.name
        relations.forEach { relation in
            if let index = items.firstIndex(where: { $0.name == relation }) {
                relations.append(items[index].desc)
            }
        }
        
        selectedItem?.relations.forEach { relation in
            relations.append(relation.name)
            if let index = items.firstIndex(where: { $0.name == relation.name }) {
                relations.append(items[index].desc)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsNmb[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            if(indexPath.row == 0) { cell.textLabel?.text = "Type"; cell.detailTextLabel?.text = selectedItem?.type }
            else if(indexPath.row == 1) { cell.textLabel?.text = "Name"; cell.detailTextLabel?.text = selectedItem?.name }
            else if(indexPath.row == 2) { cell.textLabel?.text = "Description"; cell.detailTextLabel?.text = selectedItem?.desc }
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
        } else {
            cell.textLabel?.text = relations[indexPath.row + i]
            cell.detailTextLabel?.text = relations[indexPath.row + j]
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            i+=1
            j+=1
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditItem" {
            let destinationVC = segue.destination as! EditItemViewController
            destinationVC.selectedItem = selectedItem!
            destinationVC.items = items
        }
    }
    
}
