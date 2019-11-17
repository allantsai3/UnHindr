//File: [ChartsViewController]
//Creators: [Johnston]
//Date created: [11/10/2019]
//Updater name: [Johnston]
//File description: [Reads values from the data]
//
//
//  MonthmonthGraphViewController.swift
//
//
//  Created by Johnston Yang on 11/10/19.
//

import UIKit
import Foundation
import Charts
import FirebaseFirestore
import FirebaseAuth

class MonthMoodGraphViewController: UIViewController {

    @IBOutlet weak var monthGraph: BarChartView!
    @IBOutlet weak var monthName: UILabel!
    
    
    let moodRef = Services.db.collection("users").document(Services.userRef!).collection("Mood")
    var GraphData: [BarChartDataEntry] = []
    var dayofMonth: [String] = []
    
    var monthMoodValues: [Int:Double] = [:]
    var dayAverage = Array(repeating: 0, count: 31)
    var dictDayAvg: [Int:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoodData()
        self.title = "Stacked Bar Chart"
        monthGraph.maxVisibleCount = 40
        monthGraph.drawBarShadowEnabled = false
        monthGraph.drawValueAboveBarEnabled = true
        monthGraph.highlightFullBarEnabled = false
        monthGraph.doubleTapToZoomEnabled = false
        let leftAxis = monthGraph.leftAxis
        leftAxis.axisMinimum = 0
        monthGraph.rightAxis.enabled = false
        let xAxis = monthGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = monthGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        monthGraph.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
        xAxis.drawGridLinesEnabled = false
        // Do any additional setup after loading the view.
        //monthGraph.set
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
                    let today = Date()
                    let calendar = Calendar.current
                    let currentMonth = calendar.component(.month, from: today)
                    let currentMonthName = DateFormatter().monthSymbols[currentMonth-1]
                    self.monthName.text = "\(currentMonthName)"
                    
                    for document in querySnapshot!.documents
                    {
                        let timestamp: Timestamp = document.get("Date") as! Timestamp
                        let dbDate: Date = timestamp.dateValue()
                        let dbMonth = calendar.component(.month, from: dbDate)
                        let dbDay = calendar.component(.month, from: dbDate)
                        if(dbMonth == currentMonth)
                        {
                            // checks if dbDay is already inside weekMoodValues dictionary
                            let keyExists = self.monthMoodValues[dbDay] != nil
                            if(keyExists)
                            {
                                // adds the score found from dbDay into the correct spot in the dictionary
                                self.monthMoodValues[dbDay] = (self.monthMoodValues[dbDay]!) + (document.get("Score") as! Double)
                                // increments the average by one
                                self.dictDayAvg[dbDay]! += 1
                            }
                            else{
                                // sets the value of the new dbDay key to equal to the score
                                self.monthMoodValues[dbDay] = (document.get("Score") as! Double)
                                // sets the average to 1
                                self.dictDayAvg[dbDay] = 1
                            }
                        }
                    }
                    // counts the number of days for that month and stores the value in numDays
                    let range = calendar.range(of: .day, in: .month, for: today)!
                    let numDays = range.count
                    var i = 0
                    while (i < numDays)
                    {
                        let dayExists = self.monthMoodValues[i] != nil
                        if(dayExists)
                        {
                            let data = BarChartDataEntry(x: Double(i), y: (self.monthMoodValues[i]!)/Double(self.dictDayAvg[i]!))
                            self.GraphData.append(data)
                        }
                        else{
                            let data = BarChartDataEntry(x: Double(i), y: 0)
                            self.GraphData.append(data)
                        }
                        i += 1
                    }
                    let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
                    self.monthGraph.fitBars = true
                    self.monthGraph.data = chartData
                    self.monthGraph.setVisibleXRangeMaximum(10)
                    self.monthGraph.moveViewToX(21)
                }
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


