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
import AudioToolbox

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
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                self.updateAccelerationData(data: (data?.acceleration)!)
            }
        }
    }
    
    func updateAccelerationData(data: CMAcceleration) {
        print(data)
        
        var preBool = false
        var postBool = false
        
        let x = data.x
        let y = data.y
        let z = data.z
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        
        if preBool {
            postBool = true
        }
        
        if !postBool && synthetic >= 3 {
            audioPlayer.currentTime = 0 //再生中の音を止める
            audioPlayer.play()
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) //バイブレーション
            
            preBool = true
        }
        
        if postBool && synthetic >= 5 {
            audioPlayer.currentTime = 0
            audioPlayer.play()
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            postBool = false
            preBool = false
        }
        
    }

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
