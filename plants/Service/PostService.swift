//
//  PostService.swift
//  plants
//
//  Created by viplab on 2019/3/31.
//  Copyright © 2019年 viplab. All rights reserved.
//

import Foundation
import Firebase

final class PostService {
    
    static let shared: PostService = PostService()
    private init() { }
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts")
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        //產生一個貼文的唯一ID並準備貼文Database的參照
        let postDatabaseRef = POST_DB_REF.childByAutoId()
        
        //使用唯一個key作為圖片名稱並準備Storage參照
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(postDatabaseRef.key).jpg")
        
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
            
            //在資料庫中加上一個參照
            imageStorageRef.downloadURL(completion:{ (url,error) in
                if let imageFileURL = url?.absoluteString {
                    let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
                    
                    let post: [String: Any] = [Post.PostInfoKey.imageFileURL: imageFileURL,
                                               Post.PostInfoKey.votes : Int(0),
                                               Post.PostInfoKey.user: displayName,
                                               Post.PostInfoKey.timestamp: timestamp,
                                               Post.PostInfoKey.report : Int(0)]
                    
                    postDatabaseRef.setValue(post)
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
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        var postQuery = POST_DB_REF.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            //如果有指定時戳,我們將會以比給定值來的新的時戳來取得貼文
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        }
        else {
            //否則的話,我們將會取得最近的貼文
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        //呼叫Firebase API來取得最新的資料記錄
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let postInfo = item.value as? [String: Any] ?? [:]
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            if newPosts.count > 0 {
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            
            completionHandler(newPosts)
            
        })
    }
    
    func getOldPosts(start timestamp: Int, limit: UInt, completionHandler: @escaping ([Post]) -> Void){
        let postOrderedQuery = POST_DB_REF.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var newPosts: [Post] = []
            for item in  snapshot.children.allObjects as! [DataSnapshot] {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo){
                    newPosts.append(post)
                }
            }
            
            //以降冪來排序 (也就是最新的貼文變成第一則貼文)
            newPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completionHandler(newPosts)
        })
    }
}
