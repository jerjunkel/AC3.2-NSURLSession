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
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []

    // We're going to get a second set of data, but this time it will be from the web
    internal let instaCatEndpoint: String = "https://api.myjson.com/bins/254uw"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let instaCatsAll: [InstaCat] = InstaCatFactory.makeInstaCats(fileName: instaCatJSONFileName) {
//            self.instaCats = instaCatsAll
//        }
        
        
        self.getInstaCats(from: instaCatEndpoint) { instaCat in
            if let validCats: [InstaCat] = instaCat {
                DispatchQueue.main.async{
                    self.instaCats = validCats
                    self.tableView.reloadData()
                }
            }
        }
        
//        InstaCatFactory.makeInstaCats(apiEndpoint: instaCatEndpoint) { (instaCats: [InstaCat]?) in
//            if instaCats != nil {
//                for cat in instaCats! {
//                    print(cat.description)
//                }
//                
//                self.instaCats = instaCats!
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//                
//            }
//        }
        
    }
    
    func getInstaCats(from apiEndpoint: String, callback: @escaping (([InstaCat]?)->Void)) {
        if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
            
            let session = URLSession(configuration: URLSessionConfiguration.default)

            session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil {
                    print("Error encountered!: \(error!)")
                }
                
                if let validData: Data = data {
                    print(validData)
                    
                    let allTheCats: [InstaCat]? = InstaCatFactory.manager.getInstaCats(from: validData)
                    callback(allTheCats)
                }
                }.resume() // Other: Easily forgotten, but we need to call resume to actually launch the task
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InstaCatTableViewCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = self.instaCats[indexPath.row].name
        cell.detailTextLabel?.text = self.instaCats[indexPath.row].description
        
        return cell
    }

}
