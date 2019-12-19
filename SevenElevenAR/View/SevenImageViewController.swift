//
//  SevenImageViewController.swift
//  SevenElevenAR
//
//  Created by 藤井陽介 on 2019/10/04.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit

class SevenImageViewController: UIViewController {


    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscapeLeft
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

