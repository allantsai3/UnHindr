//File: [ChartsViewController]
//Creators: [Allan, Johnston]
//Date created: [29/10/2019]
//Updater name: [Johnston]
//File description: [Reads values from the data]
//
//
//  ChartsViewController.swift
//  
//
//  Created by Johnston Yang on 10/29/19.
//

import Foundation
import UIKit
import Charts
import FirebaseFirestore
import FirebaseAuth

class ChartsViewController: UIViewController {
    // Handle for auth state changes
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    
    //Outlet for displaying chart
    @IBOutlet weak var chtChart: BarChartView!
    
    //Formatting the values of the chart
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.negativeSuffix = ""
        formatter.positiveSuffix = ""
        
        return formatter
    }()
    var MedTaken: [Double] = []
    var DateTaken: [Date] = []
    var medDayPlan: [String] = []
    var GraphData: [BarChartDataEntry] = []
    let dayOfWeek: [String] = ["MON","TUES","WED","THURS","FRI","SAT","SUN"]
    
    var dictMedTaken: [String:[Double]] = [:]
    var dictDateTaken: [String:[Date]] = [:]
    var dictDayPlan: [String:[String]] = [:]
    var dictDidTakeMed: [String:[Bool]] = [:]
    var dictMedToTake: [String:Double] = [:]

    
    var documents: [DocumentSnapshot] = []
    
    // MARK: - View controller lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        // user authentication
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        Auth.auth().removeStateDidChangeListener(handle!)
        self.MedTaken.removeAll()
        self.DateTaken.removeAll()
        self.medDayPlan.removeAll()
        self.GraphData.removeAll()
        self.dictMedTaken.removeAll()
        self.dictDateTaken.removeAll()
        self.dictDidTakeMed.removeAll()
        self.dictDayPlan.removeAll()
        self.documents.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                Services.getDBUserRef(user, completionHandler: { (result) in
                    guard let result = result else {
                        print("Failed to fetch ref")
                        return
                    }
                    //grabs medication data from the database
                    self.getDBMedicationData(result, completionHandler: { (count) in
                        guard count != nil else {
                            print("Unable to fetch med data")
                            return
                        }
                        //grab medication plan from the database
                        self.getDBMedicationPlan(result, completionHandler: { (count) in
                            guard count != nil else {
                                print("Unable to fetch med data")
                                return
                            }
                            // compares the day between the the day the user has taken to the days they are suppose to take it
                            self.compareDate(dateTaken: self.dictDateTaken,dayPlan: self.dictDayPlan)
                            // begins plotting the data to the stacked bar chart
                            self.setChartData(medAmount: self.dictMedTaken,dayPlan: self.dictDayPlan,userTaken: self.dictDidTakeMed, allMedToTake: self.dictMedToTake)
                        })
                    })
                })
            }
            
        }
        // Setting up the stacked bar chart properties
        self.title = "Stacked Bar Chart"
        chtChart.maxVisibleCount = 40
        chtChart.drawBarShadowEnabled = false
        chtChart.drawValueAboveBarEnabled = false
        chtChart.highlightFullBarEnabled = false
        chtChart.doubleTapToZoomEnabled = false
        chtChart.animate(xAxisDuration: 3.0, yAxisDuration: 3.0)
        let leftAxis = chtChart.leftAxis
        leftAxis.axisMinimum = 0
        chtChart.rightAxis.enabled = false
        let xAxis = chtChart.xAxis
        xAxis.labelPosition = .bottom
        let l = chtChart.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formToTextSpace = 8
        l.xEntrySpace = 6
    }
    // MARK: - Obtain medication data
    // Input:
    //      1. Document ID of unique user
    // Output:
    //      1. Places medication taken by the user into the dictionary 'dictMedTaken'
    //      2. The date and time of the user taking the medication is placed into the dictionary 'dictDateTaken'
    private func getDBMedicationData(_ userdoc: String, completionHandler: @escaping (_ result: Int?) -> Void)
    {
        //Obtain all the documents of the user under the 'Medication' collection
        Services.db.collection("users").document(userdoc).collection("Medication")
            .getDocuments()
        {
                (querySnapshot, err) in
                if err != nil // the program will go into this if statement if the user authentication fails
                {
                    print("Error getting medication data")
                }
                else
                { // the program will go into this else statment if the user authentication is successful
                    var i = 0
                    // the for loop will go through each doucment and look at the data that is inside each document
                    for document in querySnapshot!.documents
                    {
                        self.MedTaken.removeAll() // removes all data that is already inside the array 'MedTaken'
                        self.DateTaken.removeAll() // removes all data that is already inside the array 'DateTaken'
                        let med = document.get("Medication") as! String
                        let quantity = document.get("Quantity")
                        self.MedTaken.append(quantity as! Double)
                        if let timestamp = document.get("Date") as? Timestamp
                        {
                            let date = timestamp.dateValue()
                            self.DateTaken.append(date)
                        }
                        i += 1
                        let keyExists = self.dictMedTaken[med] != nil // checks if that particular key exists in the dictionary 'MedTaken'
                        if(keyExists)
                        { // the key already exists in the dictionary
                            if var arr = self.dictMedTaken[med] // arr gets the current values inside 'dictMedTaken' with a certain key value 'med'
                            {
                                for count in 0..<(arr.count)
                                {
                                    arr.append(self.MedTaken[0]) // the new medication is appended to the arr array
                                }
                                self.dictMedTaken[med] = arr // the modified arr is the new value of 'dictMedTaken[med]'
                            }
                            if var arr = self.dictDateTaken[med] // arr gets the current values inside 'dictDateTaken' with a certain key value 'med'
                            {
                                arr.append(self.DateTaken[0]) // the new date is appended to the arr array
                                self.dictDateTaken[med] = arr // the modified arr is the new value of 'dictDateTaken[med]'
                            }
                        }
                        else
                        { // the key does not exist in the dictionary
                            self.dictMedTaken[med] = self.MedTaken // add the new medication to the dictMedTaken
                            self.dictDateTaken[med] = self.DateTaken // add the new medication to the dictDateTaken
                        }
                    }
                    completionHandler(i) // this function allows getDBMedicationData to return properly once the for loop is completed
                }
        } //end of getDBMedicationData function
    }
    
    // MARK: - Obtain medication plan of each user
    // Input:
    //      1. Document ID of unique user
    // Output:
    //      1. Places medication taken by the user into dictionary 'dictMedToTake'
    //      2. The date and time the medication was taken is put into dictionary 'dictDayPlan'
