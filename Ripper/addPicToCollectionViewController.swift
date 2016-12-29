//
//  addPicToCollectionViewController.swift
//  Ripper
//
//  Created by Manish Ojha on 12/24/16.
//  Copyright © 2016 Manish Ojha. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class addPicToCollectionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var loggedInUser: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet var imageDesTextView: UITextView!
    @IBOutlet var addPicToolbar: UIToolbar!
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    
    //variable to store initial value of the tool bar bottom
    var initialValueofBottomConstraints = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //hide the toolbar first
        addPicToolbar.isHidden = true
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        imageDesTextView.text = "Say Something about the picture..."
        imageDesTextView.textColor = UIColor.gray
    }

    override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        
        self.initialValueofBottomConstraints = toolbarBottomConstraint.constant
    }
    
    //function to notify when the keyboard will open and close
    fileprivate func enableKeyboardHideOnTap(){
        
        //Set up two observers when the keyboard is shown or hidden
        
        //1st notification
        NotificationCenter.default.addObserver(self, selector: #selector(addPicToCollectionViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //2nd notification
        NotificationCenter.default.addObserver(self, selector: #selector(addPicToCollectionViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //adding a tap gesture recongniser in the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPicToCollectionViewController.hideKeyboard))
        
        //adding to the view
        self.view.addGestureRecognizer(tap)
        
    }
    
    //Notification 1
    func keyboardWillShow(_ notification: Notification)
    {
        let info = (notification as NSNotification).userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            
            self.addPicToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    //Notification 2
    func keyboardWillHide(_ notification: Notification)
    {
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraint.constant = self.initialValueofBottomConstraints
            
            self.addPicToolbar.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImage(_ sender: UIBarButtonItem) {
        
         //open the photo gallery
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        
    }
 
    //after user has picked an image from photo gallery, this function will be called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //var selectedProfileImageFromPicker: UIImage?
        
        //Adding image using the attributed string
        //Attaches meadia with the text
        var attributedString = NSMutableAttributedString()
        
        //checking whether the user has choose image before writing something
        //if first written then attaching the text with the image else showing the message as before
        if (self.imageDesTextView.text.characters.count>0) {
            attributedString = NSMutableAttributedString(string:self.imageDesTextView.text)
        }else{
            attributedString = NSMutableAttributedString(string:"Say Something about the picture...\n")
        }
        
        //this will allow to attach image to the text and put it in the attributed string
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        
        //get the width of the original image
        let oldWidth:CGFloat = textAttachment.image!.size.width
        
        //setting the image to the size it fits below the textfield
        let scaleFactor: CGFloat = oldWidth/(imageDesTextView.frame.size.width-0)
        
        //setting the image of the text attachment
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        //creating an attributed string with text attachment that has image inside it
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attrStringWithImage)
        
        imageDesTextView.attributedText = attributedString
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
      
    }

    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        var imagesArray = [AnyObject]()
        
        //extract the images from the attributed text
        self.imageDesTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.imageDesTextView.text.characters.count), options: []) { (value, range, true) in
            
            //determine if we got image or not
            if(value is NSTextAttachment)
            {
                let attachment = value as! NSTextAttachment
                var image : UIImage? = nil
                
                if(attachment.image !== nil)
                {
                    image = attachment.image!
                    imagesArray.append(image!)
                }
                else
                {
                    print("No image found")
                }
            }
        }
        
        let decLength = imageDesTextView.text.characters.count
        let numImages = imagesArray.count //to store the number of images
        
        //create a unique auto generated key from firebase database
        let key = self.databaseRef.child("image_description").childByAutoId().key
        
        let storageRef = FIRStorage.storage().reference()
        //creating a reference for the exact location for storing the imgae
        let pictureStorageRef = storageRef.child("User_Profiles/\(self.loggedInUser!.uid!)/media/\(key)")
        
        //reduce resolution of selected picture
        
        //user has entered text and an image
        if(decLength>0 && numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            
            pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/image_description/\(self.loggedInUser!.uid!)/\(key)/text":self.imageDesTextView.text,
                                        "/image_description/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/image_description/\(self.loggedInUser!.uid!)/\(key)/picture":downloadUrl!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
                
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        //user has entered only text
        else if(decLength>0)
        {
            let childUpdates = ["/image_description/\(self.loggedInUser!.uid!)/\(key)/text":imageDesTextView.text,
                                "/image_description/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(Date().timeIntervalSince1970)"] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
            
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
                        "/image_description/\(self.loggedInUser!.uid)/\(key)/timestamp":"\(Date().timeIntervalSince1970)",
                        "/image_description/\(self.loggedInUser!.uid)/\(key)/picture":downloadUrl!.absoluteString]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
                
            }
            
            dismiss(animated: true, completion: nil)
            
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
