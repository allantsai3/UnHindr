//
//  CogGameMonthlyViewController.swift
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

class CogGameMonthlyViewController: UIViewController {

    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var cogMonthGraph: BarChartView!
    
    let cogRef = Services.db.collection("users").document(Services.userRef!).collection("CogGameData")
    
    var GraphData: [BarChartDataEntry] = []
    
    var monthMoodValues: [Int:Double] = [:]
    var dayAverage = Array(repeating: 0, count: 31)
    var dictDayAvg: [Int:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCogGameData()
        
        self.title = "Bar Chart"
        cogMonthGraph.maxVisibleCount = 40
        cogMonthGraph.drawBarShadowEnabled = false
        cogMonthGraph.drawValueAboveBarEnabled = true
        cogMonthGraph.highlightFullBarEnabled = false
        cogMonthGraph.doubleTapToZoomEnabled = false
        let leftAxis = cogMonthGraph.leftAxis
        leftAxis.axisMinimum = 0
        cogMonthGraph.rightAxis.enabled = false
        let xAxis = cogMonthGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = cogMonthGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        cogMonthGraph.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
        xAxis.drawGridLinesEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func getCogGameData()
    {
        cogRef.getDocuments()
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
                    self.month.text = "\(currentMonthName)"
                    
                    for document in querySnapshot!.documents
                    {
                        let timestamp: Timestamp = document.get("Date") as! Timestamp
                        let dbDate: Date = timestamp.dateValue()
                        let dbMonth = calendar.component(.month, from: dbDate)
                        let dbDay = calendar.component(.day, from: dbDate)
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
                    print(numDays)
                    var i = 1
                    while (i <= numDays)
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
                    self.cogMonthGraph.fitBars = true
                    self.cogMonthGraph.data = chartData
                    self.cogMonthGraph.setVisibleXRangeMaximum(7)
                    self.cogMonthGraph.moveViewToX(Double(numDays-7))
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
