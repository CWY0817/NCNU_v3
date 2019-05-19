//
//  PorfileService.swift
//  plants
//
//  Created by viplab on 2019/5/19.
//  Copyright © 2019年 viplab. All rights reserved.
//

import Foundation
import Firebase

final class ProfileService {
    
    static let shared: ProfileService = ProfileService()
    private init() { }
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let POST_DB_REF: DatabaseReference = Database.database().reference().child("profile")
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("profilephotos")
    
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        //產生一個貼文的唯一ID並準備貼文Database的參照
        let profilephotoDatabaseRef = POST_DB_REF.childByAutoId()
        
        //使用唯一個key作為圖片名稱並準備Storage參照
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(profilephotoDatabaseRef.key).jpg")
        let imageref = "\(profilephotoDatabaseRef.key).jpg"
        
        
        
        //調整圖片大小
        let scaledImage = image.scale(newWidth: 640.0)
        
        guard let imageData = UIImageJPEGRepresentation(scaledImage, 0.9) else {
            return
        }
        
        //建立檔案元資料
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        //準備上傳任務
        let uploadTask = imageStorageRef.putData(imageData, metadata:metadata)
        
        
        //觀察上傳狀態
        uploadTask.observe(.success) { (snapshot) in
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            guard let useremail = Auth.auth().currentUser?.email else {
                return
            }
            let profileuser = displayName
            let prodef = self.POST_DB_REF.child(profileuser)
            //在資料庫中加上一個參照
            
            prodef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                let useremail = value?["useremail"] as? String ?? ""
                let imageurl = value?["imageFileURL"] as? String ?? ""
                let profilephotokey = value?["profilephotokey"] as? String ?? ""
                let notfirstlogin = value?["notfirstlogin"] as? Int ?? Int()
                
                if profilephotokey != "" {
                    self.PHOTO_STORAGE_REF.child(profilephotokey).delete(completion: { (error) in
                        if let error = error{
                            print("Failed to delete picture!")
                        }
                        else{
                            print("Delete picture successfully!")
                        }
                    })
                }
                
                let profileupdate: [String: Any] = [Profile.ProfileInfoKey.username: username,Profile.ProfileInfoKey.imageFileURL: imageurl,
                                                    Profile.ProfileInfoKey.useremail: useremail,
                                                    Profile.ProfileInfoKey.profilephotokey:"",
                                                    Profile.ProfileInfoKey.notfirstlogin: notfirstlogin]
                prodef.updateChildValues(profileupdate)
            })
            
            imageStorageRef.downloadURL(completion:{ (url,error) in
                if let imageFileURL = url?.absoluteString {
                    
                    let post: [String: Any] = [Profile.ProfileInfoKey.username: profileuser,
                                               Profile.ProfileInfoKey.imageFileURL: imageFileURL,
                                               Profile.ProfileInfoKey.useremail: useremail,Profile.ProfileInfoKey.profilephotokey: imageref,Profile.ProfileInfoKey.notfirstlogin: Int(1)]
                    
                    prodef.updateChildValues(post)
                }
            })
            completionHandler()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)/Double(snapshot.progress!.totalUnitCount)
            print("Uploading... \(percentComplete)% complete")
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateProfilemessage (imgref: URL) {
        let imgurl = imgref
        guard let displayName = Auth.auth().currentUser?.displayName else {
            return
        }
        guard let useremail = Auth.auth().currentUser?.email else {
            return
        }
        let profileuser = displayName
        let prodef = self.POST_DB_REF.child(profileuser)
        
        
        //在資料庫中加上一個參照
        
        let profileupdate: [String: Any] = [Profile.ProfileInfoKey.username: profileuser,Profile.ProfileInfoKey.imageFileURL: imgurl.absoluteString,
                                            Profile.ProfileInfoKey.useremail: useremail,
                                            Profile.ProfileInfoKey.profilephotokey:"",
                                            Profile.ProfileInfoKey.notfirstlogin: Int(1)]
        prodef.updateChildValues(profileupdate)
    }
}
