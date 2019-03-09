//
//  ViewController.swift
//  correct-a-spine
//
//  Created by Jack Morrison on 09/03/2019.
//  Copyright © 2019 Jack Morrison. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BluetoothSerialDelegate{
    
    //MARK: Properties
    @IBOutlet weak var recommendation: UILabel!
    
    
    func serialDidChangeState() {
        
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        serial = BluetoothSerial(delegate: self)
        
        if !serial.isPoweredOn {
            recommendation.text = "Bluetooth off"
            print("off")
            //return
        } else {
            recommendation.text = "Bluetooth turned on"
            print("on")
        }
    }


}

