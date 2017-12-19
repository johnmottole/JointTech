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

    @IBOutlet weak var currentForceView: UIView!
    @IBOutlet weak var averageForceLabel: UILabel!
    @IBOutlet weak var theChart: LineChartView!
    @IBOutlet weak var averageForceView: UIView!
    @IBOutlet weak var realTimeLabel: UILabel!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let BEAN_SCRATCH_UUID = CBUUID(string: "A495FF21-C5B1-4B44-B512-1370F02D74DE")
    let BEAN_SERVICE_UUID = CBUUID(string: "A495FF20-C5B1-4B44-B512-1370F02D74DE")
    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var loadingView: UIView = UIView()

    var time = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateChart(array: [])
        
        //Turn squares to circles
        averageForceView.layer.cornerRadius = min(averageForceView.frame.size.height, averageForceView.frame.size.width) / 2.0
        averageForceView.layer.masksToBounds = true
        currentForceView.layer.cornerRadius = min(currentForceView.frame.size.height, currentForceView.frame.size.width) / 2.0
        currentForceView.layer.masksToBounds = true
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        loadingView.addSubview(myActivityIndicator)
        
        view.addSubview(loadingView)
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateChart(array: [NSManagedObject])
    {
        let final_data_array = array.suffix(5)
        var numbers = [ChartDataEntry]()
        if final_data_array.count > 0
        {
            var i = 0
            for var item in final_data_array{
                let force = item.value(forKey: "force")
                if let forceD = Double("\(force!)")
                {
                    numbers.append(ChartDataEntry(x: Double(i), y: forceD))
                }else{
                    numbers.append(ChartDataEntry(x: Double(i), y: 0))
                }
                i += 1
            }
        }
    
        let line = LineChartDataSet(values: numbers, label: "Stuff")
        line.colors = [NSUIColor.blue]
        let gradientColors = [UIColor(red: 230.0/255.0, green: 0, blue: 0, alpha: 1.0).cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        line.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        line.drawCirclesEnabled=false
        line.drawValuesEnabled = false
        line.drawFilledEnabled = true
        let data = LineChartData()
        data.addDataSet(line)
        theChart.data = data
        theChart.chartDescription?.text = ""
        theChart.gridBackgroundColor = NSUIColor.green
        theChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        theChart.xAxis.granularity = 1
        theChart.leftAxis.granularity = 1
        theChart.rightAxis.granularity = 1
        theChart.xAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 13.0)!
        theChart.leftAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 14.0)!
        theChart.rightAxis.labelFont =  UIFont(name: "HelveticaNeue-Light", size: 14.0)!


        if array.count > 0 {
            var labels = [String]()
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm:ss"
            for var item in final_data_array
            {
                if let date = item.value(forKey: "timestamp")! as? Date{
                    let time = formatter.string(from: date)
                    labels.append(time)
                }
            }
            theChart.xAxis.valueFormatter=IndexAxisValueFormatter(values:labels)
            theChart.xAxis.axisMinimum = -0.1;
            theChart.xAxis.axisMaximum = Double(final_data_array.count)-0.9;

            
        }
        
        theChart.legend.enabled = false
        theChart.xAxis.drawGridLinesEnabled = false
        theChart.fitScreen()
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
        if device?.contains("JointTech") == true {
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
            if service.uuid == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil,for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
                self.peripheral.setNotifyValue(true,for: thisCharacteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(Date())
        if characteristic.uuid == BEAN_SCRATCH_UUID {
            let str = "\([UInt8](characteristic.value!)[0])"
            realTimeLabel.text = str
            let intValue = Int(str)
            if let unwrappedInt = intValue{
                storeSnapshot(force: unwrappedInt)
                getData()
            }
            if time == 10 {
                time = 0
                updateAverage()
            }
            time += 1
            if myActivityIndicator.isAnimating == true{
                myActivityIndicator.stopAnimating()
                loadingView.removeFromSuperview()
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
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func storeSnapshot(force: Int) {
        let context = getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "ForceData", in: context)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(force, forKey: "force")
        transc.setValue(Date(), forKey: "timestamp")
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func getData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForceData")

        
        let calendar = NSCalendar.autoupdatingCurrent
        let sec30Date = calendar.date(byAdding: .second, value: -30, to: Date())

        let datePredicate = NSPredicate(format: "%@ <= timestamp", argumentArray: [sec30Date!])

        fetchRequest.predicate = datePredicate
        
        do {
            let array = try managedContext.fetch(fetchRequest)
            updateChart(array: array)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateAverage()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForceData")
        let calendar = NSCalendar.autoupdatingCurrent
        let sec24Date = calendar.date(byAdding: .hour, value: -24, to: Date())
        let datePredicate = NSPredicate(format: "%@ <= timestamp", argumentArray: [sec24Date!])
        fetchRequest.predicate = datePredicate
        do {
            let array = try managedContext.fetch(fetchRequest)
            var avg  = 0
            var size = 0
            for a in array {
                let force = a.value(forKey: "force")
                if let forceD = Int("\(force!)")
                {
                    avg += forceD
                    size += 1
                }
            }
            avg = avg / size
            averageForceLabel.text = "\(avg)"
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }


}

