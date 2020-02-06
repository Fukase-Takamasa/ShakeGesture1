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
    
    var audioPlayer1 = AVAudioPlayer()  //アイテムごとの起動音
    var audioPlayer2 = AVAudioPlayer()  //以下アクション音声　4パターン
    var audioPlayer3 = AVAudioPlayer()
    var audioPlayer4 = AVAudioPlayer()
    var audioPlayer5 = AVAudioPlayer()
    
    var preBool = false //連続アクション再生時に 前の音声が再生中か判断するもの
    var postBool = false
    var pistolBullets = 7 //ColtM1911（ピストル）の残弾数
    
    @IBOutlet weak var segmentControl: UISegmentedControl! //5つのアイテムの切り替え管理
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSounds()
        audioPlayer1.play() //選択されているアイテムの起動音を鳴らす
        getAccelerometer()
        getGyro()
    }
    
    @IBAction func tapSegmentControl(_ sender: Any) {
        setSounds()
        audioPlayer1.play()
    }
    
    @IBAction func tapButton(_ sender: Any) {
    }
    
    func getAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.2
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
        
        let index = self.segmentControl.selectedSegmentIndex
        switch index {
        case 0:
            katanaAccelerometer(x, y, z)
        case 1:
            lightSaberAccelerometer(x, y, z)
        case 2:
            pistolAccelerometer(x, y, z)
        case 3:
            break
        case 4:
            ultraSoulAccelerometer(x, y, z)
        default:
            break
        }
    }
    
    func getGyro() {
        motionManager.gyroUpdateInterval = 0.2
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
        let x = data.x
        let y = data.y
        let z = data.z
        
        let index = self.segmentControl.selectedSegmentIndex
        switch index {
        case 0:
            katanaGyro(x, y, z)
        case 1:
            break
        case 2:
            pistolGyro(x, y, z)
        case 3:
            motorBikeGyro(x, y, z)
        case 4:
            ultraSoulGyro(x, y, z)
        default:
            break
        }
    }
}


extension ViewController {
    
    func resetAllAudioPlayerTime() {
        audioPlayer1.currentTime = 0
        audioPlayer2.currentTime = 0
        audioPlayer3.currentTime = 0
        audioPlayer4.currentTime = 0
        audioPlayer5.currentTime = 0
    }
    
    func vibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //バイブレーション
    }
    
    func katanaAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if (x * x) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if (y * y) + (z * z) >= 6  {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if (x * x) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
                }else if (y * y) + (z * z) >= 6  {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func katanaGyro(_ x: Double, _ y: Double, _ z: Double) {
        if (y * y) >= 5 {
            audioPlayer4.play()
        }
    }
    
    func lightSaberAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool && synthetic >= 6 {
            resetAllAudioPlayerTime()
            audioPlayer2.play()
            vibration()
            preBool = true
        }
        if postBool && synthetic >= 6 {
            resetAllAudioPlayerTime()
            audioPlayer2.play()
            vibration()
            postBool = false
            preBool = false
        }
    }
    
    func pistolAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        print("ピストルの残弾数: \(pistolBullets) / 7発")
        if preBool {
            postBool = true
        }
        if !postBool && (x * x) + (y * y) >= 6 {
            if pistolBullets > 0 {
                pistolBullets -= 1
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if pistolBullets <= 0 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }
        }
        if postBool && (x * x) + (y * y) >= 6 {
            if pistolBullets > 0 {
                pistolBullets -= 1
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }else if pistolBullets <= 0 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func pistolGyro(_ x: Double, _ y: Double, _ z: Double) {
        if (x * x) >= 8 {
            pistolBullets = 7
            audioPlayer4.play()
            print("ピストルの弾をリロードしました  残弾数: \(pistolBullets)発")
        }
    }
    
    func motorBikeGyro(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if (y * y) >= 3 && (y * y) <= 5.9 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if (y * y) >= 6 && (y * y) <= 8.9 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if (y * y) >= 9 {
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if (y * y) >= 3 && (y * y) <= 5.9 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 6 && (y * y) <= 8.9 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 9 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func ultraSoulAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if (y * y) >= 6 {
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                preBool = true
            }else if (x * x) >= 6 {
                resetAllAudioPlayerTime()
                audioPlayer5.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if (y * y) >= 6 {
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                postBool = false
                preBool = false
            }else if (x * x) >= 6 {
                resetAllAudioPlayerTime()
                audioPlayer5.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func ultraSoulGyro(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if x <= -3 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if x >= 3{
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if x <= -3 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
                }else if x >= 3{
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    
    func setSounds() {
        let index = self.segmentControl.selectedSegmentIndex
        switch index {
        case 0:
            setAudioPlayer1("katana_drawing")
            setAudioPlayer2("katana_slash")
            setAudioPlayer3("katana_sting")
            setAudioPlayer4("katana_hold")
        case 1:
            setAudioPlayer1("lightSaber_start")
            setAudioPlayer2("lightSaber_swing")
        case 2:
            setAudioPlayer1("pistol-slide")
            setAudioPlayer2("pistol-fire")
            setAudioPlayer3("pistol-out-bullets")
            setAudioPlayer4("pistol-reload")
        case 3:
            setAudioPlayer1("motorBike_engineStart")
            setAudioPlayer2("motorBike_engine1")
            setAudioPlayer3("motorBike_engine2")
            setAudioPlayer4("motorBike_engine3")
        case 4:
            setAudioPlayer1("ultraSoul_start")
            setAudioPlayer2("ultraSoul_1")
            setAudioPlayer3("ultraSoul_2")
            setAudioPlayer4("ultraSoul_3")
            setAudioPlayer5("ultraSoul_4")
        default:
            break
        }
    }
    
    func setAudioPlayer1(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("shake音声ファイルが見つかりません")
            return
        }
        do {
            audioPlayer1 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer1.delegate = self
            audioPlayer1.prepareToPlay()
        } catch {
            print("shake音声セットエラー")
        }
    }
    
    func setAudioPlayer2(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("shake2音声ファイルが見つかりません")
            return
        }
        do {
            audioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer2.delegate = self
            audioPlayer2.prepareToPlay()
        } catch {
            print("shake2音声セットエラー")
        }
    }
    
    func setAudioPlayer3(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("start音声ファイルが見つかりません。")
            return
        }
        do {
            audioPlayer3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer3.delegate = self
            audioPlayer3.prepareToPlay()
        } catch {
            print("start音声セットエラー")
        }
    }
    
    func setAudioPlayer4(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("gyro音声ファイルが見つかりません。")
            return
        }
        do {
            audioPlayer4 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer4.delegate = self
            audioPlayer4.prepareToPlay()
        } catch {
            print("gyro音声セットエラー")
        }
    }
    
    func setAudioPlayer5(_ resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("gyro音声ファイルが見つかりません。")
            return
        }
        do {
            audioPlayer5 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer5.delegate = self
            audioPlayer5.prepareToPlay()
        } catch {
            print("gyro音声セットエラー")
        }
    }
}
