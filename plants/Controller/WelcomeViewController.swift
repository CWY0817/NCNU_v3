//
//  WelcomeViewController.swift
//  plants
//
//  Created by viplab on 2019/3/14.
//  Copyright © 2019年 viplab. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class WelcomeViewController: UIViewController {
    @IBAction func cancel(sender:UIButton){
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab"){
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
            
        }    }
    
    @IBAction func googleLogin(sender: UIButton){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookLogin(sender: UIButton){
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions:["public_profile","email"],from:self){
            (result,error) in
            if let error = error{
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else{
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            //呼叫Firebase APIs來執行登入
            Auth.auth().signIn(with:credential, completion:{(user,error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title:"Login Error",message: error.localizedDescription,preferredStyle:.alert)
                    let okayAction=UIAlertAction(title:"OK",style:.cancel,handler:nil)
                    alertController.addAction(okayAction)
                    self.present(alertController,animated: true,completion: nil)
                    return
                }
                //呈現主視圖
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MyProfile"){
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""

        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindtoWelcomeView(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}


extension WelcomeViewController: GIDSignInDelegate,GIDSignInUIDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
        
        if error != nil{
            return
        }
        
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: {(user, error) in
            if let error = error{
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title:"OK",style:.cancel,handler:nil)
                alertController.addAction(okayAction)
                self.present(alertController,animated: true,completion: nil)
                return
            }
            
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
            
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
    }
}
