//
//  ProfileCollectionViewController.swift
//  Ripper
//
//  Created by Manish Ojha on 12/23/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileCollectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageDec: UITextField!
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    var loggedInUser: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loggedInUser = FIRAuth.auth()?.currentUser
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        //open the photo gallery
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            //self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }

    }

    //after user has picked an image from photo gallery, this function will be called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    
        showImage.image = image
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func makePost(_ sender: Any) {
        
        loader.startAnimating()
        
        var imagesArray = [AnyObject]()
        imagesArray.append(showImage.image!)
        
        let decLength = imageDec.text?.characters.count
        let numImages = imagesArray.count //to store the number of images
        
        //create a unique auto generated key from firebase database
        let key = self.databaseRef.child("Image_Collection").childByAutoId().key
        
        let storageRef = FIRStorage.storage().reference()
        //creating a reference for the exact location for storing the imgae
        let pictureStorageRef = storageRef.child("User_Profiles/\(self.loggedInUser!.uid!)/media/\(key)")
        
        //reduce resolution of selected picture
        
        //user has entered text and an image
        if(decLength!>0 && numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/Image_Collection/\(self.loggedInUser!.uid!)/\(key)/text":self.imageDec.text!,
                                        "/Image_Collection/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Image_Collection/\(self.loggedInUser!.uid!)/\(key)/picture":downloadUrl!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
            }
         
        }
            
        //user has entered only text
        else if(decLength!>0)
        {
            
            DispatchQueue.main.async(execute: {
                
                // Display alert message with confirmation
                let myAlert = UIAlertController(title: "Error", message:"You have not selected an image.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction (title: "Try Again", style: UIAlertActionStyle.default){
                    action in
                    //self.dismissViewControllerAnimated(true, completion:nil)
                    
                }
                
                myAlert.addAction(okAction)
                self.present(myAlert, animated: true, completion: nil)
            })
            loader.stopAnimating()
        }
            
        //user has entered only an image
        else if(numImages>0)
        {
            
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = [
                        "/Image_Collection/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Image_Collection/\(self.loggedInUser!.uid!)/\(key)/picture":downloadUrl!.absoluteString]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
                
            }
        }
//        loader.stopAnimating()
        loader.stopAnimating()
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
