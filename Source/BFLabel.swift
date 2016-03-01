//
//  BFLabel.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import UIKit

private let textQueue = dispatch_queue_create("com.byyyf.YFLabel", DISPATCH_QUEUE_CONCURRENT)

@objc
public protocol BFLabelDelegate {
    optional func touchedMetion(label: BFLabel, metion: String)
    optional func touchedTag(label: BFLabel, tag: String)
    optional func touchedURL(label: BFLabel, url: String)
    optional func touchedLabel(label: BFLabel)
    
    optional func longPressedMetion(label: BFLabel, metion: String)
    optional func longPressedTag(label: BFLabel, tag: String)
    optional func longPressedURL(label: BFLabel, url: String)
    optional func longPressedLabel(label: BFLabel)
}

@IBDesignable
public class BFLabel: UIView {

    @IBInspectable
    public var text: String? {
        get {
            return attributedText?.string
        }
        set {
            attributedText = newValue.map(NSAttributedString.init)
            isDirty = true
        }
    }
    
    public var attributedText: NSAttributedString? {
        get {
            var attr: NSAttributedString?
            dispatch_sync(textQueue) {
                attr = self._attributedText
            }
            return attr
        }
        set {
            dispatch_barrier_async(textQueue) {
                self._attributedText = newValue
            }
        }
    }
    
    private var _attributedText: NSAttributedString?

    /// Paddings around the text.
    public var insets = UIEdgeInsetsZero
    
    public var exclusionPaths: [UIBezierPath] {
        get {
            return textContainer.exclusionPaths
        }
        set {
            textContainer.exclusionPaths = self.exclusionPaths
        }
    }
    
    @IBInspectable
    public var prefferedLayoutWidth: CGFloat = 0
    
    public var autoSizeToFit = false
    
    public var drawManually = true
    
    public var drawAsynchronously = false
    
    public lazy var displayLayer: CALayer = self.layer
    
    public var highlightLayer = CALayer()
    
    public var highlightMaskColor = UIColor(white: 1, alpha: 0.4)
    
    private var drawedSize: CGSize?
    
    private var isDirty = true
    
    private typealias TouchInfo = (type: BFTextType, range: NSRange)
    private var touchedInfo: TouchInfo?
    
    public var longPressGesture: UILongPressGestureRecognizer!
    
    public var delegate: BFLabelDelegate?
    
