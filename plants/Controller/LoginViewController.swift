//
//  LoginViewController.swift
//  plants
//
//  Created by viplab on 2019/3/15.
//  Copyright © 2019年 viplab. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func login(sender: UIButton){
        //  輸入驗證
        guard let emailAddress = emailTextField.text,emailAddress != "",let password = passwordTextField.text,password != "" else{
            let alertController = UIAlertController(title: "登入錯誤",message:"兩格都不能空白。",preferredStyle: .alert)
            let okayAction = UIAlertAction(title:"OK",style: .cancel,handler:nil)
            alertController.addAction(okayAction)
            present(alertController,animated:true,completion: nil)
            return
        }
        
        //呼叫Firebase APIs 執行登入
        Auth.auth().signIn(withEmail:emailAddress,password: password,completion:{(user,error) in
            if let error = error{
                let alertController = UIAlertController(title: "登入錯誤",message:error.localizedDescription,preferredStyle: .alert)
                let okayAction = UIAlertAction(title:"OK",style:.cancel,handler:nil)
                alertController.addAction(okayAction)
                self.present(alertController,animated: true,completion:nil)
                return
            }
            //Email認證
            guard let currentUser = user?.user, currentUser.isEmailVerified else {
                let alertController = UIAlertController(title:"登入錯誤",message:"您尚未驗證您的信箱。請先至信箱點擊郵件上的連結以進行驗證。若需重新發送驗證郵件，請點擊重新發送。",preferredStyle: .alert)
                let okayAction = UIAlertAction(title:"重新發送",style: .default,handler:{(action) in
                    user?.user.sendEmailVerification(completion: nil)
                })
                let cancelAction = UIAlertAction(title:"取消",style: .cancel,handler: nil)
                alertController.addAction(okayAction)
                alertController.addAction(cancelAction)
                self.present(alertController,animated: true,completion: nil)
                return
            }
            //解除鍵盤
            self.view.endEditing(true)
            //呈現主視圖
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
