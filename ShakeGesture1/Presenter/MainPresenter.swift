//
//  MainPresenter.swift
//  ShakeGesture1
//
//  Created by Takahiro Fukase on 2020/02/16.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import CoreMotion

enum SoundType: Int {
    case katana = 0
    case lightSaber = 1
    case pistol = 2
    case motorBike = 3
    case ultraSoul = 4
}

protocol MainViewInterface: AnyObject {
    func setImages(for soundType: SoundType?, pistolBulletsCount: Int)
    func setSounds(for soundType: SoundType?)
    func playSound(of index: Int)
    func vibration()
    func setBulletsImageView(with image: UIImage?)
}

class MainPresenter {
    
    private var preBool = false
    private var postBool = false
    
    private var pistolBulletsCount = 7
    
    private weak var listener: MainViewInterface!
    
    private var model = CalcuModel()
    
    init(listener: MainViewInterface) {
        self.listener = listener
    }
    
    func viewDidLoad(selectedSegmentIndex: Int) {
        
        guard let soundType = SoundType(rawValue: selectedSegmentIndex) else {
            return
        }
        
        listener.setImages(for: soundType, pistolBulletsCount: pistolBulletsCount)
        listener.setSounds(for: soundType)
        listener.playSound(of: 1)
    }
    
    func didTapSegmentedControl(tappedSegmentIndex: Int) {
        
        guard let soundType = SoundType(rawValue: tappedSegmentIndex) else {
            return
        }
        
        listener.setImages(for: soundType, pistolBulletsCount: pistolBulletsCount)
        listener.setSounds(for: soundType)
        listener.playSound(of: 1)
    }
    
    func didUpdateAccelerationData(data: CMAcceleration, selectedSegmentIndex: Int) {
        print("加速度データ: \(data)")
        
        let x = data.x
        let y = data.y
        let z = data.z
        
        switch selectedSegmentIndex {
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
    
    func didUpdateGyroData(data: CMRotationRate, selectedSegmentIndex: Int) {
        print("ジャイロデータ: \(data)")
        let x = data.x
        let y = data.y
        let z = data.z
        
        switch selectedSegmentIndex {
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

extension MainPresenter {
    
    
    func katanaAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        let compositeAcceleration = model.getCompositeAcceleration(x, y, z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool {
            if compositeAcceleration >= 20 {
                listener.playSound(of: 3)
                listener.vibration()
                preBool = true
            }else if compositeAcceleration >= 5  {
                listener.playSound(of: 2)
                listener.vibration()
                preBool = true
            }
        }
        if postBool {
            if compositeAcceleration >= 20 {
                listener.playSound(of: 3)
                listener.vibration()
                preBool = true
            }else if compositeAcceleration >= 5  {
                listener.playSound(of: 2)
                listener.vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func lightSaberAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        let compositeAcceleration = model.getCompositeAcceleration(x, y, z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool && compositeAcceleration >= 5 {
            listener.playSound(of: 2)
            listener.vibration()
            preBool = true
        }
        if postBool && compositeAcceleration >= 5 {
            listener.playSound(of: 2)
            listener.vibration()
            postBool = false
            preBool = false
        }
    }
    
    func pistolAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        print("ピストルの残弾数: \(pistolBulletsCount) / 7発")
        if preBool {
            postBool = true
        }
        if !postBool && (x * x) + (y * y) >= 4 {
            if pistolBulletsCount > 0 {
                pistolBulletsCount -= 1
                listener.playSound(of: 2)
                listener.vibration()
                preBool = true
            }else if pistolBulletsCount <= 0 {
                listener.playSound(of: 3)
                preBool = true
            }
        }
        if postBool && (x * x) + (y * y) >= 4 {
            if pistolBulletsCount > 0 {
                pistolBulletsCount -= 1
                listener.playSound(of: 2)
                listener.vibration()
                postBool = false
                preBool = false
            }else if pistolBulletsCount <= 0 {
                listener.playSound(of: 3)
                postBool = false
                preBool = false
            }
        }
        listener.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
    }
    
    func pistolGyro(_ x: Double, _ y: Double, _ z: Double) {
        if pistolBulletsCount <= 0 && (x * x) >= 30 {
            pistolBulletsCount = 7
            listener.playSound(of: 4)
            print("ピストルの弾をリロードしました  残弾数: \(pistolBulletsCount)発")
            listener.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
        }
    }
    
    func motorBikeGyro(_ x: Double, _ y: Double, _ z: Double) {
        if preBool {
            postBool = true
        }
        if !postBool {
            if (y * y) >= 6 && (y * y) <= 29 {
                print("エンジン吹かし: 小")
                listener.playSound(of: 2)
                listener.vibration()
                preBool = true
            }else if (y * y) >= 30 && (y * y) <= 49 {
                print("エンジン吹かし: 中")
                listener.playSound(of: 3)
                listener.vibration()
                preBool = true
            }else if (y * y) >= 50 {
                print("エンジン吹かし: 大")
                listener.playSound(of: 4)
                listener.vibration()
                preBool = true
            }
        }
        if postBool {
            if (y * y) >= 6 && (y * y) <= 29 {
                print("エンジン吹かし: 小")
                listener.playSound(of: 2)
                listener.vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 30 && (y * y) <= 49 {
                print("エンジン吹かし: 中")
                listener.playSound(of: 3)
                listener.vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 50 {
                print("エンジン吹かし: 大")
                listener.playSound(of: 4)
                listener.vibration()
                postBool = false
                preBool = false
            }
        }
    }
    
    func ultraSoulGyro(_ x: Double, _ y: Double, _ z: Double) {
        let compositeAcceleration = model.getCompositeAcceleration(x, y, z) //合成加速度
        if preBool {
            postBool = true
        }
        if !postBool {
            if compositeAcceleration >= 50 {
                listener.playSound(of: 5)
                listener.vibration()
                preBool = true
            }else if (x * x) >= 8 {
                listener.playSound(of: 2)
                listener.vibration()
                preBool = true
            }else if (z * z) >= 8 {
                listener.playSound(of: 3)
                listener.vibration()
                preBool = true
            }else if (y * y) >= 8 {
                listener.playSound(of: 4)
                listener.vibration()
                preBool = true
            }
        }
        if postBool {
            if compositeAcceleration >= 50 {
                listener.playSound(of: 5)
                listener.vibration()
                postBool = false
                preBool = false
            }else if (x * x) >= 8 {
                listener.playSound(of: 2)
                listener.vibration()
                postBool = false
                preBool = false
            }else if (z * z) >= 8 {
                listener.playSound(of: 3)
                listener.vibration()
                postBool = false
                preBool = false
            }else if (y * y) >= 8 {
                listener.playSound(of: 4)
                listener.vibration()
                postBool = false
                preBool = false
            }
        }
    }
}
