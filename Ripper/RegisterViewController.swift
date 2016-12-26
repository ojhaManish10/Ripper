//
//  RegisterViewController.swift
//  Ripper
//
//  Created by Manish Ojha on 10/8/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    //Creating reference to the FIrebase database
    var databaseRef = FIRDatabase.database().reference()
    
    @IBOutlet var userName: UITextField!
    @IBOutlet var userEmail: UITextField!
    @IBOutlet var accountPassword: UITextField!
    @IBOutlet var retypePassword: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var errorMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disabling the signUpButton
        signUpButton.isEnabled = false

        // Do any additional setup after loading the view.
    }

    @IBAction func haveAccount(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: -  Signning up the user
    
    @IBAction func tappedSignUpButton(_ sender: AnyObject) {
        
        signUpButton.isEnabled = false
        
        FIRAuth.auth()?.createUser(withEmail: userEmail.text!, password: accountPassword.text!, completion: {(user, Error)in
            
            if (Error != nil){
                
                    self.errorMessage.text = Error!.localizedDescription
                }else{
                self.errorMessage.text = "Registered Sucessfully"
                
                FIRAuth.auth()?.signIn(withEmail: self.userEmail.text!, password: self.accountPassword.text!, completion: {(user, Error)in
                    
                    if (Error == nil){
                        print("ya aayo")
                        self.databaseRef.child("user_profiles").child(user!.uid).child("email").setValue(self.userEmail.text!)
                        self.databaseRef.child("user_profiles").child(user!.uid).child("name").setValue(self.userName.text!)
                        //self.databaseRef.child("user_profiles").child(user!.uid).child("password").setValue(self.accountPassword.text!)
                        
                        self.performSegue(withIdentifier: "signUpComplete", sender: nil)
                        
                    }
                
                })
            }
            
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textEntered(_ sender: AnyObject) {
        
        if ((userName.text?.characters.count)! > 0 && (userEmail.text?.characters.count)! > 0 && (accountPassword.text?.characters.count)! > 0 && (retypePassword.text?.characters.count)! > 0){
            
            signUpButton.isEnabled = true
        
        }else{
            signUpButton.isEnabled = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
