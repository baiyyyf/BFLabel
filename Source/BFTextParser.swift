//
//  BFTextParser.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

public let BFTextTypeAttributeName = "BFTextTypeAttributeName"
public let BFURLStringAttributeName = "BFURLStringAttributeName"

public enum BFTextType: String {
    case URL            = "BFTextTypeURL"
    case Tag            = "BFTextTypeTag"
    case Metion         = "BFTextTypeMention"
}

public class BFTextParser: NSObject {
    
    public typealias TextFormatter = NSMutableAttributedString -> NSMutableAttributedString
    
    public private (set) var attributedText: NSAttributedString?
    
    public var font = UIFont.systemFontOfSize(16)
    
    public var textColor = UIColor.blackColor()
    
    public var tintColor = UIColor(red:0.905, green:0.298, blue:0.235, alpha:1)
    
    public var lineSpacing: CGFloat = 0
    
    public var imageForName: (String -> UIImage?)?
    
    public lazy var formatter: TextFormatter =
        self.replaceTextWithEmoticon
        >|> self.updateCommonAttributes
        >|> self.replaceURL
        >|> self.highlightMetionAndTag
    
    
    //MARK: - Method
    public func parseText(text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        self.attributedText = formatter(attributedText)
        return self.attributedText!
    }
    
    public func parseAttributeText(attr: NSMutableAttributedString) -> NSAttributedString {
        self.attributedText = formatter(attr)
        return self.attributedText!
    }
    
    public func size(size: CGSize) -> CGSize {
        guard let attributedText = attributedText else { return size }
        return BFTextParser.size(attributedText, size: size)
    }
    
    public class func size(attributedText: NSAttributedString, size: CGSize) -> CGSize {
        let rect = attributedText.boundingRectWithSize(size, options: NSStringDrawingOptions(rawValue: 11), context: nil)
        return CGSize(width: size.width, height: ceil(rect.height))
    }
    
    public func updateCommonAttributes(attr: NSMutableAttributedString)
        -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByCharWrapping
        paragraphStyle.minimumLineHeight = self.font.lineHeight
        paragraphStyle.maximumLineHeight = self.font.lineHeight
        paragraphStyle.lineSpacing = self.lineSpacing
        
        let attributes = [
            NSFontAttributeName: self.font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        attr.addAttributes(attributes)
        return attr
    }
    
    public func highlightMetionAndTag(attr: NSMutableAttributedString) -> NSMutableAttributedString {
        let mentionRanges = mentionRegex.matchesInAttributedString(attr)
        let tagRanges = tagRegex.matchesInAttributedString(attr)
        
        let attributes = [
            BFTextTypeAttributeName: BFTextType.Metion.rawValue,
            NSForegroundColorAttributeName: tintColor
        ]
        mentionRanges.forEach {
            attr.addAttributes(attributes, range: $0)
        }
        tagRanges.forEach {
            attr.addAttributes(attributes, range: $0)
        }
        return attr
    }
    
    public func replaceURL(attr: NSMutableAttributedString) -> NSMutableAttributedString {
        let ranges = urlRegex.matchesInAttributedString(attr)
        for range in ranges.reverse() {
            let urlAttr = attr.attributedSubstringFromRange(range)
            let attrM = NSMutableAttributedString(string: urlAttr.string)

            var attributes = urlAttr.attributesAtIndex(0, effectiveRange: nil)
            attributes[NSForegroundColorAttributeName] = tintColor
            attributes[BFTextTypeAttributeName] = BFTextType.URL.rawValue
            attrM.addAttributes(attributes)

            attr.replaceCharactersInRange(range, withAttributedString: attrM)
        }
        return attr
    }
    
    public func replaceTextWithEmoticon(attr: NSMutableAttributedString) -> NSMutableAttributedString {
        guard let imageForName = imageForName else { return attr }
        let ranges = emotionRegex.matchesInAttributedString(attr)
        for range in ranges.reverse() {
            let name = attr.attributedSubstringFromRange(range).string
            guard let image = imageForName(name) else { continue }
            let attachment = BFEmoticonAttachment()
            attachment.image = image
            attr.replaceCharactersInRange(range, withAttributedString: NSAttributedString(attachment: attachment))
        }
        return attr
    }
}

private let emotionRegex = NSRegularExpression("\\[[^\\[\\]]*\\]")!

private let mentionRegex = NSRegularExpression("@[\\u4e00-\\u9fa5a-zA-Z0-9_-]{2,30}")!

private let urlRegex =  NSRegularExpression("(http|https)://[a-zA-Z0-9/\\.]*")!

private let tagRegex =  NSRegularExpression("#[^#]+#")!


infix operator >|> { associativity left }
func >|> <A, B, C>(lhs: A -> B, rhs: B -> C) -> A -> C {
    return { rhs(lhs($0)) }
}