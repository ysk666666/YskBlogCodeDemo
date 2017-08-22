//
//  BViewController.swift
//  YRouterSwiftDemo
//
//  Created by ysk on 2017/6/25.
//  Copyright © 2017年 china. All rights reserved.
//

import UIKit

class BViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "B"
    }
    @IBAction func backButtonTarget(_ sender: Any) {
        let method = (self.parameter as? [String: String])?["method"] ?? ""
        if method == "push" {
            self.ynav.popViewController(animated: true)
            self.returnClosure?("push的回调返回值")//回调的所有数据放在这
        } else if method == "present" {
            self.ynav.dismiss(animated: true, completion: { 
                
            })
            self.returnClosure?("present的回调返回值")
        }
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
