//
//  MoodGraphsViewController.swift
//  UnHindr
//
//  Created by Johnston Yang on 11/10/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import Foundation
import Charts
import FirebaseFirestore
import FirebaseAuth

class MoodGraphsViewController: UIViewController {
    
    let moodRef = Services.db.collection("users").document(Services.userRef!).collection("Mood")
    
    @IBOutlet weak var moodChart: BarChartView!
    @IBOutlet weak var month: UILabel!
    
    
    var GraphData: [BarChartDataEntry] = []
    var moodData: [String:Double] = [:]

    var weekMoodValues: [Int:Double] = [:]
    var dayAverage = Array(repeating: 0, count: 8)
    var days: [Int] = []
    var stringDays: [String] = []
    
    var dictDayAvg: [Int:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoodData()
        //Sets up the chart properties
        self.title = "Stacked Bar Chart"
        moodChart.maxVisibleCount = 40
        moodChart.drawBarShadowEnabled = false
        moodChart.drawValueAboveBarEnabled = true
        moodChart.highlightFullBarEnabled = false
        moodChart.doubleTapToZoomEnabled = false
        moodChart.animate(xAxisDuration: 2.0, yAxisDuration: 3.0)
        let leftAxis = moodChart.leftAxis
        leftAxis.axisMinimum = 0
        moodChart.rightAxis.enabled = false
        let xAxis = moodChart.xAxis
        xAxis.labelPosition = .bottom
        let l = moodChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        xAxis.drawGridLinesEnabled = false
        // Do any additional setup after loading the view.
        
    }
    
    func getMoodData()
    {
        moodRef.getDocuments()
        {
            (querySnapshot, err) in
            if err != nil // the program will go into this if statement if the user authentication fails
            {
                print("Error getting medication data")
            }
            else
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "LLLL"
                let nameOfMonth = dateFormatter.string(from: Date())
                
                
                // other dates
                //let otherdate = DateFormatter()
                //otherdate.dateFormat = "yyyy/MM/dd HH:mm"
                //let someDateTime = otherdate.date(from: "2019/11/3 22:31")
                //let calendar = Calendar.current
                
                //let currentDay = calendar.component(.day, from: someDateTime!)
                //let currentMonth = calendar.component(.month, from: someDateTime!)
                //var previousMonth = currentMonth - 1
                //let previousMonthName = DateFormatter().monthSymbols[previousMonth-1]
                //let currentYear = calendar.component(.year, from: someDateTime!)
                //let lastWeekDay = currentDay - 7


                //for todays date
                let today = Date()
                let calendar = Calendar.current
                
                let currentDay = calendar.component(.day, from: today)
                let currentMonth = calendar.component(.month, from: today)
                let currentYear = calendar.component(.year, from: today)
                let lastWeekDay = currentDay - 7
                
                var previousMonth = currentMonth - 1
                let previousMonthName = DateFormatter().monthSymbols[previousMonth-1]

                
                if(lastWeekDay <= 0)
                {
                    
                    self.daysInMonth(inMonth: currentMonth, inYear: currentYear, inDay: lastWeekDay)
                    self.month.text = "\(previousMonthName)-\(nameOfMonth)"
                    
                    for document in querySnapshot!.documents
                    {
                        let timestamp: Timestamp = document.get("Date") as! Timestamp
                        let dbDate: Date = timestamp.dateValue()
                        
                        let dbDay = calendar.component(.day, from: dbDate)
                        
                        if (self.days.contains(dbDay))
                        {
                            let keyExists = self.weekMoodValues[dbDay] != nil
                            if(keyExists)
                            {
                                self.weekMoodValues[dbDay] = (self.weekMoodValues[dbDay]!) + (document.get("Score") as! Double)
                                self.dictDayAvg[dbDay]! += 1
                            }
                            else{
                                self.weekMoodValues[dbDay] = (document.get("Score") as! Double)
                                self.dictDayAvg[dbDay] = 1
                            }
                        }
                    }
                    var i = 0
                    while(i < self.days.count)
                    {
                        let dayExists = self.weekMoodValues[self.days[i]] != nil
                        print(dayExists)
                        print(self.days[i])
                        if(dayExists)
                        {
                            let data = BarChartDataEntry(x: Double(i), y: (self.weekMoodValues[self.days[i]]!)/Double(self.dictDayAvg[self.days[i]]!))
                            self.GraphData.append(data)
                            
                        }
                        else
                        {
                            let data = BarChartDataEntry(x: Double(i), y: 0)
                            self.GraphData.append(data)
                        }
                        i += 1
                    }
                    let dayFormat = BarChartFormatter(values: self.stringDays)
                    self.moodChart.xAxis.valueFormatter = dayFormat as IAxisValueFormatter
                    let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
                    self.moodChart.fitBars = true
                    self.moodChart.data = chartData
                }
                else
                {
                //for todays date
                //let today = Date()
                //let calendar = Calendar.current

                //let currentDay = calendar.component(.day, from: today)
                //let lastWeekDay = currentDay - 7
                self.month.text = "\(nameOfMonth)"
                for document in querySnapshot!.documents
                {
                    let timestamp: Timestamp = document.get("Date") as! Timestamp
                    let dbDate: Date = timestamp.dateValue()

                    let dbDay = calendar.component(.day, from: dbDate)

                    if (dbDay >= lastWeekDay && dbDay <= currentDay)
                    {
                        let keyExists = self.weekMoodValues[dbDay] != nil
                        if(keyExists)
                        {
                            self.weekMoodValues[dbDay] = (self.weekMoodValues[dbDay]!) + (document.get("Score") as! Double)
                            self.dayAverage[(currentDay-dbDay)] += 1
                            
                        }
                        else{
                            self.weekMoodValues[dbDay] = (document.get("Score") as! Double)
                            self.dayAverage[(currentDay-dbDay)] += 1
                            
                        }
                    }
                }
                for i in lastWeekDay...currentDay
                {
                    let dayExists = self.weekMoodValues[i] != nil
                    if(dayExists)
                    {
                        let data = BarChartDataEntry(x: Double(i), y: (self.weekMoodValues[i]!)/Double(self.dayAverage[(currentDay-i)]))
                        self.GraphData.append(data)
                        
                    }
                    else
                    {
                        let data = BarChartDataEntry(x: Double(i), y: 0)
                        self.GraphData.append(data)
                    }
                }
            }
                let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                set.colors = [UIColor.green]
                let chartData = BarChartData(dataSet: set)
                self.moodChart.fitBars = true
                self.moodChart.data = chartData
            }

        }
    }
    
    func daysInMonth(inMonth: Int, inYear: Int, inDay: Int)
    {
        var previousMonth = inMonth-1
        var year = inYear
        var day = inDay
        let forwardDay = inDay
        var i = 1
        if(previousMonth == 0) // if the previous month was january of that year
        {
            previousMonth = 12
            year = year - 1 // gets previous year
        }
        let dateComponents = DateComponents(year: inYear, month: inMonth-1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        var numDays = range.count
        while(abs(forwardDay)-i > 0)
        {
            days.append(abs(forwardDay)-i)
            i += 1
        }
        while(day <= 0)
        {
            days.append(numDays)
            day += 1
            numDays -= 1
        }
        var j = 7
        while(j >= 0)
        {
            stringDays.append(String(days[j]))
            j -= 1
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
