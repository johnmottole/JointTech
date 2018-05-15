//
//  LogInViewController.swift
//  JoinTech
//
//  Created by John Mottole on 2/27/18.
//  Copyright © 2018 John Mottole. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signIn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn.layer.cornerRadius = 25
        signIn.layer.masksToBounds = true
        emailField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func submit(_ sender: Any) {
        let user = emailField.text
        let pass = passwordField.text
        loginAttempt(user: user!, pass: pass!)
        
    }
    
    func displayMessage(message: String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)

    }
    
    func loginAttempt(user: String, pass: String)
    {
        
        let json: [String: Any] = ["e_mail": user, "password" : pass]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string:  "https://orthoinsights.herokuapp.com/login")!
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
                        
                    if let response = result {
                        if (response["msg"] as! String) == "failure"{
                            OperationQueue.main.addOperation {
                                if let error_string = response["error"]
                                {
                                    self.displayMessage(message: "\(error_string)")
                                }else{
                                    self.displayMessage(message: "An error occurred")
                                }
                            }
                        }else{
                            let id = response["user_id"] as! String
                            UserDefaults.standard.set(id, forKey: "user_id")
                            OperationQueue.main.addOperation {
                                self.performSegue(withIdentifier: "loginToMain", sender: self)
                            }
                        }
                    }else{
                        OperationQueue.main.addOperation {
                            self.displayMessage(message: "An error occured")
                        }
                    }
                }catch {
                    print("Error -> \(error)")
                    
                }
            }
            
            task.resume()
            
            
        } catch {
            print(error)
        }
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
