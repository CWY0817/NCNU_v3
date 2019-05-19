//
//  ResetPwViewController.swift
//  plants
//
//  Created by viplab on 2019/3/20.
//  Copyright © 2019年 viplab. All rights reserved.
//

import UIKit
import Firebase

class ResetPwViewController: UIViewController {
    @IBOutlet var emailTextField:UITextField!
    @IBAction func resetPasswd(sender:UIButton){
        guard let emailAddress = emailTextField.text,emailAddress != "" else{
            let alertController = UIAlertController(title: "Input Error", message:"Please provide your email address for password reset.",preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK",style: .cancel,handler:nil)
            alertController.addAction(okayAction)
            present(alertController,animated:true,completion: nil)
            return
        }
        //傳送密碼重設的email
        Auth.auth().sendPasswordReset(withEmail: emailAddress,completion:{
            (error) in
            let title = (error == nil) ? "Password Reset Follow-up" : "Password Reset Error"
            let message = (error == nil) ? "We have just send you a password reset email. Please check your inbox and follow the instructions to reset your password." : error?.localizedDescription
            let alertController = UIAlertController(title: title,message:message,preferredStyle: .alert)
            let okayAction = UIAlertAction(title:"OK",style: .cancel,handler:{
                (action) in
                if error == nil{
                    //解除鍵盤
                    self.view.endEditing(true)
                    //返回登入畫面
                    if let navController = self.navigationController{
                        navController.popViewController(animated: true)
                    }
                }
            })
            alertController.addAction(okayAction)
            self.present(alertController,animated: true,completion: nil)
        })
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
