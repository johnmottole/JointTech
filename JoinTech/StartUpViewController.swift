//
//  StartUpViewController.swift
//  JoinTech
//
//  Created by John Mottole on 11/30/17.
//  Copyright © 2017 John Mottole. All rights reserved.
//

import UIKit

class StartUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var infoViewContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        infoViewContainer.layer.cornerRadius = 10
        infoViewContainer.layer.masksToBounds = true
        connectButton.layer.cornerRadius = 25
        connectButton.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 80
        scrollView.contentInset = contentInset
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
