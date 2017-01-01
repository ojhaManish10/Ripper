//
//  Collection.swift
//  Ripper
//
//  Created by Manish Ojha on 1/1/17.
//  Copyright © 2017 Manish Ojha. All rights reserved.
//

import Foundation

class Collection{
    private var _caption: String?
    private var _imageUrl: String!
    private var _userName: String!
    private var _postKey: String!
    
    var caption: String?{
        return _caption
    }
    
    var imageUrl: String{
        return _imageUrl
    }
    
    var userName: String{
        return _userName
    }
    
    var postKey: String{
        return _postKey
    }
    
    init(captions: String, imageUrls: String, userName: String) {
        self._caption = captions
        self._imageUrl = imageUrls
        self._userName = userName
    }
    
    init(postKey:String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let imgUrl = dictionary["picture"] as? String{
            self._imageUrl = imgUrl
        }
        
        if let caption = dictionary["text"] as? String{
            self._caption = caption
        }
    }
    
    
    
}
