//
//  ViewController.swift
//  JoinTech
//
//  Created by John Mottole on 11/29/17.
//  Copyright © 2017 John Mottole. All rights reserved.
//


import UIKit
import Charts
import CoreBluetooth
import CoreData


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var theChart: LineChartView!
    @IBOutlet weak var medialLaterialChart: LineChartView!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let BEAN_DEVICE_NAME  = "Bean"
    let BEAN_SCRATCH_UUID1 = CBUUID(string: "A495FF21-C5B1-4B44-B512-1370F02D74DE")
    let BEAN_SCRATCH_UUID2 = CBUUID(string: "A495FF22-C5B1-4B44-B512-1370F02D74DE")

    let BEAN_SERVICE_UUID = CBUUID(string: "A495FF20-C5B1-4B44-B512-1370F02D74DE")

    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var loadingView: UIView = UIView()
    
    var firstPoint : Int? = nil
    
    enum ChartState {
        case live, day, week, month
    }

    var chartMode = ChartState.live
    var chartPoints = [Int]()
    var chartLabels = [String]()
    
    
    enum medialLaterialChartState {
        case medial,laterial,both
    }
    var medialLaterialChartMode = medialLaterialChartState.medial
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        loadingView.addSubview(myActivityIndicator)
        
        view.addSubview(loadingView)
        
        updateMedialLaterialChart()
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scannin")
        } else {
            print("Bluetooth not available.")
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        print(device ?? "Default Value")
        if device?.contains(BEAN_DEVICE_NAME) == true {
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            print(service.uuid)
            if service.uuid == BEAN_SERVICE_UUID{
                peripheral.discoverCharacteristics(nil,for: thisService)
                if myActivityIndicator.isAnimating == true{
                    myActivityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID1 || thisCharacteristic.uuid == BEAN_SCRATCH_UUID2 {
                self.peripheral.setNotifyValue(true,for: thisCharacteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(Date())
        if characteristic.uuid == BEAN_SCRATCH_UUID1 {
            let str = "\([UInt8](characteristic.value!)[0])"
            let intValue = Int(str)!
            firstPoint = intValue
            
        }
        if characteristic.uuid == BEAN_SCRATCH_UUID2 {
            let str = "\([UInt8](characteristic.value!)[0])"
            let intValue = Int(str)!
            if let point1 = firstPoint{
                sendToBackend(value1: point1, value2: intValue)
                firstPoint = nil
                if chartMode == .live{
                    updateLiveChart(value1: point1, value2: intValue, timestamp: getTimeStampArray())
                }
            }
            
        }
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        manager.scanForPeripherals(withServices: nil, options: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTimeStampArray() -> [Int]
    {
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        return [year!,month!,day!,hour!, minute!,second!]
    }
    
    func sendToBackend(value1: Int, value2: Int)
    {
        if let id = UserDefaults.standard.value(forKey: "user_id"){
            print("ID: -->> \(id)")
            let json: [String: Any] = ["user_id": "\(id)", "timestamp" : getTimeStampArray(), "sensor1" : value1, "sensor2" : value2]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                print("id \(id)")
                print("Timestamp array \(getTimeStampArray())")
                print("value1 \(value1)")
                print("value2 \(value2)")

                print("Send: \(jsonData)")
                
                // create post request
                let url = NSURL(string:  "https://orthoinsights.herokuapp.com/add_point")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                // insert json data to the request
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                        
                        print("Result -> \(result)")
                        
                    } catch {
                        print("Error -> \(error)")
                    }
                }
                
                task.resume()
                
                
            } catch {
                print(error)
            }
        }
        
    }
    
    func updateLiveChart(value1: Int?, value2: Int?, timestamp : [Int]?){
        
        if (value1 == nil)
        {
            theChart.data = nil
            return
        }
        
        chartPoints.append((value1!+value2!)/2)
        var min = "\(timestamp![4])"
        if timestamp![4] < 10
        {
            min = "0\(timestamp![4])"
        }
        var sec = "\(timestamp![5])"
        if timestamp![5] < 10
        {
            sec = "0\(timestamp![5])"
        }
        chartLabels.append("          \(min):\(sec) ")
        var numbersSensor1 = [ChartDataEntry]()

        if chartPoints.count > 5
        {
            chartPoints = Array(chartPoints.suffix(5))
            chartLabels = Array(chartLabels.suffix(5))
        }
        if chartPoints.count > 0
        {
            var i = 0
            for var item in chartPoints{
                numbersSensor1.append(ChartDataEntry(x: Double(i)+0.3, y: Double(item)))
                i += 1
            }
        }
        
        let line1 = LineChartDataSet(values: numbersSensor1, label: "Sensor 1")
        line1.colors = [NSUIColor.gray]
        line1.circleColors = [NSUIColor.gray]
        line1.circleHoleRadius = 5
        line1.circleRadius = 7
        line1.drawCirclesEnabled=true
        line1.drawValuesEnabled = false
        line1.highlightEnabled = false

        let data = LineChartData()
        data.addDataSet(line1)
        theChart.data = data
        
        theChart.chartDescription?.text = ""
        theChart.gridBackgroundColor = NSUIColor.green
        theChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        theChart.xAxis.granularity = 1
        theChart.leftAxis.granularity = 2
        theChart.xAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 13.0)!
        theChart.leftAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        theChart.rightAxis.enabled = false
        if chartPoints.count > 0 {
            theChart.xAxis.valueFormatter=IndexAxisValueFormatter(values:chartLabels)
        }
        theChart.leftAxis.valueFormatter=IndexAxisValueFormatter(values: ["0X BW","", "2X BW","", "4X BW", "", "6X BW","", "8X BW"])
        theChart.legend.enabled = false
        theChart.xAxis.drawGridLinesEnabled = false
        theChart.xAxis.axisMinimum = 0
        theChart.xAxis.axisMaximum = 5
        theChart.leftAxis.axisMinimum = 0
        theChart.leftAxis.axisMaximum = 8
        theChart.fitScreen()
    }
    
    
    func average(list: [Double]) -> Double{
        if list.count == 0 {
            return 0
        }
        var total :Double = 0
        for item in list{
            total += item
        }
        return (total / Double(list.count))
    }
    
    
    func getDummyData() -> [String:[Any]]
    {
        switch chartMode {
        case .day:
            let values = [1.5,0.5,2,3,2,2.5,4,1]
            let labels = getDateLabels(type: "hour")
            return ["values":values,"labels":labels]
        case .week:
            let values = [2,2.5,3,2,3,2,2.5]
            let labels = getDateLabels(type: "day")
            return ["values":values,"labels":labels]
        case .month:
            let values = [2,1.5,2,2.5]
            let labels = getDateLabels(type: "week")
            return ["values":values,"labels":labels]
        default:
            return ["values":[],"labels":[]]
        }
    }
    
    func getDateLabels(type : String) -> [String]
    {
        let formatter = DateFormatter()
        var labels = [String]()
        switch type {
        case "hour":
            for index in stride(from: 8, to: 0, by: -1)
            {
                formatter.dateFormat = "hh a"
                var date = Calendar.current.date(
                    byAdding: .hour,
                    value: -index,
                    to: Date())
                let hourString = formatter.string(from: date!)
                labels.append(hourString)
            }
            return labels
        case "day":
            for index in stride(from: 6, to: -1, by: -1)
            {
                var date = Calendar.current.date(
                    byAdding: .day,
                    value: -index,
                    to: Date())
                let components = Calendar.current.dateComponents([.day], from: date!)
                var day  = "\(components.day!)"
                switch (day) {
                case "1" , "21" , "31":
                    day.append("st")
                case "2" , "22":
                    day.append("nd")
                case "3" ,"23":
                    day.append("rd")
                default:
                    day.append("th")
                }
                day.append("  ")
                labels.append(day)
                
            }
            return labels
        case "week":
            for index in stride(from: 28, to: 6, by: -7)
            {
                var date = Calendar.current.date(
                    byAdding: .day,
                    value: -index,
                    to: Date())
                let components = Calendar.current.dateComponents([.day], from: date!)
                var day  = "\(components.day!)"
                switch (day) {
                case "1" , "21" , "31":
                    day.append("st")
                case "2" , "22":
                    day.append("nd")
                case "3" ,"23":
                    day.append("rd")
                default:
                    day.append("th")
                }
                day.append("  ")
                labels.append(day)
            }
            return labels
        default:
            return [""]
        }
    }
    
    func updateChartUsingHistorical()
    {
        let data = getDummyData()
        let values = data["values"] as! [Double]
        let labels = data["labels"] as! [String]
        var dataPoints = [ChartDataEntry]()
        for index in 0...(values.count-1){
            dataPoints.append(ChartDataEntry(x: Double(index), y: values[index]))
        }
        
        let line1 = LineChartDataSet(values: dataPoints, label: "Readings")
        line1.colors = [NSUIColor.gray]
        line1.circleColors = [NSUIColor.gray]
        line1.circleHoleRadius = 5
        line1.circleRadius = 7
        line1.drawCirclesEnabled=true
        line1.drawValuesEnabled = false
        line1.highlightEnabled = false
        let lineData = LineChartData()
        lineData.addDataSet(line1)
        theChart.data = lineData
        
        theChart.chartDescription?.text = ""
        theChart.gridBackgroundColor = NSUIColor.green
        theChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        theChart.xAxis.granularity = 1
        if chartMode == .day{
            theChart.xAxis.granularity = 2
        }
        theChart.leftAxis.granularity = 2
        theChart.xAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 13.0)!
        theChart.leftAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        theChart.rightAxis.enabled = false
        if labels.count > 0 {
            print("CUSTOOMMM")
            print(labels)
            theChart.xAxis.valueFormatter=IndexAxisValueFormatter(values:labels)
        }
        theChart.leftAxis.valueFormatter=IndexAxisValueFormatter(values: ["0X BW","", "2X BW","", "4X BW", "", "6X BW","", "8X BW"])
        theChart.legend.enabled = false
        theChart.xAxis.drawGridLinesEnabled = false
        theChart.xAxis.axisMinimum = 0
        theChart.xAxis.axisMaximum = Double(values.count-1)
        theChart.leftAxis.axisMinimum = 0
        theChart.leftAxis.axisMaximum = 8
        //theChart.fitScreen()
    }
    
    @IBAction func ChartTypeChange(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        let index = sender.selectedSegmentIndex
        if index == 0
        {
            chartMode = .live
            updateLiveChart(value1: nil, value2: nil, timestamp: nil)
        }else if index == 1{
            chartMode = .day
            updateChartUsingHistorical()
        } else if index == 2{
            chartMode = .week
            updateChartUsingHistorical()
        } else{
            chartMode = .month
            updateChartUsingHistorical()
        }
    }

    @IBAction func MedialLaterialChanged(_ sender: Any) {
        let segment = sender as! UISegmentedControl
        let index = segment.selectedSegmentIndex
        if index == 0{
            medialLaterialChartMode = .medial
        }else if index == 1 {
            medialLaterialChartMode = .laterial
        }else {
            medialLaterialChartMode = .both
        }
        updateMedialLaterialChart()
    }
    
    func getMedialLatDummyData() -> [String : Any]
    {
        let medialValues : [Double] = [3.05,3.1,3.2,3.6,3.7,3.8,3.85]
        let labels = getDateLabels(type: "day")
        var medialChartEntrys = [ChartDataEntry]()
        var lateralChartEntrys = [ChartDataEntry]()
        for index in 0...(medialValues.count-1)
        {
            medialChartEntrys.append(ChartDataEntry(x: Double(index), y: medialValues[index]))
            lateralChartEntrys.append(ChartDataEntry(x: Double(index), y: (5-medialValues[index])))

        }
        return ["medial":medialChartEntrys,"lateral":lateralChartEntrys,"labels":labels]
    }
    
    func updateMedialLaterialChart()
    {
        let data = getMedialLatDummyData()
        let labels = data["labels"] as! [String]
        if medialLaterialChartMode != .both
        {
            var dataPoints = [ChartDataEntry]()
            if medialLaterialChartMode == .medial{
                dataPoints = data["medial"] as! [ChartDataEntry]
            }else{
                dataPoints = data["lateral"] as! [ChartDataEntry]
            }
            let line1 = LineChartDataSet(values: dataPoints, label: "Medial/Lateral")
            line1.colors = [NSUIColor.gray]
            line1.circleColors = [NSUIColor.gray]
            line1.circleHoleRadius = 5
            line1.circleRadius = 7
            line1.drawCirclesEnabled=true
            line1.drawValuesEnabled = false
            line1.highlightEnabled = false

            let lineData = LineChartData()
            lineData.addDataSet(line1)
            medialLaterialChart.data = lineData
        }else
        {
            let dataPointsMedial = data["medial"] as! [ChartDataEntry]
            let dataPointsLateral = data["lateral"] as! [ChartDataEntry]
            let line1 = LineChartDataSet(values: dataPointsMedial, label: "Medial")
            line1.colors = [NSUIColor.gray]
            line1.circleColors = [NSUIColor.gray]
            line1.circleHoleRadius = 5
            line1.circleRadius = 7
            line1.drawCirclesEnabled=true
            line1.drawValuesEnabled = false
            line1.highlightEnabled = false

            
            let line2 = LineChartDataSet(values: dataPointsLateral, label: "lateral")
            line2.colors = [NSUIColor.gray]
            line2.circleColors = [NSUIColor.gray]
            line2.circleHoleRadius = 5
            line2.circleRadius = 7
            line2.drawCirclesEnabled=true
            line2.drawValuesEnabled = false
            line2.highlightEnabled = false
            
            let lineData = LineChartData()
            lineData.addDataSet(line1)
            lineData.addDataSet(line2)
            medialLaterialChart.data = lineData
        }
        medialLaterialChart.chartDescription?.text = ""
        medialLaterialChart.gridBackgroundColor = NSUIColor.green
        medialLaterialChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        medialLaterialChart.xAxis.granularity = 1
        medialLaterialChart.leftAxis.granularity = 1
        medialLaterialChart.xAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 13.0)!
        medialLaterialChart.leftAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        medialLaterialChart.rightAxis.enabled = false
        if labels.count > 0 {
            print("CUSTOOMMM")
            print(labels)
            medialLaterialChart.xAxis.valueFormatter=IndexAxisValueFormatter(values:labels)
        }
        medialLaterialChart.leftAxis.valueFormatter=IndexAxisValueFormatter(values: ["0%","20%", "40%","60%", "80%", "100%"])
        medialLaterialChart.legend.enabled = false
        medialLaterialChart.xAxis.drawGridLinesEnabled = false
        medialLaterialChart.xAxis.axisMinimum = 0
        medialLaterialChart.xAxis.axisMaximum = Double((data["medial"] as! [ChartDataEntry]).count-1)
        medialLaterialChart.leftAxis.axisMinimum = 0
        medialLaterialChart.leftAxis.axisMaximum = 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let theP = peripheral{
            manager.cancelPeripheralConnection(theP)
        }
    }
    
  

}

