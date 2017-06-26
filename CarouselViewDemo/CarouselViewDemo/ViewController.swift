//
//  ViewController.swift
//  CarouselViewDemo
//
//  Created by ysk on 2017/6/26.
//  Copyright © 2017年 china. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var carouseView: CarouselView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //添加轮播图（代码或者xib均可）
//        let screenWidth = UIScreen.main.bounds.width
//        let carouseView = CarouselView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth / 1920 * 1080))
        carouseView.delegate = self
        self.view.addSubview(carouseView)
        
        carouseView.configWithImageArray([
            "http://cn.bing.com/az/hprichbg/rb/SanLorenzo_ZH-CN7625061136_1920x1080.jpg",
            UIImage(named: "MadagascarLemurs_ZH-CN7754035615_1920x1080")!,
            "http://cn.bing.com/az/hprichbg/rb/HawaiiSwim_ZH-CN7233619332_1920x1080.jpg",
            ])
        carouseView.clickedImageAtIndex { (index) in
            print("closure - 点击了第\(index)张图片")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CarouselViewDelegate {
    func carouselView(_ carouselView: CarouselView, clickImageAtIndex: Int) {
        print("delegate - 点击了第\(clickImageAtIndex)张图片")
    }
}

