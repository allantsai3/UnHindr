//
//  MotorGameMonthlyViewController.swift
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

class MotorGameMonthlyViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var motorMonthGraph: BarChartView!
    
    let motorRef = Services.db.collection("users").document(Services.userRef!).collection("MotorGameData")
    
    var GraphData: [BarChartDataEntry] = []
    
    var monthMotorValues: [Int:Double] = [:]
    var dayAverage = Array(repeating: 0, count: 31)
    var dictDayAvg: [Int:Int] = [:]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getMotorGameData()
        
        self.title = "Bar Chart"
        motorMonthGraph.maxVisibleCount = 40
        motorMonthGraph.drawBarShadowEnabled = false
        motorMonthGraph.drawValueAboveBarEnabled = true
        motorMonthGraph.highlightFullBarEnabled = false
        motorMonthGraph.doubleTapToZoomEnabled = false
        let leftAxis = motorMonthGraph.leftAxis
        leftAxis.axisMinimum = 0
        motorMonthGraph.rightAxis.enabled = false
        let xAxis = motorMonthGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = motorMonthGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        motorMonthGraph.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
        xAxis.drawGridLinesEnabled = false
        // Do any additional setup after loading the view.
    }
    
    
    func getMotorGameData()
    {
        motorRef.getDocuments()
            {
                (querySnapshot,err) in
                if err != nil{
                    print("Error getting monthly cognitive game data")
                }
                else
                {
                    // testing other months
                    //                    let otherdate = DateFormatter()
                    //                    otherdate.dateFormat = "yyyy/MM/dd HH:mm"
                    //                    let someDateTime = otherdate.date(from: "2019/10/3 22:31")
                    //                    let currentMonth = 10
                    let today = Date()
                    let calendar = Calendar.current
                    let currentMonth = calendar.component(.month, from: today)
                    let currentMonthName = DateFormatter().monthSymbols[currentMonth-1]
                    let currentYear = calendar.component(.year, from: today)
                    self.monthLabel.text = "\(currentMonthName)"
                    
                    for document in querySnapshot!.documents
                    {
                        let timestamp: Timestamp = document.get("Time") as! Timestamp
                        let dbDate: Date = timestamp.dateValue()
                        let dbMonth = calendar.component(.month, from: dbDate)
                        let dbDay = calendar.component(.day, from: dbDate)
                        if(dbMonth == currentMonth)
                        {
                            // checks if dbDay is already inside weekMoodValues dictionary
                            let keyExists = self.monthMotorValues[dbDay] != nil
                            if(keyExists)
                            {
                                // adds the score found from dbDay into the correct spot in the dictionary
                                self.monthMotorValues[dbDay] = (self.monthMotorValues[dbDay]!) + (document.get("Score") as! Double)
                                // increments the average by one
                                self.dictDayAvg[dbDay]! += 1
                            }
                            else{
                                // sets the value of the new dbDay key to equal to the score
                                self.monthMotorValues[dbDay] = (document.get("Score") as! Double)
                                // sets the average to 1
                                self.dictDayAvg[dbDay] = 1
                            }
                        }
                    }
                    // counts the number of days for that month and stores the value in numDays
                    let range = calendar.range(of: .day, in: .month, for: today)!
                    let numDays = range.count
                    print(numDays)
                    var i = 1
                    while (i <= numDays)
                    {
                        let dayExists = self.monthMotorValues[i] != nil
                        if(dayExists)
                        {
                            let data = BarChartDataEntry(x: Double(i), y: (self.monthMotorValues[i]!)/Double(self.dictDayAvg[i]!))
                            self.GraphData.append(data)
                        }
                        else{
                            let data = BarChartDataEntry(x: Double(i), y: 0)
                            self.GraphData.append(data)
                        }
                        i += 1
                    }
                    let set = BarChartDataSet(values: self.GraphData, label: "Motor Score")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
                    self.motorMonthGraph.fitBars = true
                    self.motorMonthGraph.data = chartData
                    self.motorMonthGraph.setVisibleXRangeMaximum(7)
                    self.motorMonthGraph.moveViewToX(Double(numDays-7))
                    //self.cogMonthGraph.xAxis.setLabelCount(numDays, force: true)
                }
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
