//
//  DataService.swift
//  Ripper
//
//  Created by Manish Ojha on 12/28/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    
    static let ds = DataService()
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("Image_Collection/\((FIRAuth.auth()?.currentUser?.uid)!)")
    private var _REF_USERS = DB_BASE.child("User_Profiles")
    
    
    // Storage references
    private var _REF_POST_IMAGES = STORAGE_BASE.child("media")
    
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
 
}
