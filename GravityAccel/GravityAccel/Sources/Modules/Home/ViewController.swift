//
//  ViewController.swift
//  GravityAccel
//
//  Created by CocoaBob on 26/07/16.
//  Copyright © 2016 Cocoabob. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var btnAction: UIButton!
    
    private let chartValuesMaxCount = 600
    private let motionManagerFPS = 30
    private let motionManager = MotionManager()
    private var chartValues = [Double]()
    private var chartDurations = [Double]()
    
    private var startTimestamp: NSTimeInterval = 0
    private var isUpdatingChartView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupChart()
        
        self.motionManager.addObserver(self)
    }
    
    deinit {
        self.motionManager.removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stop()
    }
}

// MARK: Motion
extension ViewController: MotionManagerObserver {
    
    func motionManagerDidUpdateVerticalAcceleration(value: Double) {
        if !self.isUpdatingChartView {
            dispatch_async(dispatch_get_main_queue()) {
                self.isUpdatingChartView = true
                while self.chartValues.count > self.chartValuesMaxCount {
                    self.chartValues.removeAtIndex(0)
                    self.chartDurations.removeAtIndex(0)
                }
                self.chartValues.append(value)
                self.chartDurations.append(NSDate.timeIntervalSinceReferenceDate() - self.startTimestamp)
                self.updateChart()
                self.isUpdatingChartView = false
            }
        }
    }
}

// MARK: Chart
extension ViewController {
    
    private func setupChart() {
        // Reset all
        self.chartValues.removeAll()
        self.self.chartDurations.removeAll()
        for _ in 0..<chartValuesMaxCount {
            self.chartValues.append(0)
            self.chartDurations.append(-1)
        }
        
        // Chart view
        self.chartView.legend.form = .Line
        self.chartView.autoScaleMinMaxEnabled = false
        self.chartView.backgroundColor = UIColor.whiteColor()
        self.chartView.descriptionText = "\(chartValuesMaxCount/motionManagerFPS) seconds history"
        
        self.chartView.viewPortHandler
        
        let xAxis = self.chartView.xAxis
        xAxis.labelFont = UIFont.systemFontOfSize(9)
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = .Bottom;
        
        self.chartView.rightAxis.enabled = false
        
        let leftAxis = self.chartView.leftAxis
        leftAxis.axisMaxValue = 10.0
        leftAxis.axisMinValue = -10.0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled = true
        
        let dataSet = LineChartDataSet(yVals: nil, label: "Accel Changes")
        dataSet.mode = .Linear
        dataSet.lineWidth = 1
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        dataSet.setColor(UIColor.blueColor())
        
        self.chartView.data = LineChartData(xVals: [String?](), dataSets: [dataSet])
    }
    
    private func updateChart() {
        if let dataSet = self.chartView.data?.dataSets[0] as? LineChartDataSet {
            var yVals = [ChartDataEntry]()
            for (i, value) in self.chartValues.enumerate() {
                yVals.append(ChartDataEntry(value: value, xIndex: i))
            }
            dataSet.yVals = yVals
            
            var xVals = [String?]()
            for i in 0..<self.chartValues.count {
                let duration = self.chartDurations[i]
                if duration > 0 {
                    xVals.append(String(format: "%.1fs", duration))
                } else {
                    xVals.append(nil)
                }
            }
            self.chartView.data?.xVals = xVals
            
            self.chartView.notifyDataSetChanged()
        }
    }
}

// MARK: Action
extension ViewController {
    
    func start() {
        self.motionManager.start()
        self.btnAction.setTitle("Stop", forState: .Normal)
        self.startTimestamp = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func stop() {
        self.motionManager.stop()
        self.btnAction.setTitle("Start", forState: .Normal)
    }
    
    @IBAction func toggle() {
        if self.motionManager.isRunning() {
            self.stop()
        } else {
            self.start()
        }
    }
}
