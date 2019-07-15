//
//  HSBColorPicker.swift
//  Notes
//
//  Created by Александр Степанов on 14/07/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

@IBDesignable
class ColorPickerView: UIView {
    
    private let brightnessSlider = UISlider()
    private let selectedColorView = UIView()
    private let colorLabel = UILabel()
    private let palette = ColorPalleteView()
    private let brightnessLabel = UILabel()
    private let doneButton = UIButton()
    
    //TODO: ? make an inspoectable field to set pre-selected?
    private var selectedColor: UIColor = UIColor.white
    
    // DELEGATE FOR THE DONE BUTTON
    var onColorSelected: ((UIColor) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private let singleMargin: CGFloat = 8
    private let doubleMargin: CGFloat = 16
    private let topMargin: CGFloat = 40
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageWidth = CGFloat(80.0)
        selectedColorView.frame = CGRect(
            origin: CGPoint(x: bounds.minX + doubleMargin, y: bounds.minY + topMargin),
            size: CGSize(width: imageWidth, height: imageWidth)
        )
        
        let colorLabelSize = colorLabel.intrinsicContentSize
        colorLabel.frame = CGRect(
            origin: CGPoint(x: bounds.minX + doubleMargin, y: bounds.minY + imageWidth + topMargin - CGFloat(1.0)),
            size: CGSize(width: imageWidth, height: colorLabelSize.height)
        )
        
        let brightnessLabelSize = brightnessLabel.intrinsicContentSize
        brightnessLabel.frame = CGRect(
            origin: CGPoint(x: bounds.minX + doubleMargin + imageWidth + singleMargin, y: bounds.minY + topMargin + imageWidth / 2.0),
            size: brightnessLabelSize
        )
        
        let brightnessSliderSize = brightnessSlider.intrinsicContentSize
        brightnessSlider.frame = CGRect(
            origin: CGPoint(x: bounds.minX + doubleMargin + imageWidth + singleMargin, y: brightnessLabel.frame.maxY + singleMargin),
            size: CGSize(width: bounds.width - imageWidth - doubleMargin * 3.0, height: brightnessSliderSize.height)
        )
        
        let buttonSize = doneButton.intrinsicContentSize
        doneButton.frame = CGRect(
            origin: CGPoint(x: bounds.minX + (bounds.width - buttonSize.width) / 2, y: bounds.maxY - buttonSize.height),
            size: buttonSize
        )
        
        palette.frame = CGRect(
            origin: CGPoint(x: bounds.minX + doubleMargin, y: colorLabel.frame.maxY + doubleMargin),
            size: CGSize(width: bounds.width - doubleMargin * 2.0,
                         height: bounds.height - imageWidth - colorLabelSize.height - buttonSize.height - doubleMargin * 4.0))
        
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(selectedColorView)
        addSubview(colorLabel)
        addSubview(brightnessLabel)
        addSubview(brightnessSlider)
        addSubview(palette)
        addSubview(doneButton)
        
        selectedColorView.translatesAutoresizingMaskIntoConstraints = true
        colorLabel.translatesAutoresizingMaskIntoConstraints = true
        brightnessLabel.translatesAutoresizingMaskIntoConstraints = true
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = true
        doneButton.translatesAutoresizingMaskIntoConstraints = true
        
        selectedColorView.backgroundColor = selectedColor
        selectedColorView.layer.borderWidth = 1
        selectedColorView.layer.borderColor = UIColor.black.cgColor
        selectedColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedColorView.layer.cornerRadius = 10
        colorLabel.text = getHexString(selectedColor)
        
        colorLabel.layer.borderWidth = 1
        colorLabel.layer.borderColor = UIColor.black.cgColor
        colorLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        colorLabel.layer.cornerRadius = 10
        
        brightnessLabel.text = "Brightness: "
        brightnessSlider.maximumValue = 1.0
        brightnessSlider.minimumValue = 0
        setBrightnessFromSelectedColor()
        brightnessSlider.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
        
        
        palette.onColorDidChange = {[weak self] color, brightness in
            self?.onColorDidChange(color, brightness)
        }
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        doneButton.setTitleColor(doneButton.tintColor, for: .normal)
        setNeedsLayout()
    }
    
