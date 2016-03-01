//
//  CGSize+Ex.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

extension CGSize {
    var ceilValue: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
}