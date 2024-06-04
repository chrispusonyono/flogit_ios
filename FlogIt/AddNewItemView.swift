//
//  AddNewItemView.swift
//  FlogIt
//
//  Created by apple on 11/3/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import UIKit
import LocationPicker
import ImagePicker
import ImageLoader
import CoreLocation
import MapKit
import Alamofire
import Toast_Swift
class AddNewItemView: UIViewController, ImagePickerDelegate {
    private var locationData = ""
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        self.images = images
        var at = 0
        for image in images{
            productImages[at].image=image
            at += 1
        }
    }
    
    private var images:[UIImage] = []
    private var productImages = [UIImageView]()
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.images = images
        var at = 0
        for image in images{
            productImages[at].image=image
            at += 1
        }
        
        
    }
    
    @IBOutlet weak var newChecked: UIImageView!
    @IBOutlet weak var newUnChecked: UIImageView!
    @IBOutlet weak var newlabel: UILabel!
    
    
    @IBOutlet weak var usedChecked: UIImageView!
    @IBOutlet weak var usedUnChecked: UIImageView!
    @IBOutlet weak var usedlabel: UILabel!
    
    
    @IBOutlet weak var exchangeChecked: UIImageView!
    @IBOutlet weak var exchangeUnChecked: UIImageView!
    @IBOutlet weak var exchangelabel: UILabel!
    
    @IBOutlet weak var loadingBar: UIActivityIndicatorView!
    @IBOutlet weak var priceEdit: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var productImage1: UIImageView!
    @IBOutlet weak var productImage2: UIImageView!
    @IBOutlet weak var productImage3: UIImageView!
    @IBOutlet weak var productImage4: UIImageView!
    @IBOutlet weak var productImage5: UIImageView!
    @IBOutlet weak var productImage6: UIImageView!
    
    
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productLocation: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    
    
    
    
    
    
    
    fileprivate var alertStyle: UIAlertController.Style = .actionSheet
    var selectedCategory = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func browseImage(_ sender: Any) {
        let configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.recordLocation = false
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 6
        present(imagePickerController, animated: true, completion: nil)
        
    }
    @IBAction func searchLocation(_ sender: Any) {
        let locationPicker = LocationPickerViewController()
        locationPicker.showCurrentLocationButton = true
        locationPicker.currentLocationButtonBackground = .blue
        locationPicker.showCurrentLocationInitially = true
        locationPicker.mapType = .standard
        locationPicker.useCurrentLocationAsHint = true // default: false
        locationPicker.searchBarPlaceholder = "Search places"
        locationPicker.searchHistoryLabel = "Previously searched"
        locationPicker.resultRegionDistance = 500
        locationPicker.completion = { location in
            let data:NSMutableDictionary = NSMutableDictionary()
            data.setValue(location?.address ?? "",  forKey: "productLocation")
            data.setValue(location?.coordinate.longitude ?? "", forKey: "longitude")
            data.setValue(location?.coordinate.latitude ?? "", forKey: "latitude")
            let jsonData = try! JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
            let locate = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            self.productLocation.text=location?.address
            self.locationData = locate
            print(location ?? "default value location")
        }
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func addItem(_ sender: Any) {
        let name = productName.text ?? ""
        let description = productDescription.text ?? ""
        let location = productLocation.text ?? ""
        var price = productPrice.text ?? ""
        
        if name.isEmpty {
            let alert = UIAlertController(title: "Error", message: "product name can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if description.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "description can not be blank", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if location.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "Select a location", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if(selectedCategory==0){
            let alert = UIAlertController(title: "Error", message: "Select category", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if(selectedCategory==1 || selectedCategory==2){
        if price.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "Enter price of your product", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            }
            
        }
        if(selectedCategory==3){
            price="0"
        }
        
            self.view.makeToastActivity(.center)
        
        let parameters = [
            "action": "addProduct",
            "token": UserDefaults.standard.string(forKey: "token") ?? "",
            "name": name,
            "description": description,
            "location": locationData,
            "type": (String(selectedCategory - 1 )) ,
            "price": price
            ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            for image in self.images{
                multipartFormData.append(image.jpegData(compressionQuality: 0.75)!, withName: "icon[]",fileName: "file.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
        to:Constant.URLS.PROJECT)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    self.view.hideToastActivity()
                    print(response)
                    let dataIn = response.result.value as! NSDictionary
                    if((dataIn.value(forKey: "status") as! Bool)){
                        print(dataIn)
                        self.view.makeToast("Product Uploded successfully")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        let alert = UIAlertController(title: "Error", message: dataIn.value(forKey: "message") as? String, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
        
        
        
        
    }
    func initializeView() -> Void {
        productImages = [UIImageView]()
        productImages += [productImage1]
        productImages += [productImage2]
        productImages += [productImage3]
        productImages += [productImage4]
        productImages += [productImage5]
        productImages += [productImage6]
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(AddNewItemView.tap1))
        tap1.numberOfTapsRequired = 1
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(AddNewItemView.tap2))
        tap2.numberOfTapsRequired = 1
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(AddNewItemView.tap3))
        tap3.numberOfTapsRequired = 1
        
        
        newChecked.addGestureRecognizer(tap1)
        newUnChecked.addGestureRecognizer(tap1)
        newlabel.addGestureRecognizer(tap1)
        
        newChecked.isUserInteractionEnabled = true
        newUnChecked.isUserInteractionEnabled = true
        newlabel.isUserInteractionEnabled = true
        
        
        
        usedChecked.addGestureRecognizer(tap2)
        usedUnChecked.addGestureRecognizer(tap2)
        usedlabel.addGestureRecognizer(tap2)
        
        usedChecked.isUserInteractionEnabled = true
        usedUnChecked.isUserInteractionEnabled = true
        usedlabel.isUserInteractionEnabled = true
        
        
        
        
        exchangeChecked.addGestureRecognizer(tap3)
        exchangeUnChecked.addGestureRecognizer(tap3)
        exchangelabel.addGestureRecognizer(tap3)
        
        exchangeChecked.isUserInteractionEnabled = true
        exchangeUnChecked.isUserInteractionEnabled = true
        exchangelabel.isUserInteractionEnabled = true
    }
    
    @objc func tap1(){
        clickedRadio(clicked: 1)
    }
    @objc func tap2(){
        clickedRadio(clicked: 2)
    }
    @objc func tap3(){
        clickedRadio(clicked: 3)
    }
    
    
    
    
    
    
    
    func clickedRadio(clicked : Int) -> Void {
        selectedCategory=clicked
        switch clicked {
        case 1:
            newChecked.isHidden=false
            usedChecked.isHidden=true
            exchangeChecked.isHidden=true
            priceLabel.isHidden=false
            priceEdit.isHidden=false
            
        case 2:
            newChecked.isHidden=true
            usedChecked.isHidden=false
            exchangeChecked.isHidden=true
            priceLabel.isHidden=false
            priceEdit.isHidden=false
        case 3:
            newChecked.isHidden=true
            usedChecked.isHidden=true
            exchangeChecked.isHidden=false
            priceLabel.isHidden=true
            priceEdit.isHidden=true
        default:
            break
        }
        print(clicked)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
