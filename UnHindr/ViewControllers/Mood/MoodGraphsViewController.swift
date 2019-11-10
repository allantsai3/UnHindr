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
    
    
//    @IBOutlet weak var moodChart: BarChartView!
    @IBOutlet weak var moodChart: BarChartView!
    @IBOutlet weak var average: UILabel!
    
    var GraphData: [BarChartDataEntry] = []
    
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
        Services.db.collection("users").document(Services.userRef!).collection("Mood").getDocuments()
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
//                    dump(self.GraphData)
                    //print(document.get("Score"))
                    //print(document.get("Date"))
                }
                let set = BarChartDataSet(values: self.GraphData, label: "Mood")
                set.colors = [UIColor.green]
                let chartData = BarChartData(dataSet: set)
                self.moodChart.fitBars = true
                self.moodChart.data = chartData
            }

        }
        
        //        (querySnapshot, err) in
//        if err != nil // the program will go into this if statement if the user authentication fails
//        {
//            print("Error getting medication data")
//        }
//        else
//        {
//            print("Nice")
//        }
//        var dataEntries: [BarChartDataEntry] = []
//        for i in 0..<20 {
//            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(2*i))
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Nice")
//        let chartData = BarChartData(dataSet: chartDataSet)
//        moodChart.data = chartData
        //Services.userRef! gets the user ref
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
