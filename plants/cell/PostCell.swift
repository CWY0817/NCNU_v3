//
//  PostCell.swift
//  plants
//
//  Created by viplab on 2019/3/26.
//  Copyright © 2019年 viplab. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var voteButton: LineButton! {
        didSet {
            voteButton.tintColor = .red
        }
    }
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
            avatarImageView.clipsToBounds = true
        }
    }
    
    //儲存照片至手機相簿
    @IBAction func saveImage(_ sender: UIButton) {
        let image = self.photoImageView.image!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    private var currentPost: Post?
    var postdetail : Post?
    
    var votepeople = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var reportnum = 0
    @IBAction func morebutton(_ sender: Any){
        
        let optionMenu = UIAlertController(title: nil,message: nil,preferredStyle: .actionSheet)
        
        //檢舉
        let reportHandler = { (action:UIAlertAction!) -> Void in
            if let user = self.postdetail?.postId {
                
                let alertController = UIAlertController (title: "檢舉", message: "你確定要檢舉這則Po文嗎？", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "確定", style: .default) { (_) -> Void in
                    
                    //取得Firebase Database的Reference
                    let postsRef = Database.database().reference().child("posts")
                    let postRef = postsRef.child(user)
                    
                    //更新Firebase Database的資料
                    if let postdetail = self.postdetail{
                        //self.reportnum = postdetail.report
                        postRef.updateChildValues(["imageFileURL": postdetail.imageFileURL,"timestamp": postdetail.timestamp,"user": postdetail.user,"votes":postdetail.votes,"report": self.reportnum + 1
                            
                            ])
                        self.reportnum = self.reportnum + 1
                    }
                    
                    let alertControllers = UIAlertController(title: "檢舉成功",
                                                             message: "我們會盡快處理這則貼文", preferredStyle: .alert)
                    //顯示提示框
                    self.window?.rootViewController?.present(alertControllers, animated: true, completion: nil)
                    //0.5秒後自動消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.window?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                
                
                
            }
        }
        
        
        //分享
        let shareHandler = {(action:UIAlertAction!) -> Void in
            var share : UIImage?
            if let postdetail = self.postdetail{
                if let data = try? Data(contentsOf: URL(string: (postdetail.imageFileURL))! ){
                    share = UIImage(data: data)
                }
                let sharetext = "你看這植物的照片很美麗喔～(*´∀`)~♥"
                
                let activityController : UIActivityViewController
                if let shareimage = share {
                    activityController = UIActivityViewController(activityItems: [shareimage,sharetext], applicationActivities: nil)
                }
                else{
                    activityController = UIActivityViewController(activityItems: [sharetext], applicationActivities: nil)
                }
                self.window?.rootViewController?.present(activityController, animated: true, completion: nil)
            }
            
        }
        
        let shareAction = UIAlertAction(title: "分享", style: .default, handler: shareHandler)
        optionMenu.addAction(shareAction)
        
        let report = UIAlertAction(title: "檢舉", style: .destructive, handler: reportHandler)
        optionMenu.addAction(report)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        optionMenu.addAction(cancelAction)
        
        self.window?.rootViewController?.present(optionMenu, animated: true, completion: nil)
    }
    
    //按讚
    var votecount = 0
    @IBAction func heartClick(_ sender: Any) {
        if let user = postdetail?.postId {
            
            //取得Firebase Database的Reference
            var postsRef = Database.database().reference().child("posts")
            var postRef = postsRef.child(user)
            
            //更新Firebase Database的資料
            if let postdetail = postdetail {
                    postRef.updateChildValues(["imageFileURL": postdetail.imageFileURL,
                                               "timestamp": postdetail.timestamp,
                                               "user": postdetail.user,
                                               "votes":votecount + 1
                        
                        ])
                    votecount = votecount + 1
                    voteButton.setTitle("\(votecount)", for: .normal)

             }
        }
        
    }

    
    
    
    func configure(post: Post) {
        
        //設定目前的貼文
        currentPost = post
        postdetail = post
        
        //設定Cell樣式
        selectionStyle = .none
        
        //設定姓名與按讚數
        nameLabel.text = post.user

        votecount = post.votes
        reportnum = post.report
        voteButton.setTitle("\(votecount)", for: .normal)
        
        
        
        avatarImageView.image = nil
        imgprofilesetup(post: post)
        
        //重設圖片視圖的圖片
        photoImageView.image = nil
        
        //下載貼文圖片
        if let image = CacheManager.shared.getFromCache(key: post.imageFileURL) as? UIImage {
            photoImageView.image = image
        }
        else {
            if let url = URL(string: post.imageFileURL) {
                let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, reponse, error) in
                    guard let imageData = data else{
                        return
                    }
                    OperationQueue.main.addOperation{
                        guard let image = UIImage(data: imageData) else {return}
                        if self.currentPost?.imageFileURL == post.imageFileURL{
                            self.photoImageView.image = image
                        }
                        
                        //加入下載圖片至快取
                        CacheManager.shared.cache(object: image, key: post.imageFileURL)
                    }
                })
                
                downloadTask.resume()
            }
        }
    }
    
    func imgprofilesetup(post: Post){
        
        let POROFILE_DB_REF: DatabaseReference = Database.database().reference().child("profile")
        let user = post.user
        let profiledef = POROFILE_DB_REF.child(user)
                    
        profiledef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
            let value = snapshot.value as? NSDictionary
            let imageurl = value?["imageFileURL"] as? String ?? ""
            
            if imageurl != "" {
                //下載大頭貼圖片
                if let image = CacheManager.shared.getFromCache(key: imageurl) as? UIImage {
                    self.avatarImageView.image = image
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
                                    self.avatarImageView.image = image
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
                self.avatarImageView.image = UIImage(named: "man")
            }
        })
    }
}
