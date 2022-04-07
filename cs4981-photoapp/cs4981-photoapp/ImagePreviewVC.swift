//
//  ImagePreviewVC.swift
//  photosApp2
//
//  Created by Muskan on 10/4/17.
//  Copyright © 2017 akhil. All rights reserved.

//  link: https://www.youtube.com/watch?v=QS2mWk3fAWc
//
//  Modified by Bo-Chen & Jayshaun

import SwiftUI
import Shout

//MARK: ImagePreviewVC
// used in the third collectionView func in ViewController
class ImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var myCollectionView: UICollectionView!
    // [UIImage](): https://stackoverflow.com/questions/24172180/
    var imgArray = [UIImage]()
    var imageNameArray=[String]()
    var passedContentOffset = IndexPath()
    var photoIndex = 0
    
    
    // From UIViewController
    // Def: Called after the controller's view is loaded into memory.
    //link:https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        print("My IPVC viewDidLoad run!")
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor=UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1.0) // UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
        print("My IPVC passedContentOffset is \(passedContentOffset)")
        
        // scrollToItem seems broken and I try all work around but not working
        // see:https://developer.apple.com/forums/thread/663156
        myCollectionView.scrollToItem(at: passedContentOffset, at: .left, animated: true)
        
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        // The things we added
        //
        // the way to add button
        // link:https://stackoverflow.com/questions/24030348/
        let button = UIButton(frame: CGRect(x: 20, y:  UIScreen.screenHeight*0.92, width: 75, height: 30))
        button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.layer.cornerRadius = 10 // https://www.swiftbysundell.com/articles/rounded-corners-uikit-swiftui/
        
        self.view.addSubview(button)
        
        
        self.status.text = "Status: None"
        self.view.addSubview(self.status)
        self.catchError.text = "Error: None"
        self.view.addSubview(self.catchError)
    }
    
    // show current visiblecell
    //link:https://stackoverflow.com/questions/18649920/uicollectionview-current-visible-cell-index
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating run")
        for cell in myCollectionView.visibleCells {
            let indexPath = myCollectionView.indexPath(for: cell)
            print(indexPath)
            photoIndex = indexPath!.row
        }
    }
    
    // From UICollectionViewDataSource, must be implemented in it's subclass
    // Def: Asks your data source object for the number of items in the specified section.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdatasource/1618058-collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("My IPVC collectionView 1 numberOfItemsInSection run!")
        return imgArray.count
    }
    
    // From UICollectionViewDataSource, must be implemente in it's subclass
    // Def: Asks your data source object for the cell that corresponds to the specified item in the collection view.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdatasource/1618029-collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("My IPVC collectionView 2 cellForItemAt run!")
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        print("indexPath: \(indexPath)\nrow: \(indexPath.row)\nend")
        cell.imgView.image=imgArray[indexPath.row]
        
        return cell
    }
    
    // From UIViewController, and it's open
    // Def: Called to notify the view controller that its view is about to layout its subviews.
    //link:https://developer.apple.com/documentation/uikit/uiviewcontroller/1621437-viewwilllayoutsubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("My IPVC viewWillLayoutSubviews run!")
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // From UIViewController, and it's just a func
    // Def: Notifies the container that the size of its view is about to change.
    //link:https://developer.apple.com/documentation/uikit/uicontentcontainer/1621466-viewwilltransition
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("My IPVC viewWillTransition run!")
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    //MARK: =>SSH-Shout
    /*
     var output: UILabel! = UILabel(frame: CGRect(x: 20, y: 500, width: 200, height: 30))
     */
    /*
    //link:https://stackoverflow.com/questions/37574689/
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
     */
    var status: UILabel! = UILabel(frame: CGRect(x: 20, y:  UIScreen.screenHeight*0.83, width: 400, height: 30))
    var catchError: UILabel! = UILabel(frame: CGRect(x: 20, y:  UIScreen.screenHeight*0.865, width: 400, height: 30))
    var ssh: SSH?{
        do{
            let ssh = try SSH(host: ServerData.host)
            try ssh.authenticate(username: ServerData.ur, password: ServerData.pw)
            
            self.status.text = "Status: Connected"
            print("SSH connected!")
            return ssh
        } catch let error{
            print("SSH failed!")
            catchError.text = "Error: \(error.localizedDescription)"
            return nil
        }
    }
    
    // the function added to button
    // link:https://stackoverflow.com/questions/24030348/
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped! The img is \(self.photoIndex)")
        let name = self.imageNameArray[self.photoIndex]
        print("The name is \(name)")
        self.status.text = "Status: test"
        // this url is not correct in our case, since we are trying to send image that in album,
        // instead of image in the Documents
        // let url = self.documentsUrl.appendingPathComponent(name)
        // print("The URL is \(url)")
        do{
            
            let ssh = try SSH(host: ServerData.host)
            try ssh.authenticate(username: ServerData.ur, password: ServerData.pw)
            
            self.status.text = "Status: Connected"
            print("SSH connected!")
            
            self.status.text = "Status: image ready to sent!"
            let sftp = try ssh.openSftp()
            // the original function need rul, which is not attendable for photo in album
            // so we use ther other function that use 'Data' instead of 'URL'
            // try sftp.upload(data: self.imgArray[self.photoIndex].jpegData(compressionQuality: CGFloat(1))!, remotePath: "/home/album/photos/" + name, permissions: FilePermissions(rawValue: 0o644))
            let newName = removeFileExtention(fullname: name) + ".PNG"
            try sftp.upload(data: self.imgArray[self.photoIndex].pngData()!, remotePath: ServerData.location + "photos/" + newName, permissions: FilePermissions(rawValue: 0o644))
            self.status.text = "Status: image sent!"
        }catch let error as SSHError{
            self.status.text = "Status: Error occured!"
            self.catchError.text = "Error: \(error.message)"
            print("Error: \(error.message)")
        } catch let error{
            self.status.text = "Status: Error occured!"
            self.catchError.text = "Error: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func removeFileExtention(fullname: String) -> String {
        if let index = fullname.lastIndex(of: ".") {
            //link:https://stackoverflow.com/questions/39677330/
            let mySubstring = fullname.prefix(upTo: index)
            return String(mySubstring)
        }
        return fullname
    }
}


//MARK: ImagePreviewFullViewCell
class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("My =IPFVC= init run!")
        
        scrollImg = UIScrollView()
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        print("My =IPFVC= handleDoubleTapScrollView run!")
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        print("My =IPFVC= zoomRectForScale run!")
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("My =IPFVC= viewForZooming run!")
        return self.imgView
    }
    
    override func layoutSubviews() {
        print("My =IPFVC= layoutSubviews run!")
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    // From UICollectionViewCell, and it's open
    // Def: Performs any clean up necessary to prepare the view for use again.
    //link:https://developer.apple.com/documentation/uikit/uicollectionreusableview/1620141-prepareforreuse
    override func prepareForReuse() {
        print("My =IPFVC= prepareForReuse run!")
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("My =IPFVC= required init? run!")
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: UIImage ext
// Not used in final implemetation
/*
//link:https://stackoverflow.com/questions/50085231/
extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
*/
