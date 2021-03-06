//
//  Tweet.swift
//  Twitter
//
//  Created by Jiapei Liang on 1/25/17.
//  Copyright © 2017 jiapei. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var id: Int?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var name: String?
    var screenName: String?
    var profileImageUrl: URL?
    var favorited: Bool?
    var retweeted: Bool?
    var entities: NSDictionary?
    var urls: NSDictionary?
    var url: String?
    var displayUrl: String?
    var expandedUrl: String?
    var created_at: String?
    
    var extendedEntrities: NSDictionary?
    
    var media: NSDictionary?
    var media1Url: URL?
    var media2Url: URL?
    var media3Url: URL?
    var media4Url: URL?
    
    
    init(dictionary: NSDictionary) {
        print(dictionary)
        
        id = (dictionary["id"] as? Int) ?? 0
        
        text = dictionary["text"] as? String
        
        created_at = dictionary["created_at"] as? String
        
        print("my created_at: \(created_at!)")
        
        entities = dictionary["entities"] as? NSDictionary
        
        let urlsTemp = entities?["urls"] as? NSArray
        
        if urlsTemp != nil && urlsTemp?.count != 0 {
            urls = urlsTemp![0] as! NSDictionary
            url = urls!["url"] as? String
            displayUrl = urls!["display_url"] as? String
            expandedUrl = urls!["expanded_url"] as? String
        }
        
        extendedEntrities = dictionary["extended_entities"] as? NSDictionary
        
        let mediaTemp = extendedEntrities?["media"] as? NSArray
        
        if mediaTemp != nil && mediaTemp?.count != 0 {
            if mediaTemp!.count >= 1 {
                media = mediaTemp![0] as! NSDictionary
                let mediaUrlString = media!["media_url_https"] as! String
                media1Url = URL(string: mediaUrlString)!
            }
            
            if mediaTemp!.count >= 2 {
                media = mediaTemp![1] as! NSDictionary
                let mediaUrlString = media!["media_url_https"] as! String
                media2Url = URL(string: mediaUrlString)!
            }
            
            if mediaTemp!.count >= 3 {
                media = mediaTemp![2] as! NSDictionary
                let mediaUrlString = media!["media_url_https"] as! String
                media3Url = URL(string: mediaUrlString)!
            }
            
            if mediaTemp!.count >= 4 {
                media = mediaTemp![3] as! NSDictionary
                let mediaUrlString = media!["media_url_https"] as! String
                media4Url = URL(string: mediaUrlString)!
            }
        }
        
        
        
        favorited = dictionary["favorited"] as? Bool
        
        retweeted = dictionary["retweeted"] as? Bool
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let user: NSDictionary = (dictionary["user"] as? NSDictionary) ?? [:]
        
        if user.count > 0 {
            if let profileImageUrlString = user["profile_image_url"] as? String {
                profileImageUrl = URL(string: profileImageUrlString)
            }
            
            screenName = user["screen_name"] as? String
            
            name = user["name"] as? String
        }
        
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            
            tweets.append(tweet)
        }
        
        return tweets
        
    }
    
    
}