    @objc func actionButtonTapped() {
        onColorSelected?(selectedColor)
        self.isHidden = true
        
        CurrentColors.wasCustom = true
        CurrentColors.custom = selectedColor
        CurrentColors.customPicker?.backgroundColor = selectedColor
    }
    
    @objc func brightnessChanged() {
        var hue        : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha      : CGFloat = 0
        selectedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if (brightnessSlider.value == 0 && saturation > 0) {
            return
        }
        selectedColor = UIColor(hue: hue, saturation: saturation, brightness: CGFloat(brightnessSlider.value), alpha: 1.0)
        updateSelectedColor()
    }
    
    private func onColorDidChange(_ color: UIColor, _ brightness: CGFloat) {
        selectedColor = color
        brightnessSlider.value = Float(brightness)
        updateSelectedColor()
    }
    
    private func updateSelectedColor() {
        selectedColorView.backgroundColor = selectedColor
        selectedColorView.setNeedsLayout()
        colorLabel.text = getHexString(selectedColor)
        colorLabel.setNeedsLayout()
    }
    
    private func setBrightnessFromSelectedColor() {
        var hue        : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha      : CGFloat = 0
        selectedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        brightnessSlider.value = Float(brightness)
    }
    
    private func getHexString(_ color: UIColor) -> String {
        var r: CGFloat = 0.000
        var g: CGFloat = 0.000
        var b: CGFloat = 0.000
        var a: CGFloat = 0.000
        if (color.getRed(&r, green: &g, blue: &b, alpha: &a)) {
            let rgb = [r, g, b].map { $0 * 255 }.reduce("", { $0 + String(format: "%02x", Int($1)) })
            return " #\(rgb)"
        } else {
            return " #000000"
        }
    }
}

//Color Palette
@IBDesignable
class ColorPalleteView : UIView {
    
    @IBInspectable var preSelectedColor: UIColor = .red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var onColorDidChange: ((_ color: UIColor, _ brightness: CGFloat) -> ())?
    
    let saturationExponentTop:Float = 1.0
    let saturationExponentBottom:Float = 1.5
    let elementSize: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
    }
    
    private var sHue : CGFloat = 0
    private var sSaturation : CGFloat = 0
    private var sBrightness : CGFloat = 0
    private var sAlpha      : CGFloat = 0
    private var selectedX:CGFloat = 0
    private var selectedY:CGFloat = 0
    private var displayPointer = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for y in stride(from: CGFloat(0), to: rect.height, by: elementSize) {
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height //CGFloat(1.0)
            
            for x in stride(from: (0 as CGFloat), to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y: y + rect.origin.y, width: elementSize, height: elementSize))
            }
        }
        
        UIColor.black.set()
        let border = UIBezierPath(rect: rect)
        border.lineWidth = 2
        border.stroke()
        
        if (displayPointer) {
            UIColor.white.set()
            let pointerDiameter = CGFloat(10.0)
            let pointerRect = CGRect(x:selectedX - pointerDiameter / 2.0, y:selectedY - pointerDiameter / 2.0, width:pointerDiameter, height:pointerDiameter)
            let path = UIBezierPath(ovalIn: pointerRect)
            path.lineWidth = 2
            path.stroke()
        }
        displayPointer = false
    }
    
    
    
    func getColorAtPoint(point: CGPoint) -> (UIColor, CGFloat) {
        let roundedPoint = point
        var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
            : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height // CGFloat(1.0)
        let hue = roundedPoint.x / self.bounds.width
        
        return (UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0), brightness)
    }
    
    
    @objc func touchedColor(gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.location(in: self)
        let color = getColorAtPoint(point: point)
        self.onColorDidChange?(color.0, color.1)
        
        selectedX = point.x
        selectedY = point.y
        displayPointer = true
        preSelectedColor = color.0
    }
}
