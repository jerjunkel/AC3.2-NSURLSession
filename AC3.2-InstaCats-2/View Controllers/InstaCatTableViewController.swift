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
        
        // In the MVC design architecture, a view controller should only coordinate model data to the views
        // So, we move our code for creating InstaCats out of this tableViewController
//        if let instaCatsAll: [InstaCat] = InstaCatFactory.makeInstaCats(fileName: instaCatJSONFileName) {
//            self.instaCats = instaCatsAll
//        }
        
        InstaCatFactory.makeInstaCats(apiEndpoint: instaCatEndpoint) { (instaCats: [InstaCat]?) in
            if instaCats != nil {
                for cat in instaCats! {
                    print(cat.description)
                }
                
                self.instaCats = instaCats!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
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
