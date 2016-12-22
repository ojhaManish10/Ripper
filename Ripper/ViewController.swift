//
//  ViewController.swift
//  Ripper
//
//  Created by Manish Ojha on 9/29/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet var userEmail: UITextField!
    @IBOutlet var userPassword: UITextField!
    @IBOutlet var errorMessage: UILabel!
    
    //Referencing the Firebase database
    var databaseRef = FIRDatabase.database().reference()
   

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        if FIRAuth.auth()?.currentUser  == nil {
            // No user is signed in.
            print("User not signned in")
            
        } else {
            
            // User is signed in.
            performSegue(withIdentifier: "idSegueContent", sender: nil)
            
            print("current userid is fucking", FIRAuth.auth()?.currentUser?.uid as Any)
            
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //Defining the style of the sign in button. (1.wide 2.standard 3.iconOnly)
        signInButton.style = .wide
        
        //Automatically sign in the user if not looged out previously
        GIDSignIn.sharedInstance().signInSilently()
        
        
        
        
    }
    
    @IBOutlet weak var signInButton: GIDSignInButton!

    

// MARK: - Action methods for Login
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
    
        //Display alert if the users information field is empty
        if self.userEmail.text! == "" && self.userPassword.text! == "" {
            let alertController = UIAlertController(title: "Oops", message: "We can't proceed because the fields should not be empty to proceed.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }

        else{
        FIRAuth.auth()?.signIn(withEmail: self.userEmail.text!, password: self.userPassword.text!, completion: {(user, error)in
            print("ya samma aayo1")
            

            if (error == nil){
                //User is logged in to the system
                
                //to get current users data from firebase (can only get uid, photoURL and email by this way)
                let user = FIRAuth.auth()?.currentUser
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let email = user?.email
//                let uid = user?.uid
//                let photoURL = user?.photoURL
                
                print("the email of the user is", email!)
                self.performSegue(withIdentifier: "idSegueContent", sender: nil)
                
                }else{
                
                
                //User not logged in to the system
                print("This is the error", error!.localizedDescription)

                    //Display alert if the users information is incorrect while logging in to the app
                    let alertController = UIAlertController(title: "Oops", message: "Either the Email or Password entered is wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                    
                }
                    
           })}
        }
            

}
