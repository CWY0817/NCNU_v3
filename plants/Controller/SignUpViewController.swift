//
//  SignUpViewController.swift
//  plants
//
//  Created by viplab on 2019/3/12.
//  Copyright © 2019年 viplab. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up"
        // Do any additional setup after loading the view.
        nameTextField.becomeFirstResponder()
    }
    @IBAction func registerAccount(sender: UIButton){
        //輸入驗證(有空白就執行else)
        guard let name = nameTextField.text,name != "",
            let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text,password != "" else {
                let alertController = UIAlertController(title: "Registration Error", message: "Please make sure you provide your name, email address and password to complete the registration.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK",style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                present(alertController, animated: true,completion: nil)
                return
        }
        //在Firebase註冊使用者帳號
        Auth.auth().createUser(withEmail: emailAddress, password: password, completion: {(user, error) in
            if let error = error{
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController,animated:true,completion:nil)
                return
            }
            //儲存使用者的名稱
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                changeRequest.displayName = name
                changeRequest.commitChanges(completion:{(error) in
                    if let error = error{
                    print("Failed to change the display name: \(error.localizedDescription)")
                    }
                    
                })
            }
            //移除鍵盤
            self.view.endEditing(true)
            //傳送驗證信
            user?.user.sendEmailVerification(completion: nil)
            let alertController = UIAlertController(title: "信箱認證",message: "我們已經發送認證郵件至您的信箱。請至信箱確認並點擊郵件中的連結來完成帳號建立。",preferredStyle: .alert)
            let okayAction = UIAlertAction(title:"OK",style: .cancel,handler:{(action) in
                //解除目前試圖控制器
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okayAction)
            self.present(alertController,animated: true,completion: nil)
            
           /* //呈現主視圖
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated:true,completion: nil)
            }*/
        })
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
