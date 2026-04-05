
//
//  ShareViewController.swift
//  Sharing Extension
//
//  Created by Kasem Mohamed on 2019-05-30.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
import UIKit
import Social

class ShareViewController: RSIShareViewController {
    
    // Use this method to return false if you don't want to redirect to host app automatically.
    // Default is true
    override func shouldAutoRedirect() -> Bool {
        return true
    }
    
    // Use this to change label of Post button
    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Send"
    }
}
