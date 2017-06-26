//
//  CarouselView.swift
//  JobIN
//
//  Created by ysk on 2017/4/21.
//  Copyright © 2017年 ysk. All rights reserved.
//

import UIKit
import Foundation

protocol CarouselViewDelegate: class {
    func carouselView(_ carouselView: CarouselView, clickImageAtIndex: Int) -> Void
}

class CarouselView: UIView, UIScrollViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private var imageArray: Array<Any>! = Array()
    private var images: Array<UIImage> = Array()
    private let currentImageView: UIImageView = { () -> UIImageView in
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()
    private let otherImageView: UIImageView = { () -> UIImageView in
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()
    private let scrollView: UIScrollView = { () -> UIScrollView in
        let sView = UIScrollView()
        sView.scrollsToTop = true
        sView.isPagingEnabled = true
        sView.bounces = false
        sView.showsVerticalScrollIndicator = false
        sView.showsHorizontalScrollIndicator = false
        return sView
    }()
    private let pageControl: UIPageControl = { () -> UIPageControl in
        let pageC = UIPageControl()
        pageC.isUserInteractionEnabled = false
        return pageC
    }()
    private let pageLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .right
        label.frame.size = CGSize(width: 40, height: 24)
        return label
    }()
    
    private var timer: Timer?
    private var currentIndex: UInt = 0
    private var nextIndex: Int = 0
    var autoReversePageTime: Double = 5.0   //默认翻页间隔时间
    var placeholderImage: UIImage = UIImage()   //默认图片
    private static let cachePath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!.appending("/NetImagesCache")
    private var closureTap: ((_ tapedIndex: Int) -> Void)? = nil
    weak var delegate: CarouselViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    private func configView() -> Void {
        self.addSubview(scrollView)
//        self.addSubview(pageControl)  //使用系统UIPageControl
        self.addSubview(pageLabel)  //使用文本框提示页码
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(otherImageView)
        scrollView.delegate = self
        var isDir: ObjCBool = false
        let isExists = FileManager.default.fileExists(atPath: CarouselView.cachePath, isDirectory: &isDir)
        if !isExists || !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(atPath: CarouselView.cachePath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.description)
            }
        }
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CarouselView.tapedScrollView)))
    }
    
    func configWithImageArray(_ imageArray: Array<Any>) -> Void {
        if imageArray.count == 0 {
            return
        }
        self.imageArray = imageArray
        for index in 0 ..< self.imageArray.count {
            let currentImageData = self.imageArray[index]
            if currentImageData is UIImage {
                images.append(currentImageData as! UIImage)
            } else if (currentImageData is String) {
                let imageName = MD5(currentImageData as! String)//缓存图片的名字为其URL的md5值
                let fullPath: URL = URL(string: CarouselView.cachePath)!.appendingPathComponent(imageName)
                if FileManager.default.fileExists(atPath: fullPath.absoluteString) {
                    let imageData: Data = FileManager.default.contents(atPath: fullPath.absoluteString)!
                    images.append(UIImage(data: imageData)!)
                } else {
                    images.append(placeholderImage)
                    downloadImage(UInt(index))
                }
            }
        }
        currentImageView.image = self.images[Int(self.currentIndex)]
        pageControl.numberOfPages = images.count
        let pageControlSize = pageControl.size(forNumberOfPages: images.count)
        let pageControlPoint = CGPoint(x: self.bounds.width * (1 - 0.1) - pageControlSize.width, y: self.bounds.height * (1 - 0.1) - pageControlSize.height)
        pageControl.frame = CGRect(origin: pageControlPoint, size: pageControlSize)
        pageLabel.frame.origin = CGPoint(x: self.bounds.width - 60, y: self.bounds.height - 40)
        pageLabel.text = String(1) + "/" + String(self.imageArray.count)
        layoutSubviews()
    }
    
    func configPageControlWithPageImage(_ image: UIImage, currentPageImage: UIImage, rightToSuper: CGFloat = 0, bottomToSuper: CGFloat = 0) -> Void {
        pageControl.setValue(image, forKey: "_pageImage")
        pageControl.setValue(currentPageImage, forKey: "_currentPageImage")
        let pageControlSize = CGSize(width: image.size.width * CGFloat(pageControl.numberOfPages * 2 - 1), height: image.size.width)
        pageControl.frame = CGRect(origin: CGPoint(x: self.bounds.width - rightToSuper - pageControlSize.width, y: self.bounds.height - bottomToSuper - pageControlSize.height), size: pageControlSize)
    }
    func configPageControlWithPageColor(_ color: UIColor, currentColor: UIColor, currentPageImage: UIImage, rightToSuper: CGFloat = 0, bottomToSuper: CGFloat = 0) -> Void {
        pageControl.pageIndicatorTintColor = color
        pageControl.currentPageIndicatorTintColor = currentColor
        let pageControlSize = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        pageControl.frame = CGRect(origin: CGPoint(x: self.bounds.width - rightToSuper - pageControlSize.width, y: self.bounds.height - bottomToSuper - pageControlSize.height), size: pageControlSize)
    }
    
    func clickedImageAtIndex(_ closure: @escaping (_ tapedIndex: Int) -> Void) -> Void {
        closureTap = closure
    }
    @objc private func tapedScrollView() -> Void {
        closureTap?(Int(currentIndex))
        delegate?.carouselView(self, clickImageAtIndex: Int(currentIndex))
    }
    
    class func cleanDiskCache() -> Void {
        do {
            try FileManager.default.removeItem(atPath: CarouselView.cachePath)
            try FileManager.default.createDirectory(atPath: CarouselView.cachePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    
    private func downloadImage(_ index: UInt) -> Void {
        if index >= UInt(self.imageArray.count) {
            return
        }
        guard let url = URL(string: self.imageArray![Int(index)] as! String) else {
            return
        }
        let imageName = MD5(url.absoluteString)
        let session = URLSession.shared
        let task: URLSessionTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil && (response as? HTTPURLResponse)?.statusCode ?? 400 < 400 {
                let fullPath: URL = URL(string: CarouselView.cachePath)!.appendingPathComponent(imageName)
                FileManager.default.createFile(atPath: fullPath.absoluteString, contents: data, attributes: nil)
                self.images[Int(index)] = UIImage(data: data!)!
                if self.currentIndex == index {
                    self.currentImageView.image = self.images[Int(index)]
                }
            }
        }
        task.resume()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if __CGSizeEqualToSize(CGSize(), scrollView.contentSize) {
            return
        }
        let offsetX = scrollView.contentOffset.x
        if offsetX < self.bounds.width {
            //右滑
            otherImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)//otherImageView放在currentImageView的左边
            nextIndex = Int(currentIndex) - 1
            if nextIndex < 0 {
                nextIndex = images.count - 1
            }
            otherImageView.image = images[nextIndex]
            if offsetX <= 0 {
                changeToNext()
            }
        } else if (offsetX > self.bounds.width) {
            //左滑
            otherImageView.frame = CGRect(x: self.bounds.width * 2, y: 0, width: self.bounds.width, height: self.bounds.height)//otherImageView放在currentImageView的右边
            nextIndex = Int(currentIndex + 1) % images.count
            otherImageView.image = images[self.nextIndex]
            if offsetX >= self.frame.width * 2 {
                changeToNext()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
    
    //修改真正的属性数据
    private func changeToNext() -> Void {
        currentImageView.image = self.otherImageView.image
        scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)//偏移到回到初始的中央
        currentIndex = UInt(self.nextIndex)
        pageControl.currentPage = Int(self.currentIndex)
        pageLabel.text = String(self.currentIndex + 1) + "/" + String(self.imageArray.count)
        layoutSubviews()
    }
    
    //MARK: - ScrollView
    private func setScrollViewContentSize() -> Void {
        if self.images.count > 1 {
            scrollView.contentSize = CGSize(width: self.bounds.width * 3, height: self.bounds.height)
            scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
            currentImageView.frame = CGRect(x: self.bounds.width, y: 0, width: self.bounds.width, height: self.bounds.height)
        } else {
            scrollView.contentSize = CGSize()
            scrollView.contentOffset = CGPoint()
            currentImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        }
        startTimer()
    }
    
    //MARK: - Timer
    private func startTimer() -> Void {
        if self.images.count <= 1 {
            return
        }
        if timer != nil {
            stopTimer()
        }
        timer = Timer(timeInterval: autoReversePageTime, target: self, selector: #selector(CarouselView.autoReverseNextPage), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    private func stopTimer() -> Void {
        timer!.invalidate()
        timer = nil
    }
    @objc private func autoReverseNextPage() -> Void {
        otherImageView.frame = CGRect(x: self.bounds.width * 2, y: 0, width: self.bounds.width, height: self.bounds.height)
        nextIndex = Int(self.currentIndex + 1) % self.images.count
        otherImageView.image = self.images[self.nextIndex]
        scrollView.panGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: 0.75, animations: {
            self.currentImageView.frame.origin.x = 0
            self.otherImageView.frame.origin.x = self.bounds.width
        }) { (finished: Bool) in
            self.scrollView.panGestureRecognizer.isEnabled = true
            self.changeToNext()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        setScrollViewContentSize()
    }

}
