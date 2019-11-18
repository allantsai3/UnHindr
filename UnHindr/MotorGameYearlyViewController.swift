//
//  MotorGameYearlyViewController.swift
//  UnHindr
//
//  Created by Johnston Yang on 2019-11-17.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import Foundation
import Charts
import FirebaseFirestore
import FirebaseAuth

class MotorGameYearlyViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var motorYearlyGraph: BarChartView!
    
    let motorRef = Services.db.collection("users").document(Services.userRef!).collection("MotorGameData")
    var GraphData: [BarChartDataEntry] = []
    
    var yearMotorValues: [String:Double] = [:]
    var monthAverage = Array(repeating: 0, count: 12)
    var dictMonthAvg: [String:Double] = [:]
    
    let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getMotorData()
        self.title = "Bar Chart"
        motorYearlyGraph.maxVisibleCount = 40
        motorYearlyGraph.drawBarShadowEnabled = false
        motorYearlyGraph.drawValueAboveBarEnabled = true
        motorYearlyGraph.highlightFullBarEnabled = false
        motorYearlyGraph.doubleTapToZoomEnabled = false
        motorYearlyGraph.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
        let leftAxis = motorYearlyGraph.leftAxis
        leftAxis.axisMinimum = 0
        motorYearlyGraph.rightAxis.enabled = false
        let xAxis = motorYearlyGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = motorYearlyGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        xAxis.drawGridLinesEnabled = false
        motorYearlyGraph.xAxis.labelRotationAngle = -45
        // Do any additional setup after loading the view.
    }
    
    func getMotorData()
    {
        motorRef.getDocuments()
            {
                (querySnapshot, err) in
                if err != nil // the program will go into this if statement if the user authentication fails
                {
                    print("Error getting yearly motor data")
                }
                else
                {
                    let today = Date()
                    let calendar = Calendar.current
                    let currentYear = calendar.component(.year, from: today)
                    self.yearLabel.text = "\(currentYear)"
                    for document in querySnapshot!.documents
                    {
                        let timestamp: Timestamp = document.get("Time") as! Timestamp
                        let dbDate: Date = timestamp.dateValue()
                        let dbMonth = calendar.component(.month, from: dbDate)
                        let dbYear = calendar.component(.year, from: dbDate)
                        let monthName = DateFormatter().monthSymbols[dbMonth - 1]
                        if(dbYear == currentYear)
                        {
                            let keyExists = self.yearMotorValues[monthName] != nil
                            if(keyExists)
                            {
                                self.yearMotorValues[monthName] = (self.yearMotorValues[monthName]!) + (document.get("Score") as! Double)
                                self.dictMonthAvg[monthName]! += 1
                            }
                            else
                            {
                                self.yearMotorValues[monthName] = (document.get("Score") as! Double)
                                self.dictMonthAvg[monthName] = 1
                            }
                        }
                    }
                    var j = 0
                    for i in self.months
                    {
                        let dayExists = self.yearMotorValues[i] != nil
                        if(dayExists)
                        {
                            let data = BarChartDataEntry(x: Double(j),y: Double(self.yearMotorValues[i]!/self.dictMonthAvg[i]!))
                            self.GraphData.append(data)
                        }
                        else{
                            let data = BarChartDataEntry(x: Double(j), y: 0)
                            self.GraphData.append(data)
                        }
                        j += 1
                    }
                    let monthFormat = BarChartFormatter(values: self.months)
                    self.motorYearlyGraph.xAxis.valueFormatter = monthFormat as IAxisValueFormatter
                    let set = BarChartDataSet(values: self.GraphData, label: "Motor Score")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
                    self.motorYearlyGraph.fitBars = true
                    self.motorYearlyGraph.data = chartData
                    self.motorYearlyGraph.setVisibleXRangeMaximum(6)
                    self.motorYearlyGraph.moveViewToX(6)
                }
        }
    }
    
    // MARK: - Helper class for XAxis labeling of medication graph
    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var values : [String]
        required init (values : [String]) {
            self.values = values
            super.init()
        }
        
        // Function: Convert an array of strings to array of ints
        // Input:
        //      1. String array
        // Output:
        //      1. The graph will be shown to the user after this function is completed
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return values[Int(value)]
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
