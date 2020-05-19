//
//  AddItemViewController.swift
//  saal
//
//  Created by Marouf, Zakaria on 19/05/2020.
//  Copyright © 2020 Marouf, Zakaria. All rights reserved.
//

import UIKit
import RealmSwift

class AddItemViewController: UIViewController {
    
    let realm = try! Realm()
    @IBOutlet weak var typeInput: UISegmentedControl!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descInput: UITextField!
    @IBOutlet weak var relationsTableView: UITableView!
    var selectedType : String = ""
    var items = [Item]()
    //var selectedItems = [Item]()
    var selectedRelations = [Relation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        relationsTableView.register(UINib.init(nibName: "RelationCell", bundle: nil), forCellReuseIdentifier: "cell")
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func selectedTypeIndex(_ sender: UISegmentedControl) {
        switch typeInput.selectedSegmentIndex
        {
        case 0:
            selectedType = "Desk"
        case 1:
            selectedType = "Computer"
        case 2:
            selectedType = "Keyboard"
        case 3:
            selectedType = "Server"
        case 4:
            selectedType = "Human being"
        default:
            break
        }
    }
    @IBAction func addItemDoneHandler(_ sender: UIBarButtonItem) {
        if(selectedType != "" && nameInput.text != "" && descInput.text != "") {
            let item = Item()
            item.name = nameInput.text!
            item.type = selectedType
            item.desc = descInput.text!
            
            if(selectedRelations.count != 0) {
                for selectedRelation in selectedRelations {
                    item.relations.append(selectedRelation)
                    for item2 in items {
                        if item2.name == selectedRelation.name {
                            let relation = Relation()
                            relation.name = item.name
                            do {
                                try self.realm.write {
                                    item2.relations.append(relation)
                                }
                            } catch {
                                print("Error updating relations, \(error)")
                            }
                        }
                    }
                }
            }
            
            save(item: item)
            
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func save(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func updateRelations() {
        
    }
    
    
}

extension AddItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RelationCell
        cell.selectionStyle = .none
        let item = items[indexPath.row]
        cell.checkBtn.isSelected = item.checked ? true : false
        cell.titleLbl.text = items[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    @objc private func checkHandler(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let relation = Relation()
        relation.name = items[indexPath.row].name
        items[indexPath.row].checked = !items[indexPath.row].checked
        if items[indexPath.row].checked {
            selectedRelations.append(relation)
        } else {
            if let indexToRemove = selectedRelations.firstIndex(of: relation) {
                selectedRelations.remove(at: indexToRemove)
            }
        }
        relationsTableView.reloadData()
    }
    
}

extension AddItemViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
