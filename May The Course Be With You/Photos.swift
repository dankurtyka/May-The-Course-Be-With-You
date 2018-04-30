//
//  Photos.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/30/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray = [Photo]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
}
