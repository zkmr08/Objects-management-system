//
//  ItemsTableViewController.swift
//  saal
//
//  Created by Marouf, Zakaria on 19/05/2020.
//  Copyright © 2020 Marouf, Zakaria. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ItemsTableViewController: UITableViewController {
    
    let realm = try! Realm()
    var items : Results<Item>?
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification), name: Notification.Name("reloadData"), object: nil)
        tableView.rowHeight = 75
    }
    
    @objc func didGetNotification(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func loadItems() {
        items = realm.objects(Item.self)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.type + " : " + item.name
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.detailTextLabel?.text = item.desc
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItem" {
            let destinationVC = segue.destination as! ItemTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedItem = items?[indexPath.row]
                destinationVC.items = Array(items!)
            }
        }
        if segue.identifier == "goToAddItem" {
            let destinationVC = segue.destination as! AddItemViewController
            searchBar.text = ""
            loadItems()
            DispatchQueue.main.async {
                self.searchBar.resignFirstResponder()
            }
            destinationVC.items = Array(items!)
        }
    }
}

extension ItemsTableViewController : UISearchBarDelegate {
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        items = items?.filter("name CONTAINS[cd] %@", searchBar.text!)
    //        tableView.reloadData()
    //    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count == 0) {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            items = items?.filter("name CONTAINS[cd] %@", searchBar.text!)
            tableView.reloadData()
        }
    }
}


//MARK: - Swipe Cell Delegate MEthods

extension ItemsTableViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let itemToDelete = self.items?[indexPath.row] {
                let relationToDelete = itemToDelete.name
                do {
                    try self.realm.write {
                        self.realm.delete(itemToDelete)
                    }
                } catch {
                    print("Error deleting item", error)
                }
                let updatedRelations = List<Relation>()
                self.items?.forEach { item in
                    updatedRelations.removeAll()
                    let relations = item.relations
                    relations.forEach { relation in
                        if relation.name != relationToDelete {
                            updatedRelations.append(relation)
                        }
                    }
                    do {
                        try self.realm.write {
                            item.relations.removeAll()
                            for updatedRelation in updatedRelations {
                                item.relations.append(updatedRelation)
                            }
                        }
                    } catch {
                        print("Error updating relation name, \(error)")
                    }
                }
            }
        }
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
