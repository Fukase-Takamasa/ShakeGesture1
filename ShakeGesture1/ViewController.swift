//
//  ViewController.swift
//  ShakeGesture1
//
//  Created by 深瀬貴将 on 2020/01/31.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAccelerometer()
        setSound()
    }
    
    @IBAction func tapButton(_ sender: Any) {
        print("buttonTapped")
    }
    
    func getAccelerometer() {
        motionManager.accelerometerUpdateInterval = 1 / 100
        motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                self.updateAccelerationData(data: (data?.acceleration)!)
            }
        }
    }
    
    func updateAccelerationData(data: CMAcceleration) {
        print(data)
        
        let x = data.x
        let y = data.y
        let z = data.z
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        
        if synthetic >= 5 {
            print("sound")
            audioPlayer.play()
        }
        
    }


    
    
    
    
    
    
//    let motionManager = CMMotionManager()
//    var x = 0
//    var y = 0
//    var z = 0
//
//    var shakesCount = 0
//
//    @IBOutlet weak var countLabel: UILabel!
//
//
//
//    func updateAccelerationData(data: CMAcceleration) {
//
//        print(("x = \(Int(data.x)), y = \(Int(data.y)), z = \(Int(data.z))"))
//
//        var isShaken = self.x != Int(data.x) || self.y != Int(data.y) || self.z != Int(data.z)
//
//        if isShaken {
//            shakesCount += 1
//            countLabel.text = String(shakesCount)
//        }
//
//        self.x = Int(data.x)
//        self.y = Int(data.y)
//        self.z = Int(data.z)
//    }

}

extension ViewController: AVAudioPlayerDelegate {
    func setSound() {
        guard let path = Bundle.main.path(forResource: "light_saber3", ofType: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("音声セットエラー")
        }
    }
}
