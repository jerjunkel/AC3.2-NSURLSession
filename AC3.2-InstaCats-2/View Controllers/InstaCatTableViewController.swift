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
    
    // instaDog lesson
    internal let InstaDogTableViewCellIdentifier: String = "InstaDogCellIdentifier"
    internal let instaDogEndpoint: String = "https://api.myjson.com/bins/58n98"
    internal var instaDogs: [InstaDog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        InstaDogFactory.makeInstaDogs(apiEndpoint: instaDogEndpoint) { (instaDogs: [InstaDog]?) in
            if instaDogs != nil {
                self.instaDogs = instaDogs!
                
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.instaCats.count
        default: return self.instaDogs.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: InstaCatTableViewCellIdentifier, for: indexPath)
            cell.textLabel?.text = self.instaCats[indexPath.row].name
            cell.detailTextLabel?.text = self.instaCats[indexPath.row].description
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: InstaDogTableViewCellIdentifier, for: indexPath)
            cell.textLabel?.text = self.instaDogs[indexPath.row].name
            cell.detailTextLabel?.text = self.instaDogs[indexPath.row].formattedStats()
            cell.imageView?.image = self.instaDogs[indexPath.row].profileImage()
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "InstaCats"
        default: return "InstaDogs"
        }
    }
}
