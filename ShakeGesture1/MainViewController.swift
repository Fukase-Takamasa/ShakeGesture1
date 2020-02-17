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
    
    let motionManager = CMMotionManager()
    
    var audioPlayer1 = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()
    var audioPlayer3 = AVAudioPlayer()
    var audioPlayer4 = AVAudioPlayer()
    var audioPlayer5 = AVAudioPlayer()
        
    private var presenter: MainPresenter?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bulletsImageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = MainPresenter(listener: self)
                
        presenter?.viewDidLoad(selectedSegmentIndex: self.segmentControl.selectedSegmentIndex)
        
        setUpAccelerometer()
        setUpGyro()
    }
    
    private func setUpAccelerometer() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let acceleration = data?.acceleration else { return }
                self.presenter?.didUpdateAccelerationData(data: acceleration,
                                                          selectedSegmentIndex: self.segmentControl.selectedSegmentIndex)
            }
        }
    }
    
    private func setUpGyro() {
        motionManager.gyroUpdateInterval = 0.2
        motionManager.startGyroUpdates(to: OperationQueue()) {
            (data, error) in
            DispatchQueue.main.async {
                guard let rotationRate = data?.rotationRate else { return }
                self.presenter?.didUpdateGyroData(data: rotationRate,
                                                  selectedSegmentIndex: self.segmentControl.selectedSegmentIndex)
            }
        }
    }
    
    @IBAction func tapSegmentControl(_ sender: Any) {
        presenter?.didTapSegmentedControl(tappedSegmentIndex: self.segmentControl.selectedSegmentIndex)
    }
}

//extension MainViewController: AVAudioPlayerDelegate {
//}

extension MainViewController: MainViewInterface {
    
    func setImages(for soundType: SoundType?, pistolBulletsCount: Int) {
        
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
            self.setBulletsImageView(with: UIImage(named: "bullets\(pistolBulletsCount)"))
        case .motorBike:
            imageView.image = UIImage(named: "motorBikeImage")
            bulletsImageView.isHidden = true
        case .ultraSoul:
            imageView.image = UIImage(named: "ultraSoulImage")
            bulletsImageView.isHidden = true
        }
    }
    
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
    
    func playSound(of index: Int) {
        
        switch index {
        case 1:
            audioPlayer1.currentTime = 0
            audioPlayer1.play()
        case 2:
            audioPlayer2.currentTime = 0
            audioPlayer2.play()
        case 3:
            audioPlayer3.currentTime = 0
            audioPlayer3.play()
        case 4:
            audioPlayer4.currentTime = 0
            audioPlayer4.play()
        case 5:
            audioPlayer5.currentTime = 0
            audioPlayer5.play()
        default:
            break
        }
    }
    
    func vibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) //バイブレーション
    }
    
    func setBulletsImageView(with image: UIImage?) {
        bulletsImageView.image = image
    }
}

extension MainViewController {

    private func setAudioPlayer(forIndex index: Int, resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("gyro音声ファイルが見つかりません。")
            return
        }
        do {
            switch index {
            case 1:
                audioPlayer1 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//                audioPlayer1.delegate = self
                audioPlayer1.prepareToPlay()
            case 2:
                audioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//                audioPlayer2.delegate = self
                audioPlayer2.prepareToPlay()
            case 3:
                audioPlayer3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//                audioPlayer3.delegate = self
                audioPlayer3.prepareToPlay()
            case 4:
                audioPlayer4 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//                audioPlayer4.delegate = self
                audioPlayer4.prepareToPlay()
            case 5:
                audioPlayer5 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//                audioPlayer5.delegate = self
                audioPlayer5.prepareToPlay()
            default:
                break
            }
        } catch {
            print("gyro音声セットエラー")
        }
    }
}
