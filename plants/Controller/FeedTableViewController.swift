//
//  FeedTableViewController.swift
//  plants
//
//  Created by viplab on 2019/3/26.
//  Copyright © 2019年 viplab. All rights reserved.
//
import UIKit
import ImagePicker
import Firebase
import Photos

class FeedTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var postfeed: [Post] = []
    fileprivate var isLoadingPost = false
    @IBOutlet var progressview : UIProgressView!
    var timer: Timer?
    var proValue: Double?
    var messages: Post?
    
    func PhotoLibraryPermissions() -> Bool {
        
        let library:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if(library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted){
            return false
        }else {
            return true
        }
    }
    
    func cameraPermissions() -> Bool{
        
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            return false
        }else {
            return true
        }
        
    }
    
    
    @IBAction func openCamera(_ sender: Any){
        if Auth.auth().currentUser != nil{
            
            //相片存取以及相機權限
            let photoallow = PhotoLibraryPermissions()
            let cameraallow = cameraPermissions()
            
            //選單列表
            let optionMenu = UIAlertController(title:nil,message: "上傳圖片",preferredStyle: .actionSheet)
            
            //照片圖庫
            let choosephotoHandler = { (action:UIAlertAction!) -> Void in
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
            
            
            //相機
            let opencameraHandler = { (action:UIAlertAction!) -> Void in
                if cameraallow {
                    //判斷設置是否支持使用圖片庫
                    if UIImagePickerController.isSourceTypeAvailable(.camera){
                        //初始化圖片控制器
                        let imagePicker = UIImagePickerController()
                        //設置代理
                        imagePicker.delegate = self
                        //指定圖片控制器類型
                        imagePicker.sourceType = .camera
                        //設置是否永允許編輯
                        imagePicker.allowsEditing = true
                        
                        //彈出控制器,顯示介面
                        self.present(imagePicker, animated:true, completion: nil)
                    }
                }
                else{
                    let alertController = UIAlertController (title: "相機存取失敗", message: "未允許使用相機", preferredStyle: .alert)
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
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
            }
            
            
            let choosephoto = UIAlertAction(title: "相片圖庫", style: .default, handler: choosephotoHandler)
            optionMenu.addAction(choosephoto)
            
            let opencamera = UIAlertAction(title: "相機", style: .default, handler: opencameraHandler)
            optionMenu.addAction(opencamera)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            optionMenu.addAction(cancelAction)
            
            present(optionMenu,animated: true,completion: nil)
            
            
        }
        else{
            let alertController = UIAlertController(title:"請先登入",message:"必須要先登入才能使用此功能",preferredStyle:UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title:"OK",style:UIAlertActionStyle.default,handler:nil))
            present(alertController,animated:true,completion: nil)
        }
        
    }
    
    //儲存照片至手機相簿的提示框
    @IBAction func save(sender: UIButton){
        let alertController = UIAlertController(title: "儲存至相簿",
                                                message: nil, preferredStyle: .alert)
        //顯示提示框
        self.present(alertController, animated: true, completion: nil)
        //0.5秒後自動消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        if let selectedIamge = info[UIImagePickerControllerEditedImage] as? UIImage{
            //更新圖片至雲端
            PostService.shared.uploadImage(image:selectedIamge) {
                //進度條
                self.progressview.isHidden = false
                self.progressview.setProgress(0.8, animated: true)
                //計時器
                self.proValue = 0;
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.changeProgress), userInfo: nil, repeats: false)
                
                self.dismiss(animated: true, completion: nil)
                
                self.loadRecentPosts()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func changeProgress() {
        
        if var proValue = proValue{
            proValue = proValue + 1.0 // 改變ProValue的值
            if proValue > 5 {
                // 停止使用計時器
                print("停止使用計時器")
                if let timer = timer{
                    timer.invalidate()
                }
            } else {
                let alertController = UIAlertController(title:"上傳成功",message:"下拉刷新頁面就可以看到囉~(*´▽`*)",preferredStyle:UIAlertControllerStyle.alert)
                //顯示提示框
                self.present(alertController, animated: true, completion: nil)
                //0.5秒後自動消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                progressview.isHidden = true
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //設置下拉式更新
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(loadRecentPosts), for: UIControlEvents.valueChanged)
        progressview.isHidden = true
        //載入目前貼文
        loadRecentPosts()
        
    }
    
    @objc fileprivate func loadRecentPosts() {
        
        isLoadingPost = true
        
        PostService.shared.getRecentPosts(start: postfeed.first?.timestamp, limit: 10) { (newPosts) in
            if newPosts.count > 0 {
                //加入貼文陣列至陣列的開始處
                self.postfeed.insert(contentsOf: newPosts, at:0)
            }
            
            self.isLoadingPost = false
            
            if let _ = self.refreshControl?.isRefreshing {
                // 為了讓動畫效果更佳,在結束更新之前延遲0.5秒
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.refreshControl?.endRefreshing()
                    self.displayNewPosts(newPosts: newPosts)
                })
            }
            else{
                self.displayNewPosts(newPosts: newPosts)
            }
        }
    }
    
    private func displayNewPosts(newPosts posts: [Post]){
        //確認我們取得新的貼文來顯示
        guard posts.count > 0 else {
            return
        }
        
        //將它們插入表格視圖中來顯示貼文
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for num in 0...(posts.count - 1){
            let indexPath = IndexPath(row: num, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
    
}



extension FeedTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        //我們要在使用這滑到最後兩列時觸發這個載入
        guard !isLoadingPost, postfeed.count - indexPath.row == 2 else {
            return
        }
        
        isLoadingPost = true
        
        guard let lastPostTimestamp = postfeed.last?.timestamp else{
            isLoadingPost = false
            return
        }
        
        PostService.shared.getOldPosts(start: lastPostTimestamp, limit: 3){ (newPosts) in
            //加上新的貼文至目前陣列的表格視圖
            var indexPaths: [IndexPath] = []
            self.tableView.beginUpdates()
            for newPost in newPosts {
                self.postfeed.append(newPost)
                let indexPath = IndexPath(row: self.postfeed.count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            //print(self.postfeed)
            self.tableView.insertRows(at: indexPaths, with: .fade)
            self.tableView.endUpdates()
            
            self.isLoadingPost = false
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let currentPost = postfeed[indexPath.row]
        cell.configure(post: currentPost)
        //cell.sharephoto(post: currentPost)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postfeed.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
