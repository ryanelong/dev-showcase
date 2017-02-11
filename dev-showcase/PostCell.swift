//
//  PostCell.swift
//  dev-showcase
//
//  Created by ryan on 2/8/17.
//  Copyright © 2017 ryan. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        
        self.post = post
        
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
                    }
                    
                })
                
                
            }
            
        } else {
            self.showcaseImg.isHidden = true
        }
        
    }

}
