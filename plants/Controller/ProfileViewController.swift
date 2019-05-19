//
//  ProfileViewController.swift
//  plants
//
//  Created by viplab on 2019/3/18.
//  Copyright © 2019年 viplab. All rights reserved.
//
import UIKit
import Firebase
import GoogleSignIn
import Photos

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var profileimg : UIImageView!
    @IBOutlet var logbutton : UIButton!
    @IBAction func LoginOrNot(sender: UIButton){
        if Auth.auth().currentUser != nil{
            do{
                if let proviserData = Auth.auth().currentUser?.providerData{
                    let userInfo = proviserData[0]
                    
                    switch userInfo.providerID{
                        
                    case "google.com":
                        GIDSignIn.sharedInstance()?.signOut()
                        
                    default:
                        break
                    }
                }
                
                try Auth.auth().signOut()
            }
            catch{
                let alertController = UIAlertController(title: "Logout Error",message:error.localizedDescription,preferredStyle:.alert)
                let okayAction = UIAlertAction(title:"OK",style:.cancel,handler:nil)
                alertController.addAction(okayAction)
                present(alertController,animated: true,completion: nil)
                return
            }
            //呈現歡迎視圖
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
                
            }
        }else{
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeNav"){
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func PhotoLibraryPermissions() -> Bool {
        
        let library:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if(library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted){
            return false
        }else {
            return true
        }
    }
    
    @IBAction func profileimg(sender:UIButton){
        let photoallow = PhotoLibraryPermissions()
        if Auth.auth().currentUser != nil{
            if photoallow {
                //判斷設置是否支持使用圖片庫
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    //初始化圖片控制器
                    let imagePicker = UIImagePickerController()
                    //設置代理
                    imagePicker.delegate = self
                    //指定圖片控制器類型
                    imagePicker.sourceType = .photoLibrary
                    //設置是否永允許編輯
                    imagePicker.allowsEditing = true
                    
                    //彈出控制器,顯示介面
                    self.present(imagePicker, animated:true, completion: nil)
                }
            }
            else{
                let alertController = UIAlertController (title: "相片存取失敗", message: "未允許存取相片", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "設定", style: .default) { (_) -> Void in
                    
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)            }
        }
        else {
            let alertController = UIAlertController(title:"請先登入",message:"必須要先登入才能更換大頭貼",preferredStyle:UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.default,handler:nil))
            present(alertController,animated:true,completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let selectedIamge = info[UIImagePickerControllerEditedImage] as? UIImage{
            //更新圖片至雲端
            ProfileService.shared.uploadImage(image:selectedIamge) {
                self.dismiss(animated: true, completion: nil)
            }
            profileimg.image = selectedIamge
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="個人檔案"
        profilesetup()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func profilesetup(){
        
        let POROFILE_DB_REF: DatabaseReference = Database.database().reference().child("profile")
        
        if Auth.auth().currentUser != nil{
            if let currentUser = Auth.auth().currentUser {
                nameLabel.text = currentUser.displayName
                if let user = currentUser.displayName {
                    let profiledef = POROFILE_DB_REF.child(user)
                    
                    profiledef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let value = snapshot.value as? NSDictionary
                        let imageurl = value?["imageFileURL"] as? String ?? ""
                        let notfirstlogin = value?["notfirstlogin"] as? Int ?? Int()
                        
                        
                        
                        if imageurl != "" {
                            //下載大頭貼圖片
                            if let image = CacheManager.shared.getFromCache(key: imageurl) as? UIImage {
                                self.profileimg.image = image
                            }
                            else {
                                if let url = URL(string: imageurl) {
                                    let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                                        guard let imageData = data else{
                                            return
                                        }
                                        OperationQueue.main.addOperation{
                                            guard let image = UIImage(data: imageData) else {return}
                                            if imageurl == imageurl{
                                                self.profileimg.image = image
                                            }
                                            
                                            //加入下載圖片至快取
                                            CacheManager.shared.cache(object: image, key: imageurl)
                                        }
                                    })
                                    
                                    downloadTask.resume()
                                }
                            }
                        }
                        else{
                            if currentUser.photoURL != nil{
                                
                                guard let imgurl = currentUser.photoURL else {
                                    return
                                }
                                
                                //更新Firebase Database的資料
                                if notfirstlogin != 1 {
                                    ProfileService.shared.updateProfilemessage (imgref: imgurl)
                                    if let data = try? Data(contentsOf: currentUser.photoURL! ){
                                        self.profileimg.image = UIImage(data: data)
                                    }
                                }
                            }
                            else{
                                //更新Firebase Database的資料
                                if notfirstlogin != 1 {
                                    profiledef.updateChildValues(["username":user, "imageFileURL": "", "useremail": currentUser.email,"profilephotokey":"","notfirstlogin": 1])
                                    self.profileimg.image = UIImage(named: "man")
                                }
                            }
                        }
                    })
                }
                logbutton.setTitle("登出", for: .normal)
            }
        }
        else{
            nameLabel.text = "使用者"
            logbutton.setTitle("登入", for: .normal)
        }
    }
    
}
