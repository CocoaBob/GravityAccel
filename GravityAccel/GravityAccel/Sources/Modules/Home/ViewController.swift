//
//  ViewController.swift
//  GravityAccel
//
//  Created by CocoaBob on 26/07/16.
//  Copyright © 2016 Cocoabob. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let motionManager: MotionManager = MotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.motionManager.addObserver(self)
    }
    
    deinit {
        self.motionManager.removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.motionManager.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.motionManager.stop()
    }
}

extension ViewController: MotionManagerObserver {
    
    func motionManagerDidUpdateVerticalAcceleration(value: Double) {
        print(String(format: "%+.2f", value))
    }
}
