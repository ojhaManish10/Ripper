//
//  UserProfileViewController.swift
//  Ripper
//
//  Created by Manish Ojha on 10/28/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileViewController: UIViewController {

    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var userImgage: UIImageView!
    @IBOutlet var userNameTitle: UILabel!
    @IBOutlet var profileTableView: UITableView!
    
    
    // The user's ID, unique to the Firebase project.
    // Do NOT use this value to authenticate with your backend server,
    // if you have one. Use getTokenWithCompletion:completion: instead.
    let email = FIRAuth.auth()?.currentUser?.email
    let userId = FIRAuth.auth()?.currentUser?.uid
    
    //To read or write data from the database, you need an instance of FIRDatabaseReference:
    
    let ref = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print("The email of the logged in user is", email!)
        
        
        // Code to retrieve specific data form FIrebase.
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("user_profiles").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["name"] as? String ?? ""
        
            print("The name is", username)
            self.userNameTitle.text = username
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signOut()
        
        // after this user loggs out completely from the application
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "logoutSegue", sender: nil)
        print("user out")
        
    }
    
    
    @IBAction func addProfilePic(_ sender: Any) {
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
