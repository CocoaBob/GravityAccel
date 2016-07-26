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
    
    private let motionManager = MotionManager()
    private let chartValuesCount = 1200
    private var chartValues = [Double]()
    
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
        
        self.motionManager.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.motionManager.stop()
    }
}

// MARK: Motion
extension ViewController: MotionManagerObserver {
    
    func motionManagerDidUpdateVerticalAcceleration(value: Double) {
        while self.chartValues.count > chartValuesCount {
            self.chartValues.removeAtIndex(0)
        }
        self.chartValues.append(value)
        dispatch_async(dispatch_get_main_queue()) { 
            self.updateChart()
        }
    }
}

// MARK: Chart
extension ViewController {
    
    private func setupChart() {
        // Default values are 0s
        self.chartValues.removeAll()
        for _ in 0..<chartValuesCount {
            chartValues.append(0)
        }
        
        // Chart view
        self.chartView.legend.form = .Line
        self.chartView.autoScaleMinMaxEnabled = true
        self.chartView.backgroundColor = UIColor.whiteColor()
        self.chartView.descriptionText = ""
        
        let xAxis = self.chartView.xAxis
        xAxis.labelFont = UIFont.systemFontOfSize(12)
        xAxis.labelTextColor = UIColor.blueColor()
        xAxis.drawGridLinesEnabled = false
        xAxis.gridLineWidth = 0.5
        xAxis.gridLineDashLengths = [5, 5]
        xAxis.spaceBetweenLabels = 1
        
        let leftAxis = self.chartView.leftAxis
        leftAxis.axisMaxValue = 5.0
        leftAxis.axisMinValue = -5.0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.5
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawZeroLineEnabled = true
        
        self.chartView.rightAxis.enabled = false
        
        let dataSet = LineChartDataSet(yVals: nil, label: "Accel Changes")
        dataSet.mode = .Linear
        dataSet.lineWidth = 1
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
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
            for _ in 0..<self.chartValues.count {
                xVals.append(nil)
            }
            self.chartView.data?.xVals = xVals
            
            self.chartView.notifyDataSetChanged()
        }
    }
}

// MARK: Action
extension ViewController {
    
    @IBAction func toggle() {
        if self.motionManager.isRunning() {
            self.motionManager.stop()
        } else {
            self.motionManager.start()
        }
    }
}
