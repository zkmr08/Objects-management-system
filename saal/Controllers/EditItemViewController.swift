//
//  EditItemViewController.swift
//  saal
//
//  Created by Marouf, Zakaria on 19/05/2020.
//  Copyright © 2020 Marouf, Zakaria. All rights reserved.
//

import UIKit
import RealmSwift

class EditItemViewController: UIViewController {
    
    let realm = try! Realm()
    @IBOutlet weak var typeInput: UISegmentedControl!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var descInput: UITextField!
    @IBOutlet weak var relationsTableView: UITableView!
    var selectedItem = Item()
    var items = [Item]()
    var itemsList = List<String>()
    var selectedRelations = [Relation]()
    var availableItems = [Item]()
    var selectedType : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        relationsTableView.register(UINib.init(nibName: "RelationCell", bundle: nil), forCellReuseIdentifier: "cell")
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setup() {
        for item in items {
            if item.name != selectedItem.name {
                availableItems.append(item)
            }
        }
        selectedRelations.append(contentsOf: selectedItem.relations)
        for relation in selectedRelations {
            for item in availableItems {
                if relation.name == item.name {
                    item.checked = true
                }
            }
        }
        
        selectedType = selectedItem.type
        switch selectedType
        {
        case "Desk":
            typeInput.selectedSegmentIndex = 0
        case "Computer":
            typeInput.selectedSegmentIndex = 1
        case "Keyboard":
            typeInput.selectedSegmentIndex = 2
        case "Server":
            typeInput.selectedSegmentIndex = 3
        case "Human being":
            typeInput.selectedSegmentIndex = 4
        default:
            break
        }
        nameInput.text = selectedItem.name
        descInput.text = selectedItem.desc
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
    
    func updateRelations() {
        if selectedItem.name != nameInput.text {
            for item in items {
                for relation in item.relations {
                    if relation.name == selectedItem.name {
                        do {
                            try self.realm.write {
                                relation.name = nameInput.text!
                            }
                        } catch {
                            print("Error updating relation name, \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func updateItem() {
        do {
            try self.realm.write {
                selectedItem.name = nameInput.text!
                selectedItem.type = selectedType
                selectedItem.desc = descInput.text!
                
                selectedItem.relations.removeAll()
                for selectedRelation in selectedRelations {
                    selectedItem.relations.append(selectedRelation)
                }
            }
        } catch {
            print("Error saving done status, \(error)")
        }
    }
    
    @IBAction func saveItemHandler(_ sender: UIBarButtonItem) {
        if(nameInput.text != "" && descInput.text != "") {
            updateRelations()
            updateItem()
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension EditItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RelationCell
        cell.selectionStyle = .none
        let item = availableItems[indexPath.row]
        cell.checkBtn.isSelected = item.checked ? true : false
        cell.titleLbl.text = availableItems[indexPath.row].name
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
        relation.name = availableItems[indexPath.row].name
        availableItems[indexPath.row].checked = !availableItems[indexPath.row].checked
        if availableItems[indexPath.row].checked {
            selectedRelations.append(relation)
        } else {
            if let indexToRemove = selectedRelations.firstIndex(where: { $0.name == relation.name }) {
                selectedRelations.remove(at: indexToRemove)
            }
        }
        relationsTableView.reloadData()
    }
}

extension EditItemViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
