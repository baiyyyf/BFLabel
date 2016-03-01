//
//  BFRoundTextAttachment.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

public class BFRoundTextAttachment: NSTextAttachment {
    public var cornerOptions: (corners: UIRectCorner, radii: CGSize) = (.AllCorners, CGSize.zero)
    public var font: UIFont?
    public var textColor = UIColor.whiteColor()
    public var backgroundColor: UIColor?
    public var padding: CGFloat = 0
    public var text: String = ""
    
    public func drawInRect(inRect rect: CGRect) {
        guard let font = font, backgroundColor = backgroundColor else {
            return
        }
        let frame = CGRect(
            x: rect.origin.x + padding,
            y: font.descender,
            width: rect.width - padding*2,
            height: rect.height
        )
        let roundedRectPath = UIBezierPath(roundedRect: frame, byRoundingCorners: cornerOptions.corners, cornerRadii: cornerOptions.radii)
        backgroundColor.setFill()
        roundedRectPath.fill()
        
        let attributes: [String: AnyObject] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        ]
        let attr = NSAttributedString(string: text, attributes: attributes)
        let size = attr.size()
        let drawPoint = CGPoint(x: frame.origin.x + (frame.width - size.width)/2, y: frame.origin.y + (frame.height - size.height)/2)
        attr.drawAtPoint(drawPoint)
    }
}