private func getDBMedicationPlan(_ userdoc: String, completionHandler: @escaping (_ result: Int?) -> Void)
{
    //Obtain all user documents that is under the 'MedicationPlan' collection
    Services.db.collection("users").document(userdoc).collection("MedicationPlan")
        .getDocuments()
    {
        (querySnapshot, err) in
        if err != nil
        { // the program will go into this if statement if the user authentication fails
            print("Error getting medication data")
        }
        else
        { // the program will go into this else statement if the user authentication is successful
            var i = 0
            var tmpDayArray: [String] = [] // array is used to append any values into the 'dictDayPlan' for a certain medication
            // goes through each document and retrieves the data  for each document
            for document in querySnapshot!.documents
            {
                // removes any data that is inside 'tmpDayArray'
                tmpDayArray.removeAll()
                i += 1
                let med = document.get("Medication") as! String // obtains the medication that the user has to take
                let dayArray = document.data()["Day"] as! [String] // obtains the days the user has to take that medication
                let quantity = document.get("Quantity") as! Double // obtains the length of the 'dayArray'
                self.dictMedToTake[med] = quantity // grabs how many of that medication the user is suppose to take
                let lengthDayArray = dayArray.count // finding the length of the day array
                for count in 0..<lengthDayArray
                {
                    let date = dayArray[count] // puts 'dayArray[count]' into the date variable
                    tmpDayArray.append(date) //date variable is appended to the 'tmpDayArray'
                }
                let keyExists = self.dictDayPlan[med] != nil // grabs a boolean to see if the key 'dictDayPlan[med]' already exists
                if(keyExists)
                { // the key already exists in the dictionary
                    if var arr = self.dictDayPlan[med] // arr gets the current values inside 'dictDayPlan' with a certain key value 'med'
                    {
                        for count in 0..<(arr.count)
                        {
                            arr.append(self.medDayPlan[count]) // appends the new 'medDayPlan[count]' to the arr variable
                        }
                        self.dictDayPlan[med] = arr // places the modified array into the 'dictDayPlan' after adding a new Day
                    }
                }
                else
                { // the key does not exist in the dictionary
                    self.dictDayPlan[med] = tmpDayArray // adds a new dictionary value for the medication and the days they are suppose to be taken
                }
            }
            completionHandler(i) // this function allows getDBMedicationPlan to return properly once the for loop is completed
        }
    }
}
    // MARK: - Compare the dates between the user taking the medication and the day the user is suppose to be taking the medication
    //       - This checks whether or not the user has missed any of their medications
    //
    // Input:
    //      1. A dictionary dateTaken [String:[Date]]. This is used to see what medication the user has taken and at what day they have taken the medication
    //      2. A dictionary dayPlan [String:[String]]. This is used to compare with the day from dayPlan
    //         to the day from dateTaken to see if the user has taken the medication on time.
    // Output:
    //      1. Places medication taken by the user into dictionary 'dictMedToTake'. The dictionary value contains a boolean array.
    //         The indexes represent a day of the week.
    //         For example, index 0 is Monday, index 1 is Tuesday, index 2 is Wednesday, etc.
    private func compareDate(dateTaken: [String:[Date]],dayPlan: [String:[String]])
    {
        // creates a boolean array with size 7 with all initialized values set as false that will be manipulated depending on
        // what the user's medication plan and what medication they have taken
        let takeMedCorrectDay = [Bool](repeating: false, count: 7)
        // iterates through the user's medication consumption
        for (takenMed,_) in dateTaken
        {
            dictDidTakeMed[takenMed] = takeMedCorrectDay // adds the boolean array 'takeMedCorrectDay' for each medication the user has taken
            // converts all dates to a day of the week inside the for loop
            for count in 0..<dateTaken[takenMed]!.count
            {// converts timestamp to a day of the week
                let date = dateTaken[takenMed]![count] // grabs each timestamp in the medication
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE" // formats the date into a day of the week
                let currentDateString: String = dateFormatter.string(from: date) // currentDateString is storing the day of the week
                // iterates through the entire medication plan and compares the currentDateString to the dayplan
                for count in 0..<dayPlan[takenMed]!.count
                {
                    // check if the i-th value in the array of dayPlan matchces with the currentDateString
                        if(dayPlan[takenMed]![count] == currentDateString)
                        {
                            // arr variable gets the boolean array of 'dictDidTakeMed'
                            if var arr = dictDidTakeMed[takenMed]
                            {
                                // each if statement will be compar currentDateString to a day
                                // if the currentDateString matches with a day the array position will be updated to have a boolean true value
                                if(currentDateString == "Monday")
                                {
                                    arr[0] = true
                                }
                                else if (currentDateString == "Tuesday")
                                {
                                    arr[1] = true
                                }
                                else if (currentDateString == "Wednesday")
                                {
                                    arr[2] = true
                                }
                                else if (currentDateString == "Thursday")
                                {
                                    arr[3] = true
                                }
                                else if (currentDateString == "Friday")
                                {
                                    arr[4] = true
                                }
                                else if (currentDateString == "Saturday")
                                {
                                    arr[5] = true
                                }
                                else if (currentDateString == "Sunday")
                                {
                                    arr[6] = true
                                }
                                // after the if statement the arr array which contains all the boolean values for that medication will be added to the dictionary
                                dictDidTakeMed[takenMed] = arr
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Uses the data from the previous functions and creates the stacked bar chart.
    //       - Some of the graph settings has been set in this function such as the color of the bars, the legend, and what values to put into the graph
    // Input:
    //      1. The medAmount dictionary which is of type [String:[Double]]
    //      2. The dayPlan dictionary which is of type [String:[String]]
    //      3. The allMedToTake dictionary which is of type [String:Double]
    // Output:
    //      1. The graph will be shown to the user after this function is completed
    private func setChartData(medAmount: [String:[Double]],dayPlan: [String:[String]],userTaken: [String:[Bool]], allMedToTake: [String:Double])
    {
        // This days array contains all the days of the week
//        let days: [String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        //
//        let daysize = days.count
        for (Med,_) in dayPlan
        {
            for i in 0..<dayPlan[Med]!.count
            {
                let keyExists = self.dictMedTaken[Med] != nil // checks if the key exists inside the dictionary 'dictMedTaken'
                var Taken: Double = 0
                var Missed: Double = 0
                if(keyExists)
                { // if the exists in the dictionary
                let date: String = dayPlan[Med]![i] //days of the medication plan
                if(date == "Monday") //compare medication plan day to each day of the week
                {
                    if(userTaken[Med]![0] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else //didnt take medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Tuesday")
                {
                    if(userTaken[Med]![1] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else //didnt take medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Wednesday")
                {
                    if(userTaken[Med]![2] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else // if the medication plan day and day of week does not matches and the user has taken the medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Thursday")
                {
                    if(userTaken[Med]![3] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else // if the medication plan day and day of week does not matches and the user has taken the medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Friday")
                {
                    if(userTaken[Med]![4] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else // if the medication plan day and day of week does not matches and the user has taken the medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Saturday")
                {
                    if(userTaken[Med]![5] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else // if the medication plan day and day of week does not matches and the user has taken the medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                else if(date == "Sunday")
                {
                    if(userTaken[Med]![6] == true) // if the medication plan day and day of week matches and the user has taken the medication
                    {
                        Taken = medAmount[Med]![0] // sets the taken value to how much the user has taken
                    }
                    else // if the medication plan day and day of week does not matches and the user has taken the medication
                    {
                        Missed = medAmount[Med]![0] // sets the missed value to how much the user has taken
                    }
                }
                        // takes all the data and enters it into the barchartdataentry function
                        let data = BarChartDataEntry(x: Double(i), yValues: [Taken, Missed], data: "Group Chart" as AnyObject)
                        GraphData.append(data) // appends the data into the graph
                }
            else
                {
                    // if the key does not exist in the dictionary
                    // the medication is missed since there is no record of the user taking the medication
                    let Missed = self.dictMedToTake[Med]
                    let data = BarChartDataEntry(x: Double(i), yValues: [Taken, Missed ?? 0], data: "Group Chart" as AnyObject)
                    GraphData.append(data)
                }
            }
        }
        // changes the strings of the days into double values for the BarChartFormatter
        let formatter = BarChartFormatter(values: dayOfWeek)
        // more chart properties
        chtChart.xAxis.valueFormatter = formatter as IAxisValueFormatter
        let set = BarChartDataSet(values: GraphData, label: "Medication")
        set.drawIconsEnabled = false
        // bar colors are set
        set.colors = [UIColor.green,UIColor.red]
        // label the colored bar graph
        set.stackLabels = ["Taken", "Missed"]

        let chartData = BarChartData(dataSet: set)
        chartData.setValueFont(.systemFont(ofSize: 7, weight: .light))
//        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        chartData.setValueTextColor(.white)
        
        // starts charting the bars
        chtChart.fitBars = true
        chtChart.data = chartData
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
 }
