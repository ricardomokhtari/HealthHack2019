//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

var dataCount = 0

var angles = Array(repeating: 0, count: 20)
var angleCount = 0


final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    
    @IBOutlet weak var mainTextView: UITextView!
    //@IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!


//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init serial
        serial = BluetoothSerial(delegate: self)
        
        // UI
        mainTextView.text = ""
        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        // we want to be notified when the keyboard is shown (so we can move the textField up)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // to dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(SerialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // style the bottom UIView
//        bottomView.layer.masksToBounds = false
//        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
//        bottomView.layer.shadowRadius = 0
//        bottomView.layer.shadowOpacity = 0.5
//        bottomView.layer.shadowColor = UIColor.gray.cgColor
    
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        // animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            }, completion: { Bool -> Void in
            self.textViewScrollToBottom()
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        // bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = 0
        }, completion: nil)

    }
    
    func reloadView() {
        
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "correct-a-spine"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "correct-a-spine"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
    
    func textViewScrollToBottom() {
        let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        mainTextView.scrollRangeToVisible(range)
    }
    

//MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        // add the received text to the textView, optionally with a line break at the end
       // mainTextView.text! += message
       // let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
       // if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
        print(String(dataCount) + " " + message)
        if(dataCount == 5) {
            angles[angleCount] = (message as NSString).integerValue
            angleCount += 1
            angleCount = angleCount % 20
            print(String(average(nums: angles)))
            mainTextView.text! += String(average(nums: angles))
            if(average(nums: angles) > 10){
                self.view.backgroundColor = UIColor.red
            } else {
                self.view.backgroundColor = UIColor.blue
            }
        }
        
        
        dataCount += 1
        dataCount = dataCount % 6
        textViewScrollToBottom()
    }
    
    func average(nums: [Int]) -> Int {
        
        var total = 0
        //use the parameter-array instead of the global variable votes
        for num in nums{
            
            total += Int(num)
            
        }
        
        let numTotal = Int(nums.count)
        let average = total/numTotal
        return average
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
            present(alert, animated: true, completion: nil)
            //messageField.resignFirstResponder()
            return true
        }
        
        // send the message to the bluetooth device
        // but fist, add optionally a line break or carriage return (or both) to the message
        let pref = UserDefaults.standard.integer(forKey: MessageOptionKey)
        //var msg = messageField.text!
//        switch pref {
//        case MessageOption.newline.rawValue:
//            //msg += "\n"
//        case MessageOption.carriageReturn.rawValue:
//            //msg += "\r"
//        case MessageOption.carriageReturnAndNewline.rawValue:
//            //msg += "\r\n"
//        default:
//            //msg += ""
//        }
        
        // send the message and clear the textfield
        //serial.sendMessageToDevice(msg)
        //messageField.text = ""
        return true
    }
    
    func dismissKeyboard() {
        //messageField.resignFirstResponder()
    }
    
    
//MARK: IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
}
