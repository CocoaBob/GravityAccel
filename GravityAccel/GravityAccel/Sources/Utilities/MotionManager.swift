//
//  MotionManager.swift
//  AthleticsMate
//
//  Created by CocoaBob on 26/07/16.
//  Copyright © 2016 Cocoabob. All rights reserved.
//

import CoreMotion

protocol MotionManagerObserver: AnyObject {
    
    func motionManagerDidUpdateVerticalAcceleration(value: Double)
}

class MotionManager {
    
    private let motionQueue: NSOperationQueue = NSOperationQueue()
    private let motionManager: CMMotionManager = CMMotionManager()
    private let motionFilter: MotionFilter = MotionFilter(level: 3)
    private var observers: [MotionManagerObserver] = [MotionManagerObserver]()
    
    init() {
        self.motionQueue.maxConcurrentOperationCount = 1
        self.motionManager.deviceMotionUpdateInterval = 1 / 100.0
    }
    
    deinit {
        self.stop()
    }
    
    func addObserver(observer: MotionManagerObserver) {
        self.observers.append(observer)
    }
    
    func removeObserver(observer: MotionManagerObserver) {
        self.observers = self.observers.filter() { $0 !== observer }
    }
    
    func start() {
        if self.motionManager.deviceMotionAvailable {
            self.motionManager.startDeviceMotionUpdatesToQueue(self.motionQueue, withHandler: { (motion, error) in
                self.handleMotion(motion)
            })
        }
    }
    
    func stop() {
        if self.motionManager.deviceMotionActive {
            self.motionManager.stopDeviceMotionUpdates()
            self.motionFilter.reset()
        }
    }
    
    func handleMotion(motion: CMDeviceMotion?) {
        guard let motion = motion else { return }
//        print(String(format: "1 %-6+.3f %-6+.3f %-6+.3f", motion.gravity.x, motion.gravity.y, motion.gravity.z))
//        print(String(format: "2 %-6+.3f %-6+.3f %-6+.3f", motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z))
        let gravityAcceleration = motion.gravity.x*motion.userAcceleration.x + motion.gravity.y*motion.userAcceleration.y + motion.gravity.z*motion.userAcceleration.z
        let filteredValue = self.motionFilter.filter(gravityAcceleration)
        let result = (filteredValue < 0.01 && filteredValue > -0.01) ? 0 : filteredValue
        
        self.observers.forEach { (observer) in
            observer.motionManagerDidUpdateVerticalAcceleration(result)
        }
    }
}

class MotionFilter {
    
    var filterLevel: Int = 3
    private var lastValues: [Double] = [Double]()
    private var lastValuesSum: Double = 0
    
    init(level: Int) {
        self.filterLevel = level
    }
    
    func reset() {
        self.lastValues.removeAll()
        self.lastValuesSum = 0
    }
    
    func filter(value: Double) -> Double {
        if filterLevel == 0 {
            return value
        }
        
        while self.lastValues.count >= filterLevel {
            if let firstValue = self.lastValues.first {
                self.lastValuesSum -= firstValue
                self.lastValues.removeAtIndex(0)
            }
        }
        self.lastValues.append(value)
        self.lastValuesSum += value
        
        return self.lastValuesSum / Double(self.lastValues.count)
    }
}
