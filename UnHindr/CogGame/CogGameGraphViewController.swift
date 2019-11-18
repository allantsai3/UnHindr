//File: [CogGameGraphViewController]
//Creators: [Johnston]
//Date created: [11/17/2019]
//Updater name: [Johnston]
//File description: [Reads cognitive data values from fireabse]
//
//  CogGameGraphViewController.swift
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

class CogGameGraphViewController: UIViewController {

    @IBOutlet weak var cogGraph: BarChartView!
    @IBOutlet weak var month: UILabel!
    
    // gets the correct user database values
    let cogRef = Services.db.collection("users").document(Services.userRef!).collection("CogGameData")
    
    // storing the graph data
    var GraphData: [BarChartDataEntry] = []
    var cogData: [Int:Double] = [:]
    var dayAverage = Array(repeating: 0, count: 8)
    var days: [Int] = []
    var stringDays: [String] = []
    
    var dictDayAvg: [Int:Int] = [:]
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getCogData()
        
        // Sets up the chart properties
        self.title = "Cog Bar Chart"
        cogGraph.maxVisibleCount = 40
        cogGraph.drawBarShadowEnabled = false
        cogGraph.drawValueAboveBarEnabled = true
        cogGraph.highlightFullBarEnabled = false
        cogGraph.doubleTapToZoomEnabled = false
        cogGraph.animate(xAxisDuration: 2.0, yAxisDuration: 3.0)
        let leftAxis = cogGraph.leftAxis
        leftAxis.axisMinimum = 0
        cogGraph.rightAxis.enabled = false
        let xAxis = cogGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = cogGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        xAxis.drawGridLinesEnabled = false
    }
    
    // MARK: - Obtain cognitive data from firebase
    // Input:
    //      1. None
    // Output:
    //      1. Cognitive Graph is created using the data from the user in firebase
    func getCogData()
    {
        // gets all the documents for this particular user
        cogRef.getDocuments()
        {
            (querySnapshot,err) in
            // the program will go into this if statement if the user authentication fails
                if err != nil
                {
                        print("Error getting cognitive data")
                }
                else
                {
                    // the program will go into this if the user authentication succeeds
                    // the next three lines recieves the current month
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "LLLL"
                    let nameOfMonth = dateFormatter.string(from: Date())
                    
                    // commented out block from line 90 - 105 is a test for other dates
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
                    
                    // grabs todays date
                    let today = Date()
                    let calendar = Calendar.current
                    // breaks up the date into day month and year components
                    let currentDay = calendar.component(.day, from: today)
                    let currentMonth = calendar.component(.month, from: today)
                    let currentYear = calendar.component(.year, from: today)
                    // calculates 7 days in the past and gets the previous month's name
                    let lastWeekDay = currentDay - 7
                    let previousMonth = currentMonth - 1
                    let previousMonthName = DateFormatter().monthSymbols[previousMonth-1]
                    
                    // checks if the lastWeekDay variable is negative.
                    // If it is negative or 0, that means it needs to get the previous months as well
                    if(lastWeekDay <= 0)
                    {
                        // function that gets how many days are in the last month and puts those days into stringDays and days array
                        self.daysInMonth(inMonth: currentMonth, inYear: currentYear, inDay: lastWeekDay)
                        // displays the previous month and the current month
                        self.month.text = "\(previousMonthName)-\(nameOfMonth)"
                        // iterates through all of the documents for this user
                        for document in querySnapshot!.documents
                        {
                            // gets the date numbers of the timestamp
                            let timestamp: Timestamp = document.get("Date") as! Timestamp
                            let dbDate: Date = timestamp.dateValue()
                            // gets the date of the database value
                            let dbDay = calendar.component(.day, from: dbDate)
                            // checks if dbDay is inside the days array
                            // if dbDay is not inside the days array skip this entire if statement
                            if (self.days.contains(dbDay))
                            {
                                // checks if dbDay is already inside cogData dictionary
                                let keyExists = self.cogData[dbDay] != nil
                                if(keyExists)
                                {
                                    // adds the score found from dbDay into the correct spot in the dictionary
                                    self.cogData[dbDay] = (self.cogData[dbDay]!) + (document.get("Score") as! Double)
                                    // increments the average by one
                                    self.dictDayAvg[dbDay]! += 1
                                }
                                else{
                                    // sets the value of the new dbDay key to equal to the score
                                    self.cogData[dbDay] = (document.get("Score") as! Double)
                                    // sets the average to 1
                                    self.dictDayAvg[dbDay] = 1
                                }
                            }
                        }
                        // while loop is to place the mood values into the bar chart
                        var i = 0
                        while(i < self.days.count)
                        {
                            // checks if a key value of days[i] exists inside the dictionary
                            let dayExists = self.cogData[self.days[i]] != nil
                            if(dayExists)
                            {
                                // places data into the graph data array
                                let data = BarChartDataEntry(x: Double(i), y: (self.cogData[self.days[i]]!)/Double(self.dictDayAvg[self.days[i]]!))
                                self.GraphData.append(data)
                                
                            }
                            else
                            {
                                // if the key value days[i] does not exist, set the value equal to 0 for that day
                                let data = BarChartDataEntry(x: Double(i), y: 0)
                                self.GraphData.append(data)
                            }
                            i += 1
                        }
                        // formats the x values to have the correct values
                        let dayFormat = BarChartFormatter(values: self.stringDays)
                        self.cogGraph.xAxis.valueFormatter = dayFormat as IAxisValueFormatter
                        // formatting the graph
                        let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                        set.colors = [UIColor.green]
                        let chartData = BarChartData(dataSet: set)
                        self.cogGraph.fitBars = true
                        self.cogGraph.data = chartData
                    }
                    else
                    {
                        // if lastweekday is a positive value
                        // sets the month text as the current month
                        self.month.text = "\(nameOfMonth)"
                        for document in querySnapshot!.documents
                        {
                            // grabs the timestamp and gets the date of that timestamp
                            let timestamp: Timestamp = document.get("Date") as! Timestamp
                            let dbDate: Date = timestamp.dateValue()
                            // converts the date into a day
                            let dbDay = calendar.component(.day, from: dbDate)
                            // checks if dbDay is greater than or equal to lastweekday and if dbDay is less than or equal to the currentDay
                            if (dbDay >= lastWeekDay && dbDay <= currentDay)
                            {
                                // checks if dbDay exists in the dictionary already
                                let keyExists = self.cogData[dbDay] != nil
                                if(keyExists)
                                {
                                    // if the key exists add the score from the database on top of the value found in the dictionary
                                    self.cogData[dbDay] = (self.cogData[dbDay]!) + (document.get("Score") as! Double)
                                    // increments the correct value inside the dayAverage array
                                    self.dayAverage[(currentDay-dbDay)] += 1
                                }
                                else{
                                    // if the key does not exist
                                    // make a new key of dbDay with the score value found from the database
                                    self.cogData[dbDay] = (document.get("Score") as! Double)
                                    // increments the correct value inside the dayAverage array
                                    self.dayAverage[(currentDay-dbDay)] += 1
                                }
                            }
                        }
                        // insert the data values into the graphData array
                        for i in lastWeekDay...currentDay
                        {
                            // checks if the that day already exists in the cogData
                            let dayExists = self.cogData[i] != nil
                            if(dayExists)
                            {
                                // inserts the data into the graphData array
                                let data = BarChartDataEntry(x: Double(i), y: (self.cogData[i]!)/Double(self.dayAverage[(currentDay-i)]))
                                self.GraphData.append(data)
                                
                            }
                            else
                            {
                                // inserts the default value of zero for keys that do not exist
                                let data = BarChartDataEntry(x: Double(i), y: 0)
                                self.GraphData.append(data)
                            }
                        }
                    }
                    // formatting the graph
                    let set = BarChartDataSet(values: self.GraphData, label: "Cog Score")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
                    self.cogGraph.fitBars = true
                    self.cogGraph.data = chartData
            }
        }
    }
    
    // MARK: - Create the day and stringDay arrays
    // Input:
    //      1. The month as an int
    //      2. The year as an int
    //      3. The day as an int
    // Output:
    //      1. day array with all the days in the week
    //      2. stringDay array with all the days in the week as a string
    func daysInMonth(inMonth: Int, inYear: Int, inDay: Int)
    {
        // grabs the previous month
        var previousMonth = inMonth-1
        var year = inYear
        var day = inDay
        let forwardDay = inDay
        var i = 1
        // if the previous month was January of that year
        if(previousMonth == 0)
        {
            // sets the previous month to December
            previousMonth = 12
            // gets the previous year
            year = year - 1
        }
        // grabs the date components of the year and the previousMonth
        let dateComponents = DateComponents(year: year, month: previousMonth)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        // counts the number of days for that month and stores the value in numDays
        let range = calendar.range(of: .day, in: .month, for: date)!
        var numDays = range.count
        // appends the day values into the days array on the current month
        while(abs(forwardDay)-i > 0)
        {
            days.append(abs(forwardDay)-i)
            i += 1
        }
        // appends the day values into the days array on the previous month
        while(day <= 0)
        {
            days.append(numDays)
            day += 1
            numDays -= 1
        }
        // takes the days values and reverses the order for stringDays array
        var j = 7
        while(j >= 0)
        {
            stringDays.append(String(days[j]))
            j -= 1
        }
    }
    
    // MARK: - Helper class for XAxis labeling of mood graph
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
