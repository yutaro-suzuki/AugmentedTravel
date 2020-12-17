//
//  DestinationModel.swift
//  Destination
//
//  Created by Yutaro Suzuki on 2020/12/08.
//

import Foundation
import SwiftUI
import CoreLocation
import SceneKit

class DestinationModel: ObservableObject {
    @Published var isSet: Bool = false
    @Published var distance: CLLocationDistance = -1 {
        didSet {
            if distance >= 1000 {
                distanceStr = "\(Int(round(distance/1000))) km from here"
            } else if distance > 3 {
                distanceStr = "\(Int(round(distance))) m from here"
            } else if distance > 0 {
                distanceStr = "here"
            } else {
                distanceStr = "set your destination!"
            }
        }
    }
    @Published var distanceStr: String = "set your destination!"
    @Published var deviceHeading: CLLocationDirection = 0
    @Published var degree: Double = 0
}
