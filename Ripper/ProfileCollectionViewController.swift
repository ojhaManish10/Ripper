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


class ProfileCollectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet var loader: UIActivityIndicatorView!
    
    
    @IBOutlet var saveButton: MaterialButton!
    @IBOutlet var imageDec: UITextField!
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var collectionView: UICollectionView!

    let userID = FIRAuth.auth()?.currentUser?.uid
    var imagesArray = [AnyObject]()
    var loggedInUser: AnyObject?
    var loggedInUserData: AnyObject?
    var collections = [Collection]()
    var databaseRef = FIRDatabase.database().reference()
    var imageSelected = false
    
    //create a unique auto generated key from firebase database
    let key = FIRDatabase.database().reference().child("Image_Collection").childByAutoId().key

    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loader.startAnimating()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //get all the collection that are saved by the user
            self.collections.removeAll()
            DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots{
                    if let collDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let collection = Collection(postKey: key, dictionary: collDict)
                        
                        
                        
                        self.collections.append(collection)
                        
                        print("MANISH 1:", self.collections.count)
                    }
                }
            }
                self.loader.stopAnimating()
                
            self.collectionView.reloadData()
        })
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("MANISH:", collections.count)
        return collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collection = collections[indexPath.row]
        
        let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollection", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        
        let url = NSURL(string: collection.imageUrl)
        let data = NSData(contentsOf: url as! URL)
        cell.collectionImage.image = UIImage(data: data as! Data)
        return cell
        
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
        imageSelected = true
    
    }
    
    @IBAction func makePost(_ sender: Any) {
        
        loader.startAnimating()
        var imagesArray = [AnyObject]()
        imagesArray.append(showImage.image!)
        
        let decLength = imageDec.text?.characters.count
        let numImages = imagesArray.count //to store the number of images
        
        
        let storageRef = FIRStorage.storage().reference()
        //creating a reference for the exact location for storing the imgae
        let pictureStorageRef = storageRef.child("User_Profiles/\(userID!)/media/\(key)")
        
        //reduce resolution of selected picture
        
        //user has entered text and an image
        if(decLength!>0 && imageSelected == true)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/Image_Collection/\(self.userID!)/\(self.key)/text":self.imageDec.text!,
                                        "/Image_Collection/\(self.userID!)/\(self.key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Image_Collection/\(self.userID!)/\(self.key)/picture":downloadUrl!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
            }
         
        }
            
        //user has entered only text
        else if(imageSelected == false)
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
                        "/Image_Collection/\(self.userID!)/\(self.key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/Image_Collection/\(self.userID!)/\(self.key)/picture":downloadUrl!.absoluteString]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
                
            }
        }
        
        imageDec.text = ""
        imageSelected = false
        showImage.image = UIImage(named: "Camera")
        
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
