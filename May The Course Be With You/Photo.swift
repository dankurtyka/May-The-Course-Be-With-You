//
//  Photo.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/30/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage!
    var description: String!
    var postedBy: String!
    var date: Date!
    var documentID: String!
    
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    init(image: UIImage, description: String, postedBy: String, date: Date, documentID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentID = documentID
    }
    convenience init() {
        let postedBy = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentID: "")
    }
}
