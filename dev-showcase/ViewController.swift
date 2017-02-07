//
//  ViewController.swift
//  dev-showcase
//
//  Created by ryan on 2/5/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func fbBtnPressed(sender: UIButton!) {
        
        //let facebookLogin = FBSDKLoginManager()
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if (error == nil){
                
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if fbloginresult.grantedPermissions != nil {
                    
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                    
                }
                
            } else {
                print("Facebook Login Failed.  Error \(error)")
            }
        }
        
    }
    
    func getFBUserData(){
        if let accessToken = FBSDKAccessToken.current().tokenString {
            
            print("Successfully logged in with facebook. \(accessToken)")
            
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! [String : AnyObject]
//                    print(result!)
//                    print(self.dict)
//                }
//            })
        }
    }
    
}

