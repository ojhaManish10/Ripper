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

class ViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    
    @IBOutlet var userEmail: UITextField!
    @IBOutlet var userPassword: UITextField!
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    //Referencing the Firebase database
    var databaseRef = FIRDatabase.database().reference()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loader.startAnimating()
        
        //Code to log the user directly if previously logged in
        FIRAuth.auth()?.addStateDidChangeListener({(auth, user) in
            
            if user != nil{
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarControllerView")
                self.present(homeViewController, animated: true, completion: nil)
            }
            
        })

        GIDSignIn.sharedInstance().uiDelegate = self
        
        //Defining the style of the sign in button. (1.wide 2.standard 3.iconOnly)
        signInButton.style = .wide
        
        
        //Automatically sign in the user if not looged out previously
        GIDSignIn.sharedInstance().signInSilently()
        
        
        
        
        loader.stopAnimating()
        
    }
    
    @IBOutlet weak var signInButton: GIDSignInButton!

    //Hide keyboard when user touches outside the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

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
            loader.startAnimating()
            
        FIRAuth.auth()?.signIn(withEmail: self.userEmail.text!, password: self.userPassword.text!, completion: {(user, error)in
            print("ya samma aayo1")
            

            if (error == nil){

                self.performSegue(withIdentifier: "idSegueContent", sender: nil)
                
                }else{
                
                
                //User not logged in to the system
                print("This is the error", error!.localizedDescription)

                    //Display alert if the users information is incorrect while logging in to the app
                    let alertController = UIAlertController(title: "Oops", message: "Either the Email or Password entered is wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                self.loader.stopAnimating()
                    
                    return
                    
                }
                    
           })}
        }
    
    
}
