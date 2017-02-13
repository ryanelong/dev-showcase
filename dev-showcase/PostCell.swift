//
//  PostCell.swift
//  dev-showcase
//
//  Created by ryan on 2/8/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.likeTapped(sender:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true

    }

    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        
        self.post = post
        
        likeRef = DataService.ds.REF_CURRENT_USER.child("likes").child(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                
                self.showcaseImg.image = img
                self.showcaseImg.isHidden = false
                
            } else {
                
                
                request = Alamofire.request(post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { response in
                    
                    if response.error == nil {
                        let img = UIImage(data: response.data!)!
                        self.showcaseImg.image = img
                        self.showcaseImg.isHidden = false
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl! as AnyObject)
                    } else {
                        print(response.error.debugDescription)
                    }
                    
                })
                
                
            }
            
        } else {
            self.showcaseImg.isHidden = true
        }
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
        
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we have not liked this post
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        
        })
        
    }

    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we have not liked this post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(addLike: false)
                self.likeRef.removeValue()
            }
            
        })
        
    }
    
    
}
