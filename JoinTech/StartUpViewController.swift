//
//  StartUpViewController.swift
//  JoinTech
//
//  Created by John Mottole on 11/30/17.
//  Copyright © 2017 John Mottole. All rights reserved.
//

import UIKit

class StartUpViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 25
        loginButton.layer.masksToBounds = true
      
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "user_id") != nil {
            self.performSegue(withIdentifier: "StartUpToMain", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginHit(_ sender: Any) {
    }
    
    @IBAction func signUpHit(_ sender: Any) {
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
