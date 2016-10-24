//
//  InstaDog.swift
//  AC3.2-InstaCats-2
//
//  Created by Jermaine Kelly on 10/23/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

struct InstaDog{
    let name:String
    let dogID:Int
    let instaUrl: URL
    let imageName: String
    let followers: Int
    let following: Int
    let postNum: Int
    
    
    init(name:String,ID:Int,instaUrl:URL,imageName:String,followers:Int,following:Int,postNum:Int){
        self.name = name
        self.dogID = ID
        self.instaUrl = instaUrl
        self.imageName = imageName
        self.followers = followers
        self.following = following
        self.postNum = postNum
    }
    
    
    
}
