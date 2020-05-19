//
//  Item.swift
//  saal
//
//  Created by Marouf, Zakaria on 19/05/2020.
//  Copyright © 2020 Marouf, Zakaria. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var desc : String = ""
    @objc dynamic var type : String = ""
    var checked : Bool = false
    var relations = List<Relation>()
}

class Relation : Object {
    @objc dynamic var name : String = ""
}
