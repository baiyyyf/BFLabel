//
//  BFEmoticonAttachment.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

private let systemFontLineHeightToDecender: CGFloat = -0.2021

public class BFEmoticonAttachment: NSTextAttachment {
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
            let lineHeight = lineFrag.size.height
            return CGRect(x: 0, y: lineHeight*systemFontLineHeightToDecender, width: lineHeight, height: lineHeight)
    }
}