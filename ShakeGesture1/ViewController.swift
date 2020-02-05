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
    var gyroAudioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAccelerometer()
        setShakeSound("katana_slash")
        setStartSound("katana_drawing")
        setGyroSound("katana_hold")
    }
    
    @IBAction func tapSegmentControl(_ sender: Any) {
        //後でセグメントindexによって音源をセットし直す
    }
    
    @IBAction func tapButton(_ sender: Any) {
        startAudioPlayer.play()
    }
    
    func getAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let acceleration = data?.acceleration else { return }
                self.updateAccelerationData(data: acceleration)
            }
        }
    }
    
    func updateAccelerationData(data: CMAcceleration) {
        print("加速度データ: \(data)")
        
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
    
    func getGyro() {
        motionManager.gyroUpdateInterval = 0.5
        motionManager.startGyroUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let rotationRate = data?.rotationRate else { return }
                self.updateGyroData(data: rotationRate)
            }
        }
    }
    
    func changeShakeSoundInCurrentMode(_ currentShakeSoundType: Bool) -> Bool {
        let shakeSoundList = [["katana_swing", "katana_slash"], ["light_saber", "light_saber"], ["light_saber", "light_saber"]]
        let segmentIndex = self.segmentControl.selectedSegmentIndex
        if currentShakeSoundType {
            setGyroSound(shakeSoundList[segmentIndex][1])
            return false
        }else {
            setGyroSound(shakeSoundList[segmentIndex][0])
            return true
        }
    }
    
    func updateGyroData(data: CMRotationRate) {
        print("ジャイロデータ: \(data)")

        var currentShakeSoundType = true
        
        let y = data.y
        let synthetic = (y * y)
        
        if synthetic >= 6 {
            currentShakeSoundType = changeShakeSoundInCurrentMode(currentShakeSoundType)
            gyroAudioPlayer.play()
        }
    }

}

extension ViewController: AVAudioPlayerDelegate {
    func setShakeSound(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
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
    
    func setStartSound(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
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
    
    func setGyroSound(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
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
