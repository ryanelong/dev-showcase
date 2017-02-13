//
//  DataService.swift
//  dev-showcase
//
//  Created by ryan on 2/7/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import Foundation
import Firebase

//let URL_BASE = "https://dev-showcase-2e038.firebaseapp.com"
let URL_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()

    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    //private var _REF_USERS_UID = URL_BASE.child("users/uid")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = _REF_USERS.child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.child(uid).setValue(user)
    }
    
}
