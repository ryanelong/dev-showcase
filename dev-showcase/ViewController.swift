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
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used in debugging to unset the logged in user
        //UserDefaults.standard.removeObject(forKey: KEY_UID)
        
        ref = FIRDatabase.database().reference()
        
    }

    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        ref.child("users").child(uid).setValue(user)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
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
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                
                if error != nil {
                    print("Login Failed")
                } else {
                    print("Logged In! \(user?.uid)")
                    
                    if let providerData = user?.providerData, providerData.count > 0 {
                        
                        let provider = providerData[0].providerID
                        let userDict = ["provider": provider]
                        self.createFirebaseUser(uid: (user?.uid)!, user: userDict)
                    }
                    
                    UserDefaults.standard.set(user?.uid, forKey: KEY_UID)
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                }
                
            }
            
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            
            print("Made it here!")
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd) { (user, error) in
                
                if error != nil {
                    
                    print("\(error.debugDescription)")
                    
                    //print(FIRAuthErrorNameKey.debugDescription)
                    //print(FIRAuthErrorNameKey)
                    
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            print("invalid email")
                        case .errorCodeUserNotFound:
                            print("user not found")
                            
                            FIRAuth.auth()?.createUser(withEmail: email, password: pwd) { (user, error) in
                                
                                if error != nil {

                                    if let errCode2 = FIRAuthErrorCode(rawValue: error!._code) {
                                        print(errCode2)
                                        switch errCode {
                                            case .errorCodeWeakPassword:
                                                print("weak password")
                                            default:
                                                print("Create User Error: \(error!)")
                                        }
                                        
                                        self.showErrorAlert(title: "Could not create account", msg: "Problem creating account.  Try something else. \(error.debugDescription)")
                                        
                                    }

                                } else {
                                    
                                    UserDefaults.standard.set(user?.uid, forKey: KEY_UID)
                                    
                                    FIRAuth.auth()?.signIn(withEmail: email, password: pwd) { (user, error) in
                                    
                                        // This should work, we just created a user
                                        
                                        if let providerData = user?.providerData, providerData.count > 0 {
                                            
                                            let provider = providerData[0].providerID
                                            let userDict = ["provider": provider]
                                            self.createFirebaseUser(uid: (user?.uid)!, user: userDict)
                                        }
                                        
                                        
                                    
                                    }
                                    
                                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                                    
                                }
                                
                            }
                            
                        default:
                            print("Login User Error: \(error!)")
                            self.showErrorAlert(title: "Could not login", msg: "Problem loggin into account.  Try something else. \(error.debugDescription)")
                        }
                    }
                    
                } else {
                    
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    
                }
                
            }

        } else {
            showErrorAlert(title: "Email and Password Required", msg: "You must enter and email and password")
        }
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

