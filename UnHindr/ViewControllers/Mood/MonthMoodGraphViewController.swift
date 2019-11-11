//
//  MonthmonthGraphViewController.swift
//  UnHindr
//
//  Created by Johnston Yang on 11/10/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import Charts


class MonthMoodGraphViewController: UIViewController {

    @IBOutlet weak var monthGraph: BarChartView!
    
    let moodRef = Services.db.collection("users").document(Services.userRef!).collection("Mood")
    var GraphData: [BarChartDataEntry] = []
    var dayofMonth: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoodData()
        self.title = "Stacked Bar Chart"
        monthGraph.maxVisibleCount = 40
        monthGraph.drawBarShadowEnabled = false
        monthGraph.drawValueAboveBarEnabled = false
        monthGraph.highlightFullBarEnabled = false
        monthGraph.doubleTapToZoomEnabled = false
        monthGraph.animate(xAxisDuration: 2.0, yAxisDuration: 4.0)
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
        // Do any additional setup after loading the view.
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
                    var i: Double = 0
                    var total: Double = 0
                    var data: Double = 0
                    print("Why hello there")
                    for document in querySnapshot!.documents
                    {
                        if(i <= 28)
                        {
                            data = data + (document.get("Score") as! Double)
//                            print(data)
                            if(i == 7 || i == 14 || i == 21 || i == 28)
                            {
                                print(i)
                                let inputdata = BarChartDataEntry(x: Double(i/7), y: data/7)
                                self.GraphData.append(inputdata)
                                data = 0
                                
                            }
//                            self.GraphData.append(inputdata)
//                            self.dayofMonth.append("November \(i)")
//                            total += document.get("Score") as! Double
                            i += 1
                        }
//                        let avg = total/i
//                        self.average.text = "\((avg.rounded()))"
                    }
                    
//                    let dayFormat = BarChartFormatter(values: self.dayofMonth)
//                    self.monthGraph.xAxis.valueFormatter = dayFormat as IAxisValueFormatter
                    let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                    set.colors = [UIColor.green]
                    let chartData = BarChartData(dataSet: set)
//                    dump(self.GraphData)
                    self.monthGraph.fitBars = true
                    self.monthGraph.data = chartData
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
