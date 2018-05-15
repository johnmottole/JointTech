//
//  DoctorGridViewController.swift
//  JoinTech
//
//  Created by John Mottole on 3/4/18.
//  Copyright © 2018 John Mottole. All rights reserved.
//

import UIKit

class DoctorGridViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var doctorCollection: UICollectionView!
    var doctor_ids = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getDoctors()
        // Do any additional setup after loading the view.
    }
    
    func getDoctors()
    {
        doctor_ids = []
        if let id = UserDefaults.standard.value(forKey: "user_id"){
            let json: [String: Any] = ["patient_id": "\(id)"]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                // create post request
                let url = NSURL(string:  "https://orthoinsights.herokuapp.com/get_doctors")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                // insert json data to the request
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                print("getting docs")
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(String(describing: error))")
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                        if let msg = result!["msg"] as? String
                        {
                            if msg == "success"
                            {
                                print(result!["doctor_ids"])
                                self.setDocInfo(ids: result!["doctor_ids"] as! NSArray)
                            }
                        }
                        
                        print("got em")
                        
                        
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
    
    func setDocInfo(ids : NSArray)
    {
        for id in ids{
            getDoctorName(id: id as! String)
        }
    }
    
    func getDoctorName(id : String) {
        let json: [String: Any] = ["user_id": id]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string:  "https://orthoinsights.herokuapp.com/get_user_info")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            
            // insert json data to the request
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                if error != nil{
                    print("Error -> \(String(describing: error))")
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                    if let msg = result!["msg"] as? String
                    {
                        if msg == "success"
                        {
                            let user = result!["user"] as! [String : Any]
                            let f_name = user["f_name"] as! String
                            let l_name = user["l_name"] as! String
                            let name = "Dr. \(f_name) \(l_name)"
                            self.doctor_ids.append(name)
                            OperationQueue.main.addOperation {
                                self.doctorCollection.reloadData()
                            }
                        }
                    }
                    
                    print("got em")
                    
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctor_ids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorCell", for: indexPath) as! DoctorCollectionViewCell
        cell.doctorName.text = doctor_ids[indexPath.row]
        return cell
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
