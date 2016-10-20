//
//  InstaDogFactory.swift
//  AC3.2-InstaCats-2
//
//  Created by Louis Tur on 10/19/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class InstaDogFactory {
    
    static let manager: InstaDogFactory = InstaDogFactory()
    private init() {}
    
    class func makeInstaDogs(apiEndpoint: String, callback: @escaping ([InstaDog]?) -> Void) {
        
        if let validInstaDogEndpoint: URL = URL(string: apiEndpoint) {

            // 1. NSURLSession/Configuration
            let session = URLSession(configuration: URLSessionConfiguration.default)

            // 2. dataTaskWithURL
            session.dataTask(with: validInstaDogEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in

                // 3. Error Check
                if error != nil {
                    print("Error encountered!: \(error!)")
                }

                // 4. Print the data
                if let validData: Data = data {

                    // 5. New class made from previous lesson
                    let allTheDogs: [InstaDog]? = InstaDogFactory.manager.getInstaDogs(from: validData)

                    callback(allTheDogs)
                }
                }.resume() // Easily forgotten
        }
    }
    
    
    internal func getInstaDogs(from jsonData: Data) -> [InstaDog]? {
        
        do {
            let instaDogJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            // Cast from Any and check for the "cats" key
            guard let instaDogJSONCasted: [String : AnyObject] = instaDogJSONData as? [String : AnyObject],
                let instaDogArray: [AnyObject] = instaDogJSONCasted["dogs"] as? [AnyObject] else {
                    return nil
            }

            var instaDogs: [InstaDog] = []
            instaDogArray.forEach({ instaDogObject in
                guard
                    // top level keys
                    let instaDogName: String = instaDogObject["name"] as? String,
                    let instaDogIDString: String = instaDogObject["dog_id"] as? String,
                    let instaDogInstagramURLString: String = instaDogObject["instagram"] as? String,
                    let instaDogImageName: String = instaDogObject["imageName"] as? String,
                    
                    // "stats" key results in further casting
                    let instaDogStats: [String : String] = instaDogObject["stats"] as? [String: String],
                    let instaDogStatsFollowersString: String = instaDogStats["followers"],
                    let instaDogStatsFollowingString: String = instaDogStats["following"],
                    let instaDogStatsPostsString: String = instaDogStats["posts"],
                    
                    // type conversions
                    let instaDogID: Int = Int(instaDogIDString),
                    let instaDogInstagramURL: URL = URL(string: instaDogInstagramURLString),
                    let instaDogStatsFollowers: Int = Int(instaDogStatsFollowersString),
                    let instaDogStatsFollowing: Int = Int(instaDogStatsFollowingString),
                    let instaDogStatsPosts: Int = Int(instaDogStatsPostsString)
                else {
                    return
                }
                
                let newInstaDog = InstaDog(name: instaDogName,
                                           dogID: instaDogID,
                                           instagramURL: instaDogInstagramURL,
                                           imageName: instaDogImageName,
                                           followers: instaDogStatsFollowers,
                                           following: instaDogStatsFollowing,
                                           numberOfPosts: instaDogStatsPosts)
                
                // append to our temp array
                instaDogs.append(newInstaDog)
            })

            return instaDogs
        }
        catch let error as NSError {
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }

        
        return nil
    }

}
