//
//  CoursePhotosCollectionViewCell.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/30/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import UIKit

class CoursePhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            photoImageView.image = photo.image
            
        }
    }
}
