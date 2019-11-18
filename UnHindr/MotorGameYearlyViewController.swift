//File: [MotorGameYearlyViewController]
//Creators: [Johnston]
//Date created: [11/17/2019]
//Updater name: [Johnston]
//File description: [Reads cognitive data values from fireabse]
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
    
    // gets the correct user database values
    let motorRef = Services.db.collection("users").document(Services.userRef!).collection("MotorGameData")
    
    // storing the graph data
    var GraphData: [BarChartDataEntry] = []
    
    var yearMotorValues: [String:Double] = [:]
    var monthAverage = Array(repeating: 0, count: 12)
    var dictMonthAvg: [String:Double] = [:]
    // this array is to set the x axis values as strings
    let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        getMotorData()
        
        // Sets up the chart properties
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
    }
    
    // MARK: - Obtain the yearly motor data from firebase
    // Input:
    //      1. None
    // Output:
    //      1. The yearly motor graph is created and displayed for the user to see
    func getMotorData()
    {
        // gets all the documents for this particular user
        motorRef.getDocuments()
            {
                (querySnapshot, err) in
                if err != nil // the program will go into this if statement if the user authentication fails
                {
                    print("Error getting yearly motor data")
                }
                else
                {
                    // grabs today's date
                    let today = Date()
                    let calendar = Calendar.current
                    // finds the year from today's date
                    let currentYear = calendar.component(.year, from: today)
                    // sets the label to be the currentYear
                    self.yearLabel.text = "\(currentYear)"
                    // iterates through all of the documents for that user
                    for document in querySnapshot!.documents
                    {
                        // creates the timestamp for each document
                        let timestamp: Timestamp = document.get("Time") as! Timestamp
                        // finds the date of that timestamp
                        let dbDate: Date = timestamp.dateValue()
                        // finds the month of that timestamp
                        let dbMonth = calendar.component(.month, from: dbDate)
                        // finds the year of that timestamp
                        let dbYear = calendar.component(.year, from: dbDate)
                        // gets the name of the month from dbMonth
                        let monthName = DateFormatter().monthSymbols[dbMonth - 1]
                        // checks if the database year and the current year match
                        if(dbYear == currentYear)
                        {
                            // checks if the month already exists in the dictionary
                            let keyExists = self.yearMotorValues[monthName] != nil
                            if(keyExists)
                            {
                                // when the key exists, add the score on top of the value that is already in the dictionary
                                self.yearMotorValues[monthName] = (self.yearMotorValues[monthName]!) + (document.get("Score") as! Double)
                                // increment the average for that month
                                self.dictMonthAvg[monthName]! += 1
                            }
                            else
                            {
                                // creates the new key with the score from the database as its value
                                self.yearMotorValues[monthName] = (document.get("Score") as! Double)
                                // sets the average as 1
                                self.dictMonthAvg[monthName] = 1
                            }
                        }
                    }
                    var j = 0
                    // iterates through all the months to insert it into the graphdata array
                    for i in self.months
                    {
                        // checks if that month exists inside the dictionary
                        let dayExists = self.yearMotorValues[i] != nil
                        if(dayExists)
                        {
                            // sets the data value as the average from yearMotorValues[i] and dictMonthAvg[i] and appends the data to the GraphData array
                            let data = BarChartDataEntry(x: Double(j),y: Double(self.yearMotorValues[i]!/self.dictMonthAvg[i]!))
                            self.GraphData.append(data)
                        }
                        else{
                            // sets the data value as 0 since the key does not exist
                            let data = BarChartDataEntry(x: Double(j), y: 0)
                            self.GraphData.append(data)
                        }
                        j += 1
                    }
                    // calls on the helper function to set the x axis values as strings
                    let monthFormat = BarChartFormatter(values: self.months)
                    self.motorYearlyGraph.xAxis.valueFormatter = monthFormat as IAxisValueFormatter
                    // finalize any other chart properties
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
