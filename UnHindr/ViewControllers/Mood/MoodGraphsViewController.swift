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
    @IBOutlet weak var average: UILabel!
    
    var GraphData: [BarChartDataEntry] = []
    var moodData: [String:Double] = [:]
    
    let dayOfWeek: [String] = ["MON","TUES","WED","THURS","FRI","SAT","SUN"]
    //var moodDayValues: []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoodData()
        //Sets up the chart properties
        self.title = "Stacked Bar Chart"
        moodChart.maxVisibleCount = 40
        moodChart.drawBarShadowEnabled = false
        moodChart.drawValueAboveBarEnabled = false
        moodChart.highlightFullBarEnabled = false
        moodChart.doubleTapToZoomEnabled = false
        moodChart.animate(xAxisDuration: 2.0, yAxisDuration: 4.0)
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
                var i: Double = 0;
                var total: Double = 0;
                print("Why hello there")
                for document in querySnapshot!.documents
                {
                    if(i < 6)
                    {
                        let data = BarChartDataEntry(x: Double(i), y: document.get("Score") as! Double)
                        self.GraphData.append(data)
                        total += document.get("Score") as! Double
                        i += 1
                    }
                    let avg = total/i
                    self.average.text = "\((avg.rounded()))"

                }
                
                let dayFormat = BarChartFormatter(values: self.dayOfWeek)
                self.moodChart.xAxis.valueFormatter = dayFormat as IAxisValueFormatter
                let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                set.colors = [UIColor.green]
                let chartData = BarChartData(dataSet: set)
                self.moodChart.fitBars = true
                self.moodChart.data = chartData
            }

        }
        //Services.userRef! gets the user ref
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
