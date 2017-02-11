//
//  FeedVC.swift
//  dev-showcase
//
//  Created by ryan on 2/8/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var postRef: FIRDatabaseReference!
    var posts = [Post]()
    
    var imagePicker: UIImagePickerController!
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 453
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        postRef = FIRDatabase.database().reference().child("posts")
        
        postRef.observe(FIRDataEventType.value, with: { (snapshot) in
            
            print(snapshot.value!)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                
            }
            
            self.tableView.reloadData()
            
        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        //print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureCell(post: post, img: img)
            return cell
        } else {
            return PostCell()
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageSelectorImage.image = selectedImage
        
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(_ sender: Any) {
        
        if let txt = postField.text, txt != "" {
            
            if let img = imageSelectorImage.image {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = URL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "014FKOSV06ed4d96e56881e890b7a50e474da023".data(using: String.Encoding.utf8)!
                let keyJSON = "json".data(using: String.Encoding.utf8)!
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    
                    multipartFormData.append(imgData, withName: "fileupload", fileName: "image.jpg", mimeType: "image/jpg")
                    multipartFormData.append(keyData, withName: "key")
                    multipartFormData.append(keyJSON, withName: "format")
                    
                }, to: url)
                { (result) in
                    
                    switch result {
                    case .success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            print("LINK: \(imgLink)")
                                        }
                                    }
                                }
                            })
                    case .failure(let error):
                        print(error)
                    }
                    
                }
            }
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
}
