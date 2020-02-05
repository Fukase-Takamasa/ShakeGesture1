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
    var shakeAudioPlayer2 = AVAudioPlayer()
    var startAudioPlayer = AVAudioPlayer()
    var gyroAudioPlayer = AVAudioPlayer()
    
    var preBool = false
    var postBool = false
    var currentShakeSoundType = true
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSounds()
        getAccelerometer()
        getGyro()
    }
    
    @IBAction func tapSegmentControl(_ sender: Any) {
        setSounds()
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
        
        let x = data.x
        let y = data.y
        let z = data.z
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        
        if preBool {
            postBool = true
        }
        
        if !postBool && synthetic >= 4 {
            if currentShakeSoundType {
                shakeAudioPlayer.currentTime = 0
                shakeAudioPlayer.play()
            }else {
                shakeAudioPlayer2.currentTime = 0
                shakeAudioPlayer2.play()
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //バイブレーション
            
            preBool = true
        }

        if postBool && synthetic >= 4 {
            if currentShakeSoundType {
                shakeAudioPlayer.currentTime = 0
                shakeAudioPlayer.play()
            }else {
                shakeAudioPlayer2.currentTime = 0
                shakeAudioPlayer2.play()
            }
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
    
    func updateGyroData(data: CMRotationRate) {
        print("ジャイロデータ: \(data)")
        let y = data.y
        let synthetic = (y * y)
        
        if synthetic >= 8 {
            print("ジャイロセンサー反応")
            if currentShakeSoundType {
                currentShakeSoundType = false
            }else {
                currentShakeSoundType = true
            }
            shakeAudioPlayer.currentTime = 0
            gyroAudioPlayer.play()
            print("currentShakeSoundType: \(self.currentShakeSoundType)")
        }
    }

}

extension ViewController: AVAudioPlayerDelegate {
    
    func setSounds() {
        let index = self.segmentControl.selectedSegmentIndex
        setShakeSound(SoundList.sounds[index]["shake1"]!)
        setShakeSound2(SoundList.sounds[index]["shake2"]!)
        setStartSound(SoundList.sounds[index]["start"]!)
        setGyroSound(SoundList.sounds[index]["gyro"]!)
    }
    
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
    
    func setShakeSound2(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("shake2音声ファイルが見つかりません")
            return
        }
        do {
            shakeAudioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            shakeAudioPlayer2.delegate = self
            shakeAudioPlayer2.prepareToPlay()
        } catch {
            print("shake2音声セットエラー")
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
            print("gyro音声ファイルが見つかりません。")
            return
        }
        do {
            gyroAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            gyroAudioPlayer.delegate = self
            gyroAudioPlayer.prepareToPlay()
        } catch {
            print("gyro音声セットエラー")
        }
    }
}
