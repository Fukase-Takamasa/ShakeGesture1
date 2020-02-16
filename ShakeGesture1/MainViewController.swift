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

class MainViewController: UIViewController {
    
    enum SoundType: Int {
        case katana = 0
        case lightSaber = 1
        case pistol = 2
        case motorBike = 3
        case ultraSoul = 4
    }
    
    let motionManager = CMMotionManager()
    
    var audioPlayer1 = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()
    var audioPlayer3 = AVAudioPlayer()
    var audioPlayer4 = AVAudioPlayer()
    var audioPlayer5 = AVAudioPlayer()
    
    var preBool = false
    var postBool = false
    var pistolBullets = 7
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bulletsImageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentSoundType = SoundType(rawValue: self.segmentControl.selectedSegmentIndex)
        setImages(for: currentSoundType)
        setSounds(for: currentSoundType)
        audioPlayer1.play()
        getAccelerometer()
        getGyro()
    }
    
    @IBAction func tapSegmentControl(_ sender: Any) {
        let currentSoundType = SoundType(rawValue: self.segmentControl.selectedSegmentIndex)
        setImages(for: currentSoundType)
        setSounds(for: currentSoundType)
        audioPlayer1.play()
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
            break
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
            break
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


extension MainViewController {
    
    func setImages(for soundType: SoundType?) {
        
        guard let soundType = soundType else { return }
        
        switch soundType {
        case .katana:
            imageView.image = UIImage(named: "katanaImage")
            bulletsImageView.isHidden = true
        case .lightSaber:
            imageView.image = UIImage(named: "lightSaberImage")
            bulletsImageView.isHidden = true
        case .pistol:
            imageView.image = UIImage(named: "pistolImage")
            bulletsImageView.isHidden = false
            bulletsImageView.image = UIImage(named: "bullets\(pistolBullets)")
        case .motorBike:
            imageView.image = UIImage(named: "motorBikeImage")
            bulletsImageView.isHidden = true
        case .ultraSoul:
            imageView.image = UIImage(named: "ultraSoulImage")
            bulletsImageView.isHidden = true
        }
    }
    
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
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool {
            if synthetic >= 20 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if synthetic >= 5  {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if synthetic >= 20 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if synthetic >= 5  {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func lightSaberAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool && synthetic >= 5 {
            resetAllAudioPlayerTime()
            audioPlayer2.play()
            vibration()
            preBool = true
        }
        if postBool && synthetic >= 5 {
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
        if !postBool && (x * x) + (y * y) >= 4 {
            if pistolBullets > 0 {
                pistolBullets -= 1
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if pistolBullets <= 0 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                preBool = true
            }
        }
        if postBool && (x * x) + (y * y) >= 4 {
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
                postBool = false
                preBool = false
            }
        }
        bulletsImageView.image = UIImage(named: "bullets\(pistolBullets)")
    }
    
    func pistolGyro(_ x: Double, _ y: Double, _ z: Double) {
        if pistolBullets <= 0 && (x * x) >= 30 {
            pistolBullets = 7
            audioPlayer4.play()
            print("ピストルの弾をリロードしました  残弾数: \(pistolBullets)発")
            bulletsImageView.image = UIImage(named: "bullets\(pistolBullets)")
        }
    }
    
    func motorBikeGyro(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if (y * y) >= 6 && (y * y) <= 29 {
                print("エンジン吹かし: 小")
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if (y * y) >= 30 && (y * y) <= 49 {
                print("エンジン吹かし: 中")
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if (y * y) >= 50 {
                print("エンジン吹かし: 大")
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
            if (y * y) >= 6 && (y * y) <= 29 {
                print("エンジン吹かし: 小")
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 30 && (y * y) <= 49 {
                print("エンジン吹かし: 中")
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 50 {
                print("エンジン吹かし: 大")
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }

    func ultraSoulGyro(_ x: Double, _ y: Double, _ z: Double) {
        let synthetic = (x * x) + (y * y) + (z * z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool {
            if synthetic >= 50 {
                resetAllAudioPlayerTime()
                audioPlayer5.play()
                vibration()
                preBool = true
            }else if (x * x) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                preBool = true
            }else if (z * z) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                preBool = true
            }else if (y * y) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                preBool = true
            }
        }
        if postBool {
             if synthetic >= 50 {
                resetAllAudioPlayerTime()
                audioPlayer5.play()
                vibration()
                postBool = false
                preBool = false
             }else if (x * x) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer2.play()
                vibration()
                postBool = false
                preBool = false
             }else if (z * z) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer3.play()
                vibration()
                postBool = false
                preBool = false
             }else if (y * y) >= 8 {
                resetAllAudioPlayerTime()
                audioPlayer4.play()
                vibration()
                postBool = false
                preBool = false
            }
        }
    }
}

extension MainViewController: AVAudioPlayerDelegate {
    
    func setSounds(for soundType: SoundType?) {
        
        guard let soundType = soundType else { return }
        
        switch soundType {
        case .katana:
            setAudioPlayer(forIndex: 1, resourceFileName: "katana_drawing")
            setAudioPlayer(forIndex: 2, resourceFileName: "katana_slash")
            setAudioPlayer(forIndex: 3, resourceFileName: "katana_sting")
            setAudioPlayer(forIndex: 4, resourceFileName: "katana_hold")
        case .lightSaber:
            setAudioPlayer(forIndex: 1, resourceFileName: "lightSaber_start")
            setAudioPlayer(forIndex: 2, resourceFileName: "lightSaber_swing")
        case .pistol:
            setAudioPlayer(forIndex: 1, resourceFileName: "pistol-slide")
            setAudioPlayer(forIndex: 2, resourceFileName: "pistol-fire")
            setAudioPlayer(forIndex: 3, resourceFileName: "pistol-out-bullets")
            setAudioPlayer(forIndex: 4, resourceFileName: "pistol-reload")
        case .motorBike:
            setAudioPlayer(forIndex: 1, resourceFileName: "motorBike_engineStart")
            setAudioPlayer(forIndex: 2, resourceFileName: "motorBike_engine1")
            setAudioPlayer(forIndex: 3, resourceFileName: "motorBike_engine2")
            setAudioPlayer(forIndex: 4, resourceFileName: "motorBike_engine3")
        case .ultraSoul:
            setAudioPlayer(forIndex: 1, resourceFileName: "ultraSoul_start")
            setAudioPlayer(forIndex: 2, resourceFileName: "ultraSoul_1")
            setAudioPlayer(forIndex: 3, resourceFileName: "ultraSoul_2")
            setAudioPlayer(forIndex: 4, resourceFileName: "ultraSoul_3")
            setAudioPlayer(forIndex: 5, resourceFileName: "ultraSoul_4")
        }
    }

    private func setAudioPlayer(forIndex index: Int, resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("gyro音声ファイルが見つかりません。")
            return
        }
        do {
            switch index {
            case 1:
                audioPlayer1 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer1.delegate = self
                audioPlayer1.prepareToPlay()
            case 2:
                audioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer2.delegate = self
                audioPlayer2.prepareToPlay()
            case 3:
                audioPlayer3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer3.delegate = self
                audioPlayer3.prepareToPlay()
            case 4:
                audioPlayer4 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer4.delegate = self
                audioPlayer4.prepareToPlay()
            case 5:
                audioPlayer5 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer5.delegate = self
                audioPlayer5.prepareToPlay()
            default:
                break
            }
        } catch {
            print("gyro音声セットエラー")
        }
    }
}
