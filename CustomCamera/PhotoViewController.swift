//
//  PhotoViewController.swift
//  CustomCamera
//
//  Created by Brian Advent on 24/01/2017.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class PhotoViewController: UIViewController {
    
    public enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    
    var takenPhoto:UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Helper Function to encode to Base64
    func encodeImageToBase64(image : UIImage) -> String{
        let imageData : Data = UIImagePNGRepresentation(image)! as Data
        let strBase64 = imageData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        return strBase64
    }
    
    // Compress the Image cuz it's too big lol
    func compressImage (_ image: UIImage) -> UIImage {
        let actualHeight:CGFloat = image.size.height
        let actualWidth:CGFloat = image.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 1024.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show(withStatus: "Processing Image");
    }
    // Actual Code for Camera Shit
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            imageView.image = availableImage

            let compressed = compressImage(availableImage);
            let parameters: Parameters = ["image":encodeImageToBase64(image: compressed)]
            
            Alamofire.request("https://sheltered-falls-15180.herokuapp.com/andre", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                
                                print("Data: \(utf8Text)") // original server data as UTF8 string
                                SVProgressHUD.dismiss();
                                self.createAlert(title: utf8Text, message: "Click Ok to Dismiss");
                }
            }
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func createAlert (title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //CREATING ON BUTTON
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            print ("Ok")
        }))
        
       
        
        self.present(alert, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
