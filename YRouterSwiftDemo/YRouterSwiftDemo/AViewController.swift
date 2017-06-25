//
//  AViewController.swift
//  YRouterSwiftDemo
//
//  Created by ysk on 2017/6/25.
//  Copyright © 2017年 china. All rights reserved.
//

import UIKit

class AViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func pushButtonTarget(_ sender: Any) {
        self.ynav.openURLString("ysk://BViewController", parameter: ["method": "push"])
    }
    @IBAction func presentButtonTarget(_ sender: Any) {
        self.ynav.presentURLString("ysk://BViewController", parameter: ["method": "present"])
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
