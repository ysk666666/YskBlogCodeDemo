//
//  YRouterNavigationController.swift
//  JobIN
//
//  Created by ysk on 2017/4/28.
//  Copyright © 2017年 ysk. All rights reserved.
//

import UIKit

class YRouterNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    convenience init(rootControllerURL: URL, title: String, parameter: Any? = nil) {
        let rootVC = YRouterNavigationController.viewControllerForURL(rootControllerURL, parameter: parameter)
        rootVC.title = title
        self.init(rootViewController: rootVC)
        rootVC.ynav = self
    }
    
    class func viewControllerForURL(_ url: URL, parameter: Any?) -> UIViewController {
        guard var className = url.host else {
            print("URL不符合规则")
            return UIViewController()
        }
        className = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String) + "." + className
        let aClass = NSClassFromString(className) as! UIViewController.Type
        let vc = aClass.init()
        vc.url = url
        vc.parameter = parameter
        return vc
    }
    
    @discardableResult func openURLString(_ urlString: String, parameter: Any?) -> UIViewController {
        guard let url = URL(string: urlString) else {
            return UIViewController()
        }
        let vc = YRouterNavigationController.viewControllerForURL(url, parameter: parameter)
        vc.ynav = self
        vc.hidesBottomBarWhenPushed = true
        self.pushViewController(vc, animated: true)
        return vc
    }
    
    @discardableResult func presentURLString(_ urlString: String, parameter: Any?) -> UIViewController {
        guard let url = URL(string: urlString) else {
            return UIViewController()
        }
        let vc = YRouterNavigationController.viewControllerForURL(url, parameter: parameter)
        let nav = YRouterNavigationController(rootViewController: vc)
        vc.ynav = nav
        self.present(nav, animated: true) { 
            
        }
        return vc
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

private var parameterKey: UInt8 = 0
private var urlKey: UInt8 = 1
private var ynavKey: UInt8 = 2
private var returnClosureKey: UInt8 = 0
extension UIViewController {
    var parameter: Any? {
        get {
            return objc_getAssociatedObject(self, &parameterKey)
        }
        set {
            objc_setAssociatedObject(self, &parameterKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    var url: URL {
        get {
            return objc_getAssociatedObject(self, &urlKey) as! URL
        }
        set {
            objc_setAssociatedObject(self, &urlKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    var ynav: YRouterNavigationController! {
        get {
            return objc_getAssociatedObject(self, &ynavKey) as! YRouterNavigationController!
        }
        set {
            objc_setAssociatedObject(self, &ynavKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func popToPreviousController() -> Void {
        self.ynav.popViewController(animated: true)
    }
    
    typealias ReturnInfoClosure = ((_ returnObject: Any) -> Void)
    var returnClosure: ReturnInfoClosure? {
        get {
            return objc_getAssociatedObject(self, &returnClosureKey) as? ReturnInfoClosure
        }
        set {
            objc_setAssociatedObject(self, &returnClosureKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    func getReturnClosure(_ closure: @escaping ReturnInfoClosure) -> Void {
        self.returnClosure = closure
    }
}
