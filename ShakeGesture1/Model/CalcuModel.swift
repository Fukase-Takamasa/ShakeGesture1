//
//  CalcuModel.swift
//  ShakeGesture1
//
//  Created by Takahiro Fukase on 2020/02/16.
//  Copyright © 2020 fukase. All rights reserved.
//

import Foundation

class CalcuModel {
    
    func getCompositeAcceleration(_ x: Double, _ y: Double, _ z: Double) -> Double {
        return (x * x) + (y * y) + (z * z)
    }
}
