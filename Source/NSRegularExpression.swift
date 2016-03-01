//
//  NSRegularExpression.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    convenience init?(_ pattern: String) {
        try? self.init(pattern: pattern, options: .DotMatchesLineSeparators)
    }
    
    func matchesInAttributedString(attr: NSAttributedString) -> [NSRange] {
        return matchesInString(attr.string, options: NSMatchingOptions(), range: NSMakeRange(0, attr.length)).map { $0.rangeAtIndex(0) }
    }
}