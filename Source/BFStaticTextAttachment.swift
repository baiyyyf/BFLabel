//
//  BFStaticTextAttachment.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

private let systemFontLineHeightToDecender: CGFloat = -0.2021

public class BFStaticTextAttachment: NSTextAttachment {
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
            let lineHeight = lineFrag.size.height
            let size = self.image!.size
            return CGRect(x: 0, y: lineHeight*systemFontLineHeightToDecender, width: size.width /  size.height * lineHeight, height: lineHeight)
    }
}