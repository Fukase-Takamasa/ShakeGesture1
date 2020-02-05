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
    var shakeAudioPlayer = AVAudioPlayer()
    var startAudioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAccelerometer()
        setShakeSound()
        setStartSound()
    }
    
    @IBAction func tapButton(_ sender: Any) {
        startAudioPlayer.play()
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
            shakeAudioPlayer.currentTime = 0 //再生中の音を止める
            shakeAudioPlayer.play()
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //バイブレーション
            
            preBool = true
        }
        
        if postBool && synthetic >= 3 {
            shakeAudioPlayer.currentTime = 0
            shakeAudioPlayer.play()
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //バイブレーション

            postBool = false
            preBool = false
        }
        
    }

}

extension ViewController: AVAudioPlayerDelegate {
    func setShakeSound() {
        guard let path = Bundle.main.path(forResource: "light_saber3", ofType: "mp3") else {
            print("shake音声ファイルが見つかりません")
            return
        }
        do {
            shakeAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            shakeAudioPlayer.delegate = self
            shakeAudioPlayer.prepareToPlay()
        } catch {
            print("shake音声セットエラー")
        }
    }
    
    func setStartSound() {
        guard let path = Bundle.main.path(forResource: "electric_chain", ofType: "mp3") else {
            print("start音声ファイルが見つかりません。")
            return
        }
        do {
            startAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            startAudioPlayer.delegate = self
            startAudioPlayer.prepareToPlay()
        } catch {
            print("start音声セットエラー")
        }
    }
}
