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
import FirebaseStorage
import GoogleSignIn

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userNameTitle: UILabel!
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet var editProfilePic: UIButton!
    @IBOutlet var addProfilePic: UIButton!
    @IBOutlet var profileImageLoader: UIActivityIndicatorView!
    
    //stores the logged in user
    
    
//    // The user's ID, unique to the Firebase project.
//    // Do NOT use this value to authenticate with your backend server,
//    // if you have one. Use getTokenWithCompletion:completion: instead.
//    let email = FIRAuth.auth()?.currentUser?.email
//    let userId = FIRAuth.auth()?.currentUser?.uid
    
    var loggedInUserDetail:AnyObject?
    
    //To read or write data from the database, you need an instance of FIRDatabaseReference:
    
    let databaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.editProfilePic.isHidden = true
        
        self.addProfilePic.isEnabled = true
        
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        
        // Code to retrieve specific data form FIrebase.
        databaseRef.child("User_Profiles").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = (value?["Name"] as! String)
            self.userNameTitle.text = username
        
            self.profileImageLoader.startAnimating()
            if ((value?["Profile_Picture"]) != nil){
                
                let databaseProfilePic = (value?["Profile_Picture"] as! String)
                
                let data = NSData(contentsOf: NSURL(string: databaseProfilePic)! as URL)
                
                self.setProfilePicture(imageView: self.userImage,imageToSet:UIImage(data:data! as Data)!)
                
                self.addProfilePic.isHidden = true
                self.editProfilePic.isHidden = false
                
            }
            self.profileImageLoader.stopAnimating()
            
        }) { (error) in
            print(error.localizedDescription)
        }
  
        // Do any additional setup after loading the view.
    }
    
    internal func setProfilePicture(imageView:UIImageView, imageToSet:UIImage){
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
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
            try firebaseAuth!.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "logoutSegue", sender: nil)
        print("user out")
        
    }
    
    
    @IBAction func addProfilePic(_ sender: Any) {
        profileImagePicker()
    }
    
    
    func profileImagePicker() {

        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedProfileImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
           selectedProfileImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedProfileImageFromPicker = originalImage

        }
        
        if let selectedImage = selectedProfileImageFromPicker{
            userImage.image = selectedImage
        }
        
        addProfilePic.isHidden = true
        editProfilePic.isHidden = false
        
        
        
        //Since the image is in UIImage form we must change it into meta data
        if let imageData: NSData = UIImagePNGRepresentation(selectedProfileImageFromPicker!)! as NSData?{
            
            self.addProfilePic.isEnabled = false
            self.profileImageLoader.startAnimating()
            
            let profilePicStorageRef = storageRef.child("User_Profiles/\(userID!)/Profile_Picture")
            
            profilePicStorageRef.put(imageData as Data, metadata: nil)
            {metadata,Error in
            
                if (Error == nil){
                    let downloadUrl = metadata!.downloadURL()
                    
                    self.databaseRef.child("User_Profiles").child(self.userID!).child("Profile_Picture").setValue(downloadUrl!.absoluteString)
                }else{
                    print("THe shit error is ", Error?.localizedDescription as Any)
                }
                self.profileImageLoader.stopAnimating()
            }
        }
        dismiss(animated: true, completion: nil)
        
        
    }

    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        addProfilePic.isHidden = false
        editProfilePic.isHidden = true
        dismiss(animated: true, completion: nil)
        
        addProfilePic.isHidden = true
        editProfilePic.isHidden = false
    }
    
    
    @IBAction func editProfilePic(_ sender: Any) {
        
        profileImagePicker()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Retrieve cell
        let cellIdentifier: String = "profileCell"
        let myCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        
        databaseRef.child("User_Profiles").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = (value?["Name"] as! String)
            
            myCell.textLabel?.text = username
            
            
        })
        
        return myCell
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
