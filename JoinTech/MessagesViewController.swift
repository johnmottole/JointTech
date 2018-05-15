//
//  MessagesViewController.swift
//  JoinTech
//
//  Created by John Mottole on 4/22/18.
//  Copyright © 2018 John Mottole. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var data = [[String:String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        var convo1 = [String: String]()
        convo1["name"] = "Dr. Jackson Avery"
        convo1["last"] = "10:41 AM"
        convo1["msg"] = "Your latest results look great!"
        convo1["img"] = "jackson.jpg"
        data.append(convo1)
        var convo2 = [String: String]()
        convo2["name"] = "Mike Jones"
        convo2["last"] = "12:55 PM"
        convo2["msg"] = "Let's get you in here soon!"
        convo2["img"] = "therpist.jpg"
        data.append(convo2)
        tableView.dataSource = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageTableViewCell
        let data_item = data[index]
        cell.last.text = data_item["last"]
        cell.message.text = data_item["msg"]
        cell.doctor.text = data_item["name"]
        let img = UIImage(named: data_item["img"]!)
        cell.imageView?.image = img
        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)!/2
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
