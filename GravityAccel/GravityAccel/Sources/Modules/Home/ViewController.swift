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
    
    fileprivate let chartValuesMaxCount = 600
    fileprivate let motionManagerFPS = 30
    fileprivate let motionManager = MotionManager()
    fileprivate var chartValues = [Double]()
    fileprivate var chartDurations = [Double]()
    
    fileprivate var startTimestamp: TimeInterval = 0
    fileprivate var isUpdatingChartView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupChart()
        
        self.motionManager.addObserver(self)
    }
    
    deinit {
        self.motionManager.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stop()
    }
}

// MARK: Motion
extension ViewController: MotionManagerObserver {
    
    func motionManagerDidUpdateVerticalAcceleration(_ value: Double) {
        if !self.isUpdatingChartView {
            DispatchQueue.main.async {
                self.isUpdatingChartView = true
                while self.chartValues.count > self.chartValuesMaxCount {
                    self.chartValues.remove(at: 0)
                    self.chartDurations.remove(at: 0)
                }
                self.chartValues.append(value)
                self.chartDurations.append(Date.timeIntervalSinceReferenceDate - self.startTimestamp)
                self.updateChart()
                self.isUpdatingChartView = false
            }
        }
    }
}

// MARK: Chart
extension ViewController {
    
    fileprivate func setupChart() {
        // Reset all
        self.chartValues.removeAll()
        self.self.chartDurations.removeAll()
        for _ in 0..<chartValuesMaxCount {
            self.chartValues.append(0)
            self.chartDurations.append(-1)
        }
        
        // Chart view
        self.chartView.legend.form = .line
        self.chartView.autoScaleMinMaxEnabled = false
        self.chartView.backgroundColor = UIColor.white
        self.chartView.chartDescription?.text = "\(chartValuesMaxCount/motionManagerFPS) seconds history"
        
        self.chartView.viewPortHandler
        
        let xAxis = self.chartView.xAxis
        xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = .bottom;
//        xAxis.spaceBetweenLabels = Int(4)
        
        self.chartView.rightAxis.enabled = false
        
        let leftAxis = self.chartView.leftAxis
        leftAxis.axisMaxValue = 10.0
        leftAxis.axisMinValue = -10.0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.drawZeroLineEnabled = true
        
        let dataSet = LineChartDataSet(values: nil, label: "Accel Changes")
        dataSet.mode = .linear
        dataSet.lineWidth = 1
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.setColor(UIColor.blue)
        
        let marker = BalloonMarker(color: UIColor(white: 0.9, alpha: 1),
                                   font: UIFont.systemFont(ofSize: 9),
                                   textColor: UIColor.black,
                                   insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        marker.minimumSize = CGSize(width: 48, height: 30)
        self.chartView.marker = marker
        
        self.chartView.data = LineChartData(dataSets: [dataSet])
    }
    
    fileprivate func updateChart() {
        if let dataSet = self.chartView.data?.dataSets[0] as? LineChartDataSet {
            var values = [ChartDataEntry]()
            for (i, value) in self.chartValues.enumerated() {
                values.append(ChartDataEntry(x: Double(i), y: value))
            }
            dataSet.values = values
            
            self.chartView.data?.notifyDataChanged();
            self.chartView.notifyDataSetChanged();
        }
    }
}

// MARK: Action
extension ViewController {
    
    func start() {
        self.motionManager.start()
        self.btnAction.setTitle("Pause", for: UIControlState())
        self.startTimestamp = Date.timeIntervalSinceReferenceDate
    }
    
    func stop() {
        self.motionManager.stop()
        self.btnAction.setTitle("Continue", for: UIControlState())
    }
    
    @IBAction func toggle() {
        if self.motionManager.isRunning() {
            self.stop()
        } else {
            self.start()
        }
    }
}
