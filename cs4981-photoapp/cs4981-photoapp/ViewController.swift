//
//  ViewController.swift
//  photosApp2
//
//  Created by Muskan on 10/4/17.
//  Copyright © 2017 akhil. All rights reserved.
//
//  link: https://www.youtube.com/watch?v=QS2mWk3fAWc
//
//  Modified by Bo-Chen & Jayshaun

import SwiftUI
import Photos

//MARK: #ViewController
//UIViewController: https://developer.apple.com/documentation/uikit/uiviewcontroller
//UICollectionViewDelegate: https://developer.apple.com/documentation/uikit/uicollectionviewdelegate
//UICollectionViewDataSource: https://developer.apple.com/documentation/uikit/uicollectionviewdatasource
//UICollectionViewDelegateFlowLayout: https://developer.apple.com/documentation/uikit/uicollectionviewdelegateflowlayout
//UINavigationControllerDelegate: https://developer.apple.com/documentation/uikit/uinavigationcontrollerdelegate
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {

    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    var imageNameArray=[String]()
    
    
    
    //MARK: Original
    // From UIViewController
    // Def: Called after the controller's view is loaded into memory.
    //link:https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        print("My viewDidLoad of ViewController run!")
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Album App" // self: UIViewController
        
        let layout = UICollectionViewFlowLayout()
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout) // self: UIViewController
        myCollectionView.delegate=self // self: UICollectionViewDelegate
        myCollectionView.dataSource=self // self: UICollectionViewDataSource
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
            //link: https://swiftrocks.com/whats-type-and-self-swift-metatypes
            // To get a metatype as a value, you need to type the name of that type followed by ".self".
        myCollectionView.backgroundColor=UIColor.white // UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0) //
        self.view.addSubview(myCollectionView) // self: UIViewController
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        grabPhotos()
        
        let button = UIButton(frame: CGRect(x: UIScreen.screenWidth/2+105, y: 600, width: 75, height: 30))
        button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        button.setTitle("Remote", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.layer.cornerRadius = 10

        self.view.addSubview(button)
        
        

    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        // Code from:https://stackoverflow.com/questions/51675063/
        let nav = self.navigationController //grab an instance of the current navigationController
            DispatchQueue.main.async { //make sure all UI updates are on the main thread.
                nav?.view.layer.add(CATransition().popFromRight(), forKey: nil)
                nav?.pushViewController(RemoteControlVC(), animated: false)
            }
    }
    
    //MARK: CollectionView
    // From UICollectionViewDataSource, must be implemented in it's subclass
    // Def: Asks your data source object for the number of items in the specified section.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdatasource/1618058-collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("My collectionView 1 numberOfItemsInSection run!")
        return imageArray.count
    }
    
    // From UICollectionViewDataSource, must be implemente in it's subclass
    // Def: Asks your data source object for the cell that corresponds to the specified item in the collection view.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdatasource/1618029-collectionview
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("My collectionView 2 cellForItemAt run!")
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        // dequeueReusableCell function return UICollectionViewCell
        // and UICollectionViewCell might be able to be down cast to PhotoItemCell
        cell.img.image=imageArray[indexPath.item]
        return cell
    }
    
    // From UICollectionViewDelegate, and it's optional
    // Def: Tells the delegate that the item at the specified index path was selected.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdelegate/1618032-collectionview
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("My collectionView 3 didSelectItemAt run!")
        print(indexPath)
        let vc=ImagePreviewVC()
        vc.imgArray = self.imageArray
        vc.imageNameArray = self.imageNameArray
        vc.passedContentOffset = indexPath
        print("My \(indexPath) is selected")
        // this is the method change the view to other view in think
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // From UICollectionViewDelegateFlowLayout, and it's optional
    // Def: Asks the delegate for the size of the specified item’s cell.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdelegateflowlayout/1617708-collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("My collectionView 4 layout sizeForItemAt run!")
        let width = collectionView.frame.width
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    // From UIViewController, and it's open
    // Def: Called to notify the view controller that its view is about to layout its subviews.
    //link:https://developer.apple.com/documentation/uikit/uiviewcontroller/1621437-viewwilllayoutsubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("My viewWillLayoutSubviews run!")
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // From UICollectionViewDelegateFlowLayout, and it's optional
    // Def: Asks the delegate for the spacing between successive rows or columns of a section.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdelegateflowlayout/1617705-collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("My collectionView 5 layout minimumLineSpacingForSectionAt run!")
        return 1.0
    }
    
    // From UICollectionViewDelegateFlowLayout, and it's optional
    // Def: Asks the delegate for the spacing between successive items in the rows or columns of a section.
    //link:https://developer.apple.com/documentation/uikit/uicollectionviewdelegateflowlayout/1617696-collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("My collectionView 6 layout minimumInteritemSpacingForSectionAt run!")
        return 1.0
    }
    
    //MARK: grab photos
    func grabPhotos(){
        print("My Grab Photos run!")
        imageArray = []
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            let imgManager=PHImageManager.default()
            
            let requestOptions=PHImageRequestOptions()
            requestOptions.isSynchronous=true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions=PHFetchOptions()
            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print("My fetchResult")
            print(fetchResult)
            print("My fetchResult.count")
            print(fetchResult.count)
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                        self.imageNameArray.append(fetchResult.object(at: i).value(forKey: "filename") as! String)

                    })
                }
            } else {
                print("You got no photos.")
            }
            print("imageArray count: \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.myCollectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    //MARK: SSH
    
    @IBAction func sentPicture(_ sender: UIButton) {
        status.text = "Button Pressed"
        catchError.text = "Reset"
        let filename = "IMG_2803.jpeg"
        // let filename = "test.txt"
        
        do{
            let ssh = try SSH(host: "192.168.1.134")
            try ssh.authenticate(username: "album", password: "smart")
            let sftp = try ssh.openSftp()
            status.text = "step 1"
            let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("/Documents/" + filename)
            status.text = "step 2"
            try sftp.upload(localURL: url, remotePath: "/home/album/photos/" + filename, permissions: FilePermissions(rawValue: 0o777))
            // try ssh.sendFile(localURL: url, remotePath: "/home/album/photos/" + filename, permissions: FilePermissions(rawValue: 0o777))
            status.text = "step 3"
            output.text = "Success!"
            // (status.text) = (String(s_l))
            
        } catch let error as SSHError{
            catchError.text = "Error1!"
            output.text = error.message
        } catch let error{
            catchError.text = "Error2!"
            output.text = error.localizedDescription
        }
    }
    // @IBOutlet weak var output: UILabel!
    // @IBOutlet weak var status: UILabel!
    // @IBOutlet weak var catchError: UILabel!
     */
}


//MARK: #PhotoItemCell
class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("My PIC init run!")
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("My PIC layoutSubviews run!")
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("My PIC required init? run!")
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: #DeviceInfo
//statusBarOrientation under UIApplication is Deprecated
//link:https://developer.apple.com/documentation/uikit/uiapplication/1623026-statusbarorientation
struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}
