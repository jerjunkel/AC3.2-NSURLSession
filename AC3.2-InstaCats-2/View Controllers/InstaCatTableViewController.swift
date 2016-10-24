//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-2
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class InstaCatTableViewController: UITableViewController {
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let InstaDogTableViewCellIdentifier:String = "InstaDogCellIdentifier"
    internal var cellIdentifier: String = ""
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []
    internal var instaDogs: [InstaDog] = []
    internal let instaCatEndpoint: String = "https://api.myjson.com/bins/254uw"
    internal let instaDogEndpoint: String = "https://api.myjson.com/bins/58n98"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getInstaCats(apiEndpoint: instaCatEndpoint) { (returnedInstaCats:[InstaCat]?) in
            guard let unwrappedInstaCats = returnedInstaCats else{
                return
            }
            
            self.instaCats = unwrappedInstaCats
            self.cellIdentifier = self.InstaCatTableViewCellIdentifier
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        InstaDogFactory.manager.makeInstaDogs(apiEndpoint: instaDogEndpoint) { (returnedInstaDogs:[InstaDog]?) in
            guard let unwrappedInstaDogs = returnedInstaDogs else{
                return
            }
            
            self.instaDogs = unwrappedInstaDogs
            self.cellIdentifier = self.InstaDogTableViewCellIdentifier
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return self.instaCats.count
        case 1:
            return self.instaDogs.count
        default:
            break
        }
        
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: InstaCatTableViewCellIdentifier, for: indexPath)
            cell.textLabel?.text = self.instaCats[indexPath.row].name
            cell.detailTextLabel?.text = self.instaCats[indexPath.row].description
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: InstaDogTableViewCellIdentifier, for: indexPath)
            let dog = self.instaDogs[indexPath.row]
            cell.textLabel?.text = dog.name
            cell.detailTextLabel?.text = "Post:\(dog.postNum) Followers: \(dog.followers) Following: \(dog.following)"
            cell.imageView?.image = UIImage(named: dog.imageName)
            return cell
         default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "InstaCats"
        case 1:
            return "InstaDogs"
        default:
            break
        }
        
        return ""
    }
    
    
    
    //MARK: - Utilities
    
    func getInstaCats(apiEndpoint: String, callback: @escaping ([InstaCat]?) -> Void) {
        if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
            // 1. URLSession/Configuration
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // 2. dataTaskWithURL
            session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
                // 3. check for errors right away
                if error != nil {
                    print("Error encountered!: \(error!)")
                }
                // 4. printing out the data
                if let validData: Data = data {
                    print(validData)
                    // 5. reuse our code to make some cats from Data
                    let allTheCats: [InstaCat]? = InstaCatFactory.manager.getInstaCats(from: validData)
                    callback(allTheCats) //callback closure
                }
                }.resume()
        }
    }
}
