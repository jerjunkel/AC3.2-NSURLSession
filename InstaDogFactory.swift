//
//  InstaDogFactory.swift
//  AC3.2-InstaDogs-2
//
//  Created by Jermaine Kelly on 10/23/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class InstaDogFactory{
    static let manager: InstaDogFactory = InstaDogFactory()
    private init() {}
    
    
    
    /// Attempts to make `[InstaDog]` from the `Data` contained in a local file
    /// - parameter filename: The name of the file containing json-formatted data, including its extension in the name
    /// - returns: An array of `InstaDog` if the file is located and has properly formatted data. `nil` otherwise.
//    class func makeInstaDogs(fileName: String) -> [InstaDog]? {
//        
//        // Everything from viewDidLoad in InstaDogTableViewController has just been moved here
//        guard let instaDogsURL: URL = InstaDogFactory.manager.getResourceURL(from: fileName),
//            let instaDogData: Data = InstaDogFactory.manager.getData(from: instaDogsURL),
//            let instaDogsAll: [InstaDog] = InstaDogFactory.manager.getInstaDogs(from: instaDogData) else {
//                return nil
//        }
//        
//        return instaDogsAll
//    }
    
    
    //MARK: - Utilities
    
    func makeInstaDogs(apiEndpoint: String, callback: @escaping ([InstaDog]?) -> Void) {
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
                   // print(validData)
                    // 5. reuse our code to make some cats from Data
                    let allTheDogs: [InstaDog]? = self.getInstaDogs(from: validData)
                    callback(allTheDogs) //callback closure
                }
                }.resume()
        }
    }
    
    
    /// Gets the `URL` for a local file
    fileprivate func getResourceURL(from fileName: String) -> URL? {
        
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound)
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound)
        
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL
    }
    
    /// Gets the `Data` from the local file located at a specified `URL`
    fileprivate func getData(from url: URL) -> Data? {
        
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    
    // MARK: - Data Parsing
    /// Creates `[InstaDog]` from valid `Data`
    internal func getInstaDogs(from jsonData: Data) -> [InstaDog]? {
        
        do {
            let instaDogJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // Cast from Any and check for the "Dogs" key
            guard let instaDogJSONCasted: [String : AnyObject] = instaDogJSONData as? [String : AnyObject],
                let instaDogArray: [AnyObject] = instaDogJSONCasted["dogs"] as? [AnyObject] else {
                    return nil
            }
            
            var instaDogs: [InstaDog] = []
            instaDogArray.forEach({ instaDogObject in
                if let instaDogName: String = instaDogObject["name"] as? String,
                    let instaDogIDString: String = instaDogObject["dog_id"] as? String,
                    let instaDogInstagramURLString: String = instaDogObject["instagram"] as? String,
                    let instaDogImageString: String = instaDogObject["imageName"] as? String,
                    let instaDogStatsDic:[String:String] = instaDogObject["stats"] as? [String:String],
                    let instaDogFollowersString: String = instaDogStatsDic["followers"],
                    let instaDogFollowingString: String = instaDogStatsDic["following"],
                    let instaDogPostsString: String = instaDogStatsDic["posts"],
                    
                    
                    // Some of these values need further casting
                    let instaDogID: Int = Int(instaDogIDString),
                    let instaDogFollowers: Int = Int(instaDogFollowersString),
                    let instaDogFollowing: Int = Int(instaDogFollowingString),
                    let instaDogPosts: Int = Int(instaDogPostsString),
                    let instaDogInstagramURL: URL = URL(string: instaDogInstagramURLString){
                    
                    // append to our temp array
                    instaDogs.append(InstaDog(name: instaDogName, ID: instaDogID, instaUrl: instaDogInstagramURL, imageName: instaDogImageString, followers: instaDogFollowers, following: instaDogFollowing, postNum: instaDogPosts))
                    
                }
//                else {
//                        return
                
                
            })
            
            return instaDogs
        }
        catch let error as NSError {
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }
    
    
}
