//
//  YearMoodGraphViewController.swift
//  UnHindr
//
//  Created by Johnston Yang on 11/10/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import Charts

class YearMoodGraphViewController: UIViewController {

    let moodRef = Services.db.collection("users").document(Services.userRef!).collection("Mood")
    var GraphData: [BarChartDataEntry] = []
    
    @IBOutlet weak var yearGraph: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoodData()
        self.title = "Stacked Bar Chart"
        yearGraph.maxVisibleCount = 40
        yearGraph.drawBarShadowEnabled = false
        yearGraph.drawValueAboveBarEnabled = false
        yearGraph.highlightFullBarEnabled = false
        yearGraph.doubleTapToZoomEnabled = false
        yearGraph.animate(xAxisDuration: 2.0, yAxisDuration: 4.0)
        let leftAxis = yearGraph.leftAxis
        leftAxis.axisMinimum = 0
        yearGraph.rightAxis.enabled = false
        let xAxis = yearGraph.xAxis
        xAxis.labelPosition = .bottom
        let l = yearGraph.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
        yearGraph.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
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
                    var i: Double = 0
                    var total: Double = 0
                    var data: Double = 0
                    print("Why hello there")
                    for document in querySnapshot!.documents
                    {
                        if(i <= 365)
                        {
                            data = data + (document.get("Score") as! Double)
                            //                            print(data)
                            if(i == 30 || i == 60 || i == 90 || i == 120)
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
                    self.yearGraph.fitBars = true
                    self.yearGraph.data = chartData
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
