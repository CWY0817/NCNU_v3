//
//  Porfile.swift
//  plants
//
//  Created by viplab on 2019/5/19.
//  Copyright © 2019年 viplab. All rights reserved.
//

import Foundation

struct Profile {
    
    // MARK: - Properties
    var user: String
    var username: String
    var imageFileURL: String
    var useremail: String
    var profilephotokey:String
    var notfirstlogin:Int
    
    // MARK: - Firebase Keys
    
    enum ProfileInfoKey {
        static let username = "username"
        static let imageFileURL = "imageFileURL"
        static let useremail = "useremail"
        static let profilephotokey = "profilephotokey"
        static let notfirstlogin = "notfirstlogin"
    }
    
    // MARK: - Initialization
    
    init(user: String,username: String ,imageFileURL: String, useremail: String ,profilephotokey: String,notfirstlogin:Int) {
        self.user = user
        self.imageFileURL = imageFileURL
        self.username = username
        self.useremail = useremail
        self.profilephotokey = profilephotokey
        self.notfirstlogin = notfirstlogin
    }
    
    init?(user: String, postInfo: [String: Any]) {
        guard let username = postInfo[ProfileInfoKey.username] as? String,
            let imageFileURL = postInfo[ProfileInfoKey.imageFileURL] as? String,
            let useremail = postInfo[ProfileInfoKey.useremail] as? String,
            let profilephotokey = postInfo[ProfileInfoKey.profilephotokey] as? String,
            let notfirstlogin = postInfo[ProfileInfoKey.profilephotokey] as? Int else {
                return nil
        }
        
        self = Profile(user: user,username: username, imageFileURL: imageFileURL, useremail: useremail,profilephotokey: profilephotokey,notfirstlogin:notfirstlogin)
    }
}

