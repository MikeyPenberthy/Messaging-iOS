//
//  ViewController.swift
//  Messages-iOS
//
//  Created by Michael Penberthy on 8/23/16.
//  Copyright © 2016 Michael Penberthy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email","public_profile"];
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.performSegueWithIdentifier("homeSegue", sender: self)
            } else {
                self.view.addSubview(self.loginButton)
                self.loginButton.center = self.view.center
                self.loginButton.delegate = self;
                self.loginButton.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("user Logged into facebook")
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)

        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print("user Logged in to firebase")
        }
        
    }
    

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged out")
    }
    
    
    
    
}

