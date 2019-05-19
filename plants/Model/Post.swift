//
//  Post.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 5/12/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Foundation

struct Post {
    // MARK: - Properties
    
    var postId: String
    var imageFileURL: String
    var user: String
    var votes: Int
    var timestamp: Int
    var report: Int
    
    // MARK: - Firebase Keys
    
    enum PostInfoKey {
        static let imageFileURL = "imageFileURL"
        static let user = "user"
        static let votes = "votes"
        static let timestamp = "timestamp"
        static let report = "report"
    }
    
    // MARK: - Initialization
    
    init(postId: String, imageFileURL: String, user: String, votes: Int, timestamp: Int = Int(NSDate().timeIntervalSince1970 * 1000),report: Int) {
        self.postId = postId
        self.imageFileURL = imageFileURL
        self.user = user
        self.votes = votes
        self.timestamp = timestamp
        self.report = report
    }
    
    init?(postId: String, postInfo: [String: Any]) {
        guard let imageFileURL = postInfo[PostInfoKey.imageFileURL] as? String,
            let user = postInfo[PostInfoKey.user] as? String,
            let votes = postInfo[PostInfoKey.votes] as? Int,
            let timestamp = postInfo[PostInfoKey.timestamp] as? Int,
            let report = postInfo[PostInfoKey.report] as? Int else {
                
                return nil
        }
        
        self = Post(postId: postId, imageFileURL: imageFileURL, user: user, votes: votes, timestamp: timestamp,report:report)
    }
}
