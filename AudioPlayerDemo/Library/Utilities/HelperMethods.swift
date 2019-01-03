//
//  HelperMethods.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 1/3/19.
//  Copyright © 2019 NITV. All rights reserved.
//

import Foundation
import UIKit


class HelperMethods: NSObject {
    
    class func showToastShort(message : String, view: UIView) {
        
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 145, y: view.frame.size.height-100, width: 290, height: 60))
        print(toastLabel)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.9
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    class func showToast(message: String){
        //var toastLabel: UILabel
        
        let toastLabel = UILabel(frame: CGRect.zero)
        let windows = UIApplication.shared.windows.first
        windows?.endEditing(true)
        
        
        toastLabel.backgroundColor = UIColor.darkGray
        toastLabel.textColor = UIColor.white
        toastLabel.text = message
        toastLabel.textAlignment = NSTextAlignment.center
        toastLabel.numberOfLines = 2
        toastLabel.sizeToFit()
        toastLabel.layoutIfNeeded()
        
        let width = toastLabel.frame.width + 50
        let height = toastLabel.frame.height + 10
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if width > UIScreen.main.bounds.width/1.3{
            toastLabel.frame = CGRect(x: UIScreen.main.bounds.width/8, y: UIScreen.main.bounds.height - 2 * height - 100, width: screenWidth - screenWidth/4, height: height * 2)//y: UIScreen.main.bounds.height - 2 * height - 70
        }else{
            
            toastLabel.frame = CGRect(x: screenWidth/2 - width/2 - 20, y: screenHeight - height - 40, width: width+40, height: height+30)
        }
        
        let window = UIApplication.shared.keyWindow
        
        window?.addSubview(toastLabel)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        var dismissDuration : TimeInterval = 3
        
        if message.count > 30{
            dismissDuration = 6
        }else{
            dismissDuration = 4
        }
        
        UIView.animate(withDuration: dismissDuration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            toastLabel.alpha = 0.0
            
        }) { (val) in
            toastLabel.removeFromSuperview()
        }
    }

}
