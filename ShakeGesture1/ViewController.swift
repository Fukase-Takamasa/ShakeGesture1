//
//  ViewController.swift
//  ShakeGesture1
//
//  Created by 深瀬貴将 on 2020/01/31.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import CoreMotion
import <#module#>

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    var x = 0
    var y = 0
    var z = 0
    
    var shakesCount = 0
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabel.text = String(shakesCount)
        
        self.motionManager.accelerometerUpdateInterval = 0.5
        self.motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                self.updateAccelerationData(data: (data?.acceleration)!)
            }
        }
    }
    
    func updateAccelerationData(data: CMAcceleration) {

        print(("x = \(Int(data.x)), y = \(Int(data.y)), z = \(Int(data.z))"))

        var isShaken = self.x != Int(data.x) || self.y != Int(data.y) || self.z != Int(data.z)

        if isShaken {
            shakesCount += 1
            countLabel.text = String(shakesCount)
        }

        self.x = Int(data.x)
        self.y = Int(data.y)
        self.z = Int(data.z)
    }
    
    //override func becomeFirstResponder() -> Bool {
        //return true
    //}
    
    //override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    //    if motion == .motionShake {
    //        shakesCount += 1
    //        countLabel.text = String(shakesCount)
    //    }
    //}


}

