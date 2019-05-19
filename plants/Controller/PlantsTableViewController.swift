//
//  PlantsTableViewController.swift
//  plants
//
//  Created by viplab on 2018/8/6.
//  Copyright © 2018年 viplab. All rights reserved.
//

import UIKit

class PlantsTableViewController: UITableViewController,UISearchResultsUpdating {
    
    var searchController: UISearchController!

    
    var db :SQLiteConnect? = nil
    let url = Bundle.main.path(forResource: "ncnuplant", ofType: "sqlite")
    
    // MARK: - 植物class陣列
    var plants:[Plants] = []
    var plantsearch: [Plants] = []
    var plantslocation:[Plantslocation] = []
    var plantsdata:[Plantsdata] = []
    var plantslocationcount = [Int](repeating:0,count:50)
    var plantslon = [Double](repeating:0,count:170)
    var plantslat = [Double](repeating:0,count:170)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //搜尋框
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "搜尋植物名稱..."
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        //導覽列
    navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default )
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // MARK: - 資料庫
        
        // 資料庫檔案的路徑
        let sqlitePath = url!
        
        // 印出儲存檔案的位置
        print(sqlitePath)
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            
            // select
            let statement = mydb.fetch("plantdata", cond: "1 == 1", order: nil)
            let statement1 = mydb.fetch("plantlocation_db", cond: "1 == 1", order: nil)
            let statement2 = mydb.fetch("datatag", cond: "1 == 1", order: nil)
            while sqlite3_step(statement) == SQLITE_ROW{
                let pid = sqlite3_column_int(statement, 0)
                let cname = String(cString: sqlite3_column_text(statement, 1))
                let sname = String(cString: sqlite3_column_text(statement, 2))
                let othername = String(cString: sqlite3_column_text(statement, 3))
                let familia = String(cString: sqlite3_column_text(statement, 4))
                let originplace = String(cString: sqlite3_column_text(statement, 5))
                let distribution = String(cString: sqlite3_column_text(statement, 6))
                let application = String(cString: sqlite3_column_text(statement, 7))
                let leaf = String(cString: sqlite3_column_text(statement, 8))
                let stem = String(cString: sqlite3_column_text(statement, 9))
                let flower = String(cString: sqlite3_column_text(statement, 10))
                let fruit = String(cString: sqlite3_column_text(statement, 11))
                let startmonth = sqlite3_column_int(statement, 12)
                let endmonth = sqlite3_column_int(statement, 13)
                let tmp = Plants(Pid: pid, Cname: cname, Sname: sname, Othername: othername, Familia: familia, Originplace: originplace, Distribution: distribution, Application: application, Leaf: leaf, Stem: stem, Flower: flower, Fruit: fruit, Startmonth: startmonth, Endmonth: endmonth, Isee: false)
                plants.append(tmp)
            }
            sqlite3_finalize(statement)
            
            var num = 0
            while sqlite3_step(statement1) == SQLITE_ROW{
                let pid = sqlite3_column_int(statement1, 0)
                let latitude = sqlite3_column_double(statement1, 1)
                let longitude = sqlite3_column_double(statement1, 2)
                let tmp = Plantslocation(Pid: pid,Latitude: latitude, Longitude: longitude )
                plantslat[num] = latitude
                plantslon[num] = longitude
                num = num + 1
                plantslocation.append(tmp)
                
                
            }
            sqlite3_finalize(statement1)
            
            while sqlite3_step(statement2) == SQLITE_ROW{
                let pid = sqlite3_column_int(statement2, 0)
                let twotofive = sqlite3_column_int(statement2, 1)
                let fivetoseven = sqlite3_column_int(statement2, 2)
                let eighttoten = sqlite3_column_int(statement2, 3)
                let eleventoone = sqlite3_column_int(statement2, 4)
                let white = sqlite3_column_int(statement2, 5)
                let red = sqlite3_column_int(statement2, 6)
                let orange = sqlite3_column_int(statement2, 7)
                let yellow = sqlite3_column_int(statement2, 8)
                let green = sqlite3_column_int(statement2, 9)
                let blue = sqlite3_column_int(statement2, 10)
                let purple = sqlite3_column_int(statement2, 11)
                let brown = sqlite3_column_int(statement2, 12)
                let other = sqlite3_column_int(statement2, 13)
                let regular = sqlite3_column_int(statement2, 14)
                let irregular = sqlite3_column_int(statement2, 15)
                let composite = sqlite3_column_int(statement2, 16)
                let three = sqlite3_column_int(statement2, 17)
                let four = sqlite3_column_int(statement2, 18)
                let five = sqlite3_column_int(statement2, 19)
                let six = sqlite3_column_int(statement2, 20)
                let seven = sqlite3_column_int(statement2, 21)
                let altermate = sqlite3_column_int(statement2, 22)
                let opposite = sqlite3_column_int(statement2, 23)
                let whorled = sqlite3_column_int(statement2, 24)
                let fasciculate = sqlite3_column_int(statement2, 25)
                let simpleleaf = sqlite3_column_int(statement2, 26)
                let compoudleaf = sqlite3_column_int(statement2, 27)
                let aclularleaf = sqlite3_column_int(statement2, 28)
                let tmp = Plantsdata(Pid: pid, twotofive: twotofive, fivetoseven: fivetoseven, eighttoten: eighttoten, eleventoone: eleventoone, white: white, red: red, orange: orange, yellow: yellow, green: green, blue: blue, purple: purple, brown: brown, other: other, regular: regular, irregular: irregular, composite: composite, three: three, four: four, five: five, six: six, seven: seven, altermate: altermate, opposite: opposite, whorled: whorled, fasciculate: fasciculate, simpleleaf: simpleleaf, compoudleaf: compoudleaf, aclularleaf: aclularleaf)
                plantsdata.append(tmp)
            }
            sqlite3_finalize(statement2)
        }
        
        count()
        
    }
    
    //因為同一植物有多個座標,將location對應相對植物
    func count(){
        for index in 0...plantslocation.count-1{
            for number in 0...49{
                if (plantslocation[index].Pid - 1) == number {
                    plantslocationcount[number] = plantslocationcount[number] + 1
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive{
            return plantsearch.count
        }
        else{
            return plants.count
        }
    }

    //MARK: - 建立Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellidentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier, for: indexPath)as! PlantsTableViewCell

        if searchController.isActive{
            cell.nameLabel.text = plantsearch[indexPath.row].Cname
            cell.familiaLabel.text = "學名: " + plantsearch[indexPath.row].Familia
            cell.snameLabel.text = "科屬: " + plantsearch[indexPath.row].Sname
            cell.plantsimage.image = UIImage(named: plantsearch[indexPath.row].Cname)
            cell.heartIcon.isHidden = plantsearch[indexPath.row].Isee ? false : true
            return cell
        }
        else{
            cell.nameLabel.text = plants[indexPath.row].Cname
            cell.familiaLabel.text = "學名: " + plants[indexPath.row].Familia
            cell.snameLabel.text = "科屬: " + plants[indexPath.row].Sname
            cell.plantsimage.image = UIImage(named: plants[indexPath.row].Cname)
            cell.heartIcon.isHidden = plants[indexPath.row].Isee ? false : true
            return cell
        }

    }


    
    // MARK: - 傳遞資料給另一個視圖
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showplantsdetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destination = segue.destination as!PlantsDetailViewController
                destination.hidesBottomBarWhenPushed = true
                destination.plants = (searchController.isActive) ? plantsearch[indexPath.row] : plants[indexPath.row]
                var counting = 0
                if indexPath.row > 0{
                    for index in 0...indexPath.row-1
                    {
                        counting = counting + plantslocationcount[index]
                    }
                }
                
                let num = plantslocationcount[indexPath.row]
                if num > 0{
                    for index in 0...num-1{
                        destination.plantslocation = plantslocation[counting]
                        destination.takelat[index] = plantslat[counting]
                        destination.takelon[index] = plantslon[counting]
                        counting = counting + 1
                    }
                    destination.number = num
                }
            }
        }
        
    }
    

    func filterContent(for searchText: String) {
        // 資料庫檔案的路徑
        let sqlitePath = url!
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        plantsearch = []
        if let mydb = db {
            let statement = mydb.search("plantdata", cond: "cname",cond2:"familia", searching: searchText)
            
            while sqlite3_step(statement) == SQLITE_ROW{
                let pid = sqlite3_column_int(statement, 0)
                let cname = String(cString: sqlite3_column_text(statement, 1))
                let sname = String(cString: sqlite3_column_text(statement, 2))
                let othername = String(cString: sqlite3_column_text(statement, 3))
                let familia = String(cString: sqlite3_column_text(statement, 4))
                let originplace = String(cString: sqlite3_column_text(statement, 5))
                let distribution = String(cString: sqlite3_column_text(statement, 6))
                let application = String(cString: sqlite3_column_text(statement, 7))
                let leaf = String(cString: sqlite3_column_text(statement, 8))
                let stem = String(cString: sqlite3_column_text(statement, 9))
                let flower = String(cString: sqlite3_column_text(statement, 10))
                let fruit = String(cString: sqlite3_column_text(statement, 11))
                let startmonth = sqlite3_column_int(statement, 12)
                let endmonth = sqlite3_column_int(statement, 13)
                let tmp = Plants(Pid: pid, Cname: cname, Sname: sname, Othername: othername, Familia: familia, Originplace: originplace, Distribution: distribution, Application: application, Leaf: leaf, Stem: stem, Flower: flower, Fruit: fruit, Startmonth: startmonth, Endmonth: endmonth, Isee: false)
                plantsearch.append(tmp)
            }
            sqlite3_finalize(statement)
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }

    
    
    
    /* //MARK: - 向左滑動
     override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
     
     //刪除
     let deleteAction = UIContextualAction(style:.destructive,title: "Delete"){(action,sourceView,completionHandler) in
     
     self.plants.remove(at: indexPath.row)
     
     self.tableView.deleteRows(at: [indexPath], with: .fade)
     
     completionHandler(true)
     }
     deleteAction.backgroundColor = UIColor(red:231.0/255.0,green:76.0/255.0,blue:60.0/255.0,alpha:1.0)
     deleteAction.image = UIImage(named: "delete")
     
     //分享
     let shareAction = UIContextualAction(style:.normal,title:"Share"){(action,sourceView,completionHandler) in
     
     let sharetext = "去看看這植物吧🌳"
     
     let activityController : UIActivityViewController
     if let shareimage = UIImage(named: self.plants[indexPath.row].Cname){
     activityController = UIActivityViewController(activityItems: [shareimage,sharetext], applicationActivities: nil)
     }
     else{
     activityController = UIActivityViewController(activityItems: [sharetext], applicationActivities: nil)
     }
     
     if let popoverController = activityController.popoverPresentationController{
     if let cell = tableView.cellForRow(at: indexPath){
     popoverController.sourceView = cell
     popoverController.sourceRect = cell.bounds
     }
     }
     
     self.present(activityController,animated: true,completion: nil)
     completionHandler(true)
     }
     shareAction.backgroundColor = UIColor(red:254.0/255.0,green:149.0/255.0,blue:38.0/255.0,alpha:1.0)
     shareAction.image = UIImage(named: "share")
     
     //check
     let title2 = plants[indexPath.row].Isee ? "Undo Check" : "Check"
     let booling2 = plants[indexPath.row].Isee ? false : true
     
     let checkAction2 = UIContextualAction(style:.normal,title:title2){(action,sourceView,completionHandler) in
     let cell = tableView.cellForRow(at: indexPath)as!PlantsTableViewCell
     cell.heartIcon.isHidden = booling2 ? false : true
     self.plants[indexPath.row].Isee = booling2
     completionHandler(true)
     }
     let img = booling2 ? "tick" : "undo"
     checkAction2.image = UIImage(named: img)
     
     
     let Swipe = UISwipeActionsConfiguration(actions: [deleteAction,shareAction,checkAction2])
     
     return Swipe
     
     }*/
}

