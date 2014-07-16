//
//  ViewController.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        var ypos:Float = 20.0
        let height:Float = 50.0
        for day in items {
            self.view.addSubview(RockerCell.createCell(day, cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos))
            ypos = ypos + height
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

