//
//  LaunchViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/23/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
    }
    
    override func shouldAutorotate()->Bool {
      return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
    }
 

}
