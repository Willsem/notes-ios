//
//  ViewController.swift
//  Notes
//
//  Created by Александр Степанов on 28/06/2019.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Destroy date switch
    @IBOutlet weak var dateSwitch: UISwitch!
    
    // Bool variable equals dateSwitch state
    private var dateSwitchState: Bool = false
    
    // Destroy date picker
    @IBOutlet weak var dateSelect: UIDatePicker!
    
    // Constrain between dateSwitch and pickers
    @IBOutlet weak var pickerConstrain: NSLayoutConstraint!
    
    // Text field for content note
    @IBOutlet weak var contentField: UITextView!
    
    // Set to white color
    @IBOutlet weak var whitePicker: ColorPicker!
    
    // Set to red color
    @IBOutlet weak var redPicker: ColorPicker!
    
    // Set to blue color
    @IBOutlet weak var bluePicker: ColorPicker!
    
    // Set to custom color -> color picker
    @IBOutlet weak var customPicker: ColorPicker!
    
    // Interface for choose your custom color
    @IBOutlet weak var customColorPicker: ColorPickerView!
    
    // Background image for custom picker
    @IBOutlet weak var backgroundCustom: UIImageView!
    
    // Constant for border radius pickers
    private let cornerRadiusPicker: CGFloat = 10
    
    // Scroll of all content
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set auto height for content
        contentField.delegate = self
        
        dateSelect.isHidden = true
        
        [
            whitePicker,
            redPicker,
            bluePicker,
            customPicker,
            contentField
            ].forEach {
                $0?.layer.borderWidth = 1
                $0?.layer.borderColor = UIColor.black.cgColor
                $0?.layer.cornerRadius = cornerRadiusPicker
        }
        
        backgroundCustom.layer.cornerRadius = cornerRadiusPicker
        
        contentField.layer.borderColor = UIColor.gray.cgColor
        
        whitePicker.isSelected = true
        customPicker.layer.zPosition = 10
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector:
            #selector(self.keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        
        CurrentColors.customPicker = customPicker
    }
    
    // Tap to white picker
    @IBAction func whiteSelect(_ sender: Any) {
        whitePicker.isSelected = true
        redPicker.isSelected = false
        bluePicker.isSelected = false
        customPicker.isSelected = false
    }
    
    // Tap to red picker
    @IBAction func redSelect(_ sender: Any) {
        whitePicker.isSelected = false
        redPicker.isSelected = true
        bluePicker.isSelected = false
        customPicker.isSelected = false
    }
    
    // Tap to blue picker
    @IBAction func blueSelect(_ sender: Any) {
        whitePicker.isSelected = false
        redPicker.isSelected = false
        bluePicker.isSelected = true
        customPicker.isSelected = false
    }
    
    // Tap to custom picker
    @IBAction func customSelect(_ sender: Any) {
        if !CurrentColors.wasCustom {
            let alert = UIAlertController(title: "Color picker", message: "Press and hold for a second to open the color palette.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            whitePicker.isSelected = false
            redPicker.isSelected = false
            bluePicker.isSelected = false
            customPicker.isSelected = true
        }
    }
    
    @IBAction func customSelectLong(_ sender: Any) {
        whitePicker.isSelected = false
        redPicker.isSelected = false
        bluePicker.isSelected = false
        customPicker.isSelected = true
        customColorPicker.isHidden = false
    }
    
    // Tap to date switch
    @IBAction func dateSwitchAction(_ sender: UISwitch) {
        dateSwitchState = !dateSwitchState
        if dateSwitchState {
            dateSelect.isHidden = false
            pickerConstrain.constant = 240
        } else {
            dateSelect.isHidden = true
            pickerConstrain.constant = 10
        }
    }
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                
                if constraint.constant < 200 {
                    constraint.constant = 200
                }
            }
        }
    }
    
    // Update the scroll view insets to make the content scrollable when the keyboard is displayed
    @objc func keyboardDidShow(notification: NSNotification) {
        var info = notification.userInfo
        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }
    
    // Restore the scroll view insets
    @objc func keyboardDidHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
}