    /* Layout */
    private var textStorage = NSTextStorage()
    private var layoutManager = NSLayoutManager()
    private var textContainer = NSTextContainer()
    
    
    // MARK: - Life Cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.contentsGravity = kCAGravityTop
        layer.doubleSided = false
        
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "longPress:")
        addGestureRecognizer(longPressGesture)
    }
    
    //MARK: - Override method
    override public func layoutSubviews() {
        if (!drawManually) {
            if let drawedSize = drawedSize where drawedSize != frame.size {
                isDirty = true
            }
            if (isDirty) {
                display()
                isDirty = false
            }
        }
    }
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        guard let attributedText = attributedText else {
            return size
        }
        let rect = attributedText.boundingRectWithSize(size,
            options: NSStringDrawingOptions(rawValue: 11), context: nil)
        return CGSize(width: size.width, height: ceil(rect.height))
    }
    
    override public func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        return sizeThatFits(targetSize)
    }
    
    //MARK: - Method
    
    public func display() {
        guard let attributedText = attributedText else { return }
        let width = prefferedLayoutWidth == 0 ? frame.width : prefferedLayoutWidth
        
        // prepare layout
        textContainer.size = CGSize(width: width - insets.left - insets.right, height: 0)
        textStorage.setAttributedString(attributedText)
        
        func layoutedSize() -> CGSize {
            let size = layoutManager.usedRectForTextContainer(textContainer).size.ceilValue
            return CGSize(width: width, height: size.height + insets.top + insets.bottom)
        }
        
        // create canvas
        let canvasSize = prefferedLayoutWidth == 0 ? bounds.size : layoutedSize()
        drawedSize = canvasSize
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, opaque, UIScreen.mainScreen().scale)
        drawInRect(CGRect(origin: CGPoint.zero, size: canvasSize))
        let glyphTextCGImage = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
        
        dispatchInMainQueue {
            CATransaction.setDisableActions(true)
            if (self.autoSizeToFit) {
                self.frame.size = canvasSize
            }
            self.layer.contents = glyphTextCGImage
        }
    }
    
    public func drawInRect(rect: CGRect) {
        guard let
            attributedText = attributedText,
            context = UIGraphicsGetCurrentContext() else
        {
            return
        }
        
        // draw background
        if let backgroundColor = backgroundColor
            where opaque && backgroundColor != UIColor.clearColor()
        {
            backgroundColor.set()
            CGContextFillRect(context, rect)
        }
        
        let textAreaSize = CGSize(
            width: rect.width - insets.left - insets.right,
            height: rect.height - insets.top - insets.bottom
        )
        
        if (textContainer.size != textAreaSize) {
            textContainer.size = textAreaSize
        }
        if (!textStorage.isEqualToAttributedString(attributedText)) {
            textStorage.setAttributedString(attributedText)
        }
        
        let range = NSMakeRange(0, textStorage.length)
        let textAreaOrigin = CGPoint(
            x: rect.origin.x + insets.left,
            y: rect.origin.y + insets.top
        )
        
        // draw text
        layoutManager.drawBackgroundForGlyphRange(range, atPoint: textAreaOrigin)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: textAreaOrigin)
    }
    
    //MARK: - Gesture
    
    func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .Began) {
            performDelegate()
            removeHighlight()
        } else if (sender.state == .Ended) {
            
        }
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first!.locationInView(self)
        touchedInfo = touchInfoAtPoint(atPoint: point)
        if let touchedInfo = touchedInfo {
            highlight(forRange: touchedInfo.range)
        }
        
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        removeHighlight()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        performDelegate()
        performActionDelay(0.1, action: removeHighlight)
    }
    
    internal func performDelegate() {
        let longPress = longPressGesture.state == .Began
        guard let touchInfo = touchedInfo else {
            if (longPress) {
                delegate?.longPressedLabel?(self)
            } else {
                delegate?.touchedLabel?(self)
            }
            return
        }
        let touchedAttributedText = textStorage.attributedSubstringFromRange(touchInfo.range)
        var touchedText = touchedAttributedText.string
        
        switch touchInfo.type {
        case .Tag:
            touchedText.removeAtIndex(touchedText.startIndex)
            touchedText.removeAtIndex(touchedText.endIndex.predecessor())
            if (longPress) {
                delegate?.longPressedTag?(self, tag: touchedText)
            } else {
                delegate?.touchedTag?(self, tag: touchedText)
            }
        case .Metion:
            touchedText.removeAtIndex(touchedText.startIndex)
            if (longPress) {
                delegate?.longPressedMetion?(self, metion: touchedText)
            } else {
                delegate?.touchedMetion?(self, metion: touchedText)
            }
        case .URL:
            if let url = touchedAttributedText.attribute(BFURLStringAttributeName, atIndex: 0,
                longestEffectiveRange: nil, inRange: touchInfo.range) as? String
            {
                if (longPress) {
                    delegate?.longPressedURL?(self, url: url)
                } else {
                    delegate?.touchedURL?(self, url: url)
                }
            }
        }
    }
    
    private func touchInfoAtPoint(atPoint point: CGPoint) -> TouchInfo? {
        guard let attributedText = attributedText else {
            return nil
        }
        let origin = CGPoint(x: point.x - insets.left, y: point.y - insets.top)
        var distanceToNearestGlyph: CGFloat = 0
        let index = layoutManager.glyphIndexForPoint(origin, inTextContainer: textContainer, fractionOfDistanceThroughGlyph: &distanceToNearestGlyph)
        // touched blank area
        if (distanceToNearestGlyph == 1) {
            return nil
        }
        
        var effectiveRange = NSMakeRange(0, attributedText.length)
        if let attributeName = textStorage.attribute(BFTextTypeAttributeName, atIndex: index,
            longestEffectiveRange: &effectiveRange, inRange: NSMakeRange(0, textStorage.length)) as? String
        {
            if let type = BFTextType(rawValue: attributeName) {
                return (type, effectiveRange)
            }
            
        }
        return nil
    }
    
    private func highlight(forRange range: NSRange) {
        let originalBackgroundColor = textStorage.attribute(NSBackgroundColorAttributeName, atIndex: range.location, effectiveRange: nil)
        textStorage.addAttribute(NSBackgroundColorAttributeName, value: highlightMaskColor, range: range)
        let drawPoint = CGPointMake(insets.left, insets.top)
        UIGraphicsBeginImageContext(bounds.size)
        layoutManager.drawBackgroundForGlyphRange(range, atPoint: drawPoint)
        let glyphTextCGImage =  UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
        if let backgroundColor = originalBackgroundColor {
            textStorage.addAttribute(NSBackgroundColorAttributeName, value: backgroundColor, range: range)
        } else {
            textStorage.removeAttribute(NSBackgroundColorAttributeName, range: range)
        }
        CATransaction.setDisableActions(true)
        highlightLayer.frame = (displayLayer === layer) ? bounds : frame
        highlightLayer.contents = glyphTextCGImage
        displayLayer.addSublayer(highlightLayer)
    }
    
    private func removeHighlight() {
        CATransaction.setDisableActions(true)
        highlightLayer.contents = nil
        highlightLayer.removeFromSuperlayer()
    }
}

private func performActionDelay(time: NSTimeInterval, action: () -> Void) {
    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue()) {
        action()
    }
}