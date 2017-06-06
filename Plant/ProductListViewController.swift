//
//  ProductListViewController.swift
//  Plant
//
//  Created by Kun Huang on 6/2/17.
//  Copyright © 2017 Kun Huang. All rights reserved.
//

import UIKit
import CoreData

protocol DataEnteredDelegate: class {
    func synccellColorArray(info: Array<Bool>)
}

class ProductListViewController: UIViewController {
    
    weak var delegate: DataEnteredDelegate? = nil
    
    var popUpView: UIView!
    var titleLbl: UILabel!
    var nameLbl: UILabel!
    var descLbl: UILabel!
    var statusLbl: UILabel!
    var regionLbl: UILabel!
    var countryLbl: UILabel!
    var sopLbl: UILabel!
    var eopLbl: UILabel!
    var blurEffectView: UIVisualEffectView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productListLabel: UILabel!
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var currentPlant : PlantEntity  = PlantEntity()
    var products: [ProductEntity] = [ProductEntity]()
    var selectProduct : ProductEntity = ProductEntity()
    var filteredProducts: [ProductEntity] = [ProductEntity]()
    
    var myArray = ["A","B","C","D","E",
                   "F","G","H","I","J",
                   "K","L","M","N","O",
                   "P","Q","R","S","T",
                   "U","V","W","X","Y",
                   "Z", "*"]
    
    var cellColorArray = [Bool]()
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Mark - popUpView
        popUpView = UIView(frame: CGRect(x: 10, y: self.view.frame.height/2 - 240, width: self.view.frame.width-20, height: 480))
        popUpView.isHidden = true
        
        products = Array(self.currentPlant.products?.allObjects as! [ProductEntity])
        filteredProducts = products
        
        productListLabel.text = self.currentPlant.name;
        let countryNameStr = self.currentPlant.plantAddress?.countryCode!
        let flagName = findCountryFlagName(inputStr: countryNameStr!)
        countryFlagImg.image = UIImage(named: flagName)
        
        self.navigationController?.isNavigationBarHidden=false
        self.navigationController?.navigationItem.hidesBackButton = false
       

        
        collectionView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        for i in 0...26 {
            if(cellColorArray[i] == true){
                collectionView.scrollToItem(at: IndexPath.init(row: i, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                collectionView.reloadData()
                break
            }
        }
        
    }
    
    //Mark - set up pop up view
    func loadCustomViewIntoController()
    {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //        blurEffectView.frame = CGRect(x: 0, y: self.view.frame.height/2 - 260, width: self.view.frame.width, height: 520)
        blurEffectView.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.height - 90)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        if (popUpView.superview == self.view) {
            titleLbl.text = selectProduct.programName!
            nameLbl.text = selectProduct.product!
            descLbl.text = selectProduct.productModel
            statusLbl.text = selectProduct.customerGroup
            regionLbl.text = selectProduct.plant?.region
            countryLbl.text = selectProduct.plant?.plantAddress?.countryCode
            sopLbl.text = dateFormatter.string(from: selectProduct.productSOP! as Date)
            eopLbl.text = dateFormatter.string(from: selectProduct.productEOP! as Date)
            popUpView.superview?.bringSubview(toFront: popUpView)
            
            self.popUpView.isHidden = false
        } else {
            popUpView.backgroundColor = UIColor.white
            popUpView.layer.borderWidth = 1
            popUpView.layer.borderColor = UIColor.lightGray.cgColor
            
            popUpView.layer.cornerRadius = 25
            popUpView.layer.masksToBounds = true
            popUpView.isHidden = false
            
            // any other objects should be tied to this view as superView
            // for example adding this okayButton
            let okayButton = UIButton(frame: CGRect(x:popUpView.frame.width-45 , y: 15, width: 25, height: 25))
            okayButton.setImage(UIImage(named: "Close"), for: .normal)
            
            // here we are adding the button its superView
            popUpView.addSubview(okayButton)
            okayButton.addTarget(self, action: #selector(okButtonImplementation(button:)), for: .touchUpInside)
            
            let popupViewWidth = self.popUpView.frame.width
            
            let greenImgView = UIImageView(frame: CGRect(x: 40, y: 20, width: 20, height: 20))
            greenImgView.image = UIImage(named: "Greenselect")
            popUpView.addSubview(greenImgView)
            titleLbl = UILabel(frame: CGRect(x: 70, y: 15, width: popupViewWidth - 100, height: 30))
            titleLbl.text = selectProduct.programName
            titleLbl.numberOfLines = 0
            titleLbl.textAlignment = .center
            popUpView.addSubview(titleLbl)
            let titleLine = UIImageView(frame: CGRect(x: 0, y: 59, width: popupViewWidth, height: 1))
            titleLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(titleLine)
            
            let nameNLbl = UILabel(frame: CGRect(x: 10, y: 75, width: 95, height: 30))
            nameNLbl.text = "Product:"
            nameNLbl.textAlignment = .left
            nameNLbl.textColor = UIColor.lightGray
            popUpView.addSubview(nameNLbl)
            nameLbl = UILabel(frame: CGRect(x: 120, y: 75, width: popupViewWidth-120, height: 30))
            nameLbl.text = selectProduct.product
            nameLbl.textAlignment = .left
            popUpView.addSubview(nameLbl)
            let nameLine = UIImageView(frame: CGRect(x: 0, y: 119, width: popupViewWidth, height: 1))
            nameLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(nameLine)
            
            
            let descdescLbl = UILabel(frame: CGRect(x: 10, y: 135, width: 95, height: 30))
            descdescLbl.text = "Model:"
            descdescLbl.textAlignment = .left
            descdescLbl.textColor = UIColor.lightGray
            popUpView.addSubview(descdescLbl)
            descLbl = UILabel(frame: CGRect(x: 120, y: 120, width: popupViewWidth-120, height: 55))
            descLbl.numberOfLines = 0
            descLbl.font = descLbl.font.withSize(15)
            descLbl.text = selectProduct.productModel
            descLbl.textAlignment = .left
            popUpView.addSubview(descLbl)
            let descLine = UIImageView(frame: CGRect(x: 0, y: 179, width: popupViewWidth, height: 1))
            descLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(descLine)
            
            let statusTaLbl = UILabel(frame: CGRect(x: 10, y: 195, width: 95, height: 30))
            statusTaLbl.text = "Customer:"
            statusTaLbl.textAlignment = .left
            statusTaLbl.textColor = UIColor.lightGray
            popUpView.addSubview(statusTaLbl)
            statusLbl = UILabel(frame: CGRect(x: 120, y: 195, width: popupViewWidth-120, height: 30))
            statusLbl.numberOfLines = 0
            statusLbl.text = selectProduct.customerGroup
            statusLbl.textAlignment = .left
            popUpView.addSubview(statusLbl)
            let statusLine = UIImageView(frame: CGRect(x: 0, y: 239, width: popupViewWidth, height: 1))
            statusLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(statusLine)
            
            let regionRgLbl = UILabel(frame: CGRect(x: 10, y: 255, width: 95, height: 30))
            regionRgLbl.text = "Region:"
            regionRgLbl.textAlignment = .left
            regionRgLbl.textColor = UIColor.lightGray
            popUpView.addSubview(regionRgLbl)
            regionLbl = UILabel(frame: CGRect(x: 120, y: 255, width: popupViewWidth-120, height: 30))
            regionLbl.numberOfLines = 0
            regionLbl.text = selectProduct.plant?.region
            regionLbl.textAlignment = .left
            popUpView.addSubview(regionLbl)
            let regionLine = UIImageView(frame: CGRect(x: 0, y: 299, width: popupViewWidth, height: 1))
            regionLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(regionLine)
            
            let countryCTLbl = UILabel(frame: CGRect(x: 10, y: 315, width: 95, height: 30))
            countryCTLbl.text = "Country:"
            countryCTLbl.textAlignment = .left
            countryCTLbl.textColor = UIColor.lightGray
            popUpView.addSubview(countryCTLbl)
            countryLbl = UILabel(frame: CGRect(x: 120, y: 315, width: popupViewWidth-120, height: 30))
            countryLbl.numberOfLines = 0
            countryLbl.text = selectProduct.plant?.plantAddress?.countryCode
            countryLbl.textAlignment = .left
            popUpView.addSubview(countryLbl)
            let countryLine = UIImageView(frame: CGRect(x: 0, y: 359, width: popupViewWidth, height: 1))
            countryLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(countryLine)
            
            let sopSLbl = UILabel(frame: CGRect(x: 10, y: 375, width: 95, height: 30))
            sopSLbl.text = "SOP:"
            sopSLbl.textAlignment = .left
            sopSLbl.textColor = UIColor.lightGray
            popUpView.addSubview(sopSLbl)
            sopLbl = UILabel(frame: CGRect(x: 120, y: 375, width: popupViewWidth-120, height: 30))
            sopLbl.numberOfLines = 0
            sopLbl.text = dateFormatter.string(from: selectProduct.productSOP! as Date)
            sopLbl.textAlignment = .left
            popUpView.addSubview(sopLbl)
            let sopLine = UIImageView(frame: CGRect(x: 0, y: 419, width: popupViewWidth, height: 1))
            sopLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(sopLine)
            
            let eopELbl = UILabel(frame: CGRect(x: 10, y: 435, width: 95, height: 30))
            eopELbl.text = "EOP:"
            eopELbl.textAlignment = .left
            eopELbl.textColor = UIColor.lightGray
            popUpView.addSubview(eopELbl)
            eopLbl = UILabel(frame: CGRect(x: 120, y: 435, width: popupViewWidth-120, height: 30))
            eopLbl.numberOfLines = 0
            eopLbl.text = dateFormatter.string(from: selectProduct.productEOP! as Date)
            eopLbl.textAlignment = .left
            popUpView.addSubview(eopLbl)
            let eopLine = UIImageView(frame: CGRect(x: 0, y: 479, width: popupViewWidth, height: 1))
            eopLine.image = UIImage(named: "Linedivide%406px")
            popUpView.addSubview(eopLine)
            
            self.view.addSubview(popUpView)
            
        }
    }
    
    
    func okButtonImplementation(button:UIButton)
    {
        // do whatever you want
        // make view disappears again, or remove from its superview
        self.popUpView.isHidden = true
        self.blurEffectView.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Mark find coutry flag name
    func findCountryFlagName(inputStr: String) -> (String){
        if(inputStr.contains("China") || inputStr.contains("CN") || inputStr.contains("CHINA")){
            return "China"
        }else if (inputStr.contains("TBD")) {
            return ""
        }else if (inputStr.contains("Unknown") || inputStr.contains("UNKNOWN")) {
            return ""
        }else if (inputStr.contains("Argentina")) {
            return "Argentina"
        }else if (inputStr.contains("Austria")) {
            return "Austria"
        }else if (inputStr.contains("Belgium")) {
            return "Belgium"
        }else if (inputStr.contains("Brazil") || inputStr.contains("Braz") || inputStr.contains("Gravatai")) {
            return "Brazil"
        }else if (inputStr.contains("Canada") || inputStr.contains("ON") || inputStr.contains("ONT")) {
            return "Canada"
        }else if (inputStr.contains("Czech Republic") || inputStr.contains("CZ") || inputStr.contains("Czech Rep") || inputStr.contains("Czech") || inputStr.contains("Straz pod Ralskem")) {
            return "Czech Republic"
        }else if (inputStr.contains("EU")) {
            return "EU"
        }else if (inputStr.contains("France")) {
            return "France"
        }else if (inputStr.contains("Germany") || inputStr.contains("Kaiserslautern") || inputStr.contains("Rockenhausen") || inputStr.contains("Kirchheim")) {
            return "Germany"
        }else if (inputStr.contains("Hungary")) {
            return "Hungary"
        }else if (inputStr.contains("India")) {
            return "India"
        }else if (inputStr.contains("Indonesia")) {
            return "Indonesia"
        }else if (inputStr.contains("Italy")) {
            return "Italy"
        }else if (inputStr.contains("Japan")) {
            return "Japan"
        }else if (inputStr.contains("Lesotho")) {
            return "Lesotho"
        }else if (inputStr.contains("Macedonia")) {
            return "Macedonia"
        }else if (inputStr.contains("Malaysia")) {
            return "Malaysia"
        }else if (inputStr.contains("Mexico") || inputStr.contains("MX") || inputStr.contains("Mex")) {
            return "Mexico"
        }else if (inputStr.contains("Netherlands")) {
            return "Netherlands"
        }else if (inputStr.contains("Poland") || inputStr.contains("Skarbimierz") || inputStr.contains("Swiebodzin")) {
            return "Poland"
        }else if (inputStr.contains("Portugal")) {
            return "Portugal"
        }else if (inputStr.contains("Romania") || inputStr.contains("RO")) {
            return "Romania"
        }else if (inputStr.contains("Russia")) {
            return "Russia"
        }else if (inputStr.contains("Serbia")) {
            return "Serbia"
        }else if (inputStr.contains("Slovakia")) {
            return "Slovakia"
        }else if (inputStr.contains("Slovenia")) {
            return "Slovenia"
        }else if (inputStr.contains("South Africa") || inputStr.contains("South Af") || inputStr.contains("S Africa") || inputStr.contains("ZA")) {
            return "South Africa"
        }else if (inputStr.contains("South korea") || inputStr.contains("Korea") || inputStr.contains("South Korea")) {
            return "South korea"
        }else if (inputStr.contains("Spain") || inputStr.contains("Calatorao")) {
            return "Spain"
        }else if (inputStr.contains("Sweden")) {
            return "Sweden"
        }else if (inputStr.contains("Thailand")) {
            return "Thailand"
        }else if (inputStr.contains("Turkey")) {
            return "Turkey"
        }else if (inputStr.contains("UK") || inputStr.contains("United Kingdom") || inputStr.contains("Halewood")) {
            return "UK"
        }else if (inputStr.contains("Venezuela")) {
            return "Venezuela"
        }else if (inputStr.contains("Vietnam")) {
            return "Vietnam"
        }else if (
            inputStr.contains("AL") ||
                inputStr.contains("AK") ||
                inputStr.contains("AZ") ||
                inputStr.contains("AR") ||
                inputStr.contains("CA") ||
                inputStr.contains("CO") ||
                inputStr.contains("CT") ||
                inputStr.contains("DE") ||
                inputStr.contains("DC") ||
                inputStr.contains("FL") ||
                inputStr.contains("GA") ||
                inputStr.contains("HI") ||
                inputStr.contains("ID") ||
                inputStr.contains("IL") ||
                inputStr.contains("IN") ||
                inputStr.contains("IA") ||
                inputStr.contains("KS") ||
                inputStr.contains("KY") ||
                inputStr.contains("LA") ||
                inputStr.contains("ME") ||
                inputStr.contains("MD") ||
                inputStr.contains("MA") ||
                inputStr.contains("MI") ||
                inputStr.contains("MN") ||
                inputStr.contains("MS") ||
                inputStr.contains("MO") ||
                inputStr.contains("MT") ||
                inputStr.contains("NE") ||
                inputStr.contains("NV") ||
                inputStr.contains("NH") ||
                inputStr.contains("NJ") ||
                inputStr.contains("NM") ||
                inputStr.contains("NY") ||
                inputStr.contains("NC") ||
                inputStr.contains("ND") ||
                inputStr.contains("OH") ||
                inputStr.contains("OK") ||
                inputStr.contains("OR") ||
                inputStr.contains("PA") ||
                inputStr.contains("RI") ||
                inputStr.contains("SC") ||
                inputStr.contains("SD") ||
                inputStr.contains("TN") ||
                inputStr.contains("TX") ||
                inputStr.contains("UT") ||
                inputStr.contains("VT") ||
                inputStr.contains("VA") ||
                inputStr.contains("WA") ||
                inputStr.contains("WV") ||
                inputStr.contains("WI") ||
                inputStr.contains("WY") ||
                inputStr.contains("USA") ||
                inputStr.contains("Eldon")
            ){
            return "USA"
        }else{
            return "";
        }
        
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

extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        
        let product = filteredProducts[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: product.productSOP! as Date)
        let endYear = calendar.component(.year, from: product.productEOP! as Date)
        
        let myId = product.programName!
        
        cell.textLabel?.text = myId.appending(" ").appending(String(startYear)).appending(" - ").appending(String(endYear))
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont(name: "Geneva", size: 13.0)
        
        return cell
    }
    
}

extension ProductListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        searchBar.resignFirstResponder()
        self.selectProduct = filteredProducts[indexPath.row]
        loadCustomViewIntoController()
    }
    
}

extension ProductListViewController: UICollectionViewDataSource {
    ///Mark: CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifer = "MyCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifer, for: indexPath) as! MyCollectionViewCell
        cell.myLabel.text = myArray[indexPath.row]
        if(cellColorArray[indexPath.row]){
            cell.myLabel.backgroundColor = UIColor.gray
            cell.myLabel.textColor = UIColor.white
        }else{
            cell.myLabel.backgroundColor = UIColor.white
            cell.myLabel.textColor = UIColor.black
            
        }
        return cell
        
    }
    
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0...26 {
            cellColorArray[i] = false
        }
        cellColorArray[indexPath.row] = true
        collectionView.reloadData()
        
        //Mark: show spefic table view data
        
        tableView.reloadData()
        
        delegate?.synccellColorArray(info: cellColorArray)
        
        // go back to the previous view controller
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
    
}

extension ProductListViewController: UISearchBarDelegate {
    // MARK: - SearchBar Delegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredProducts = products
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let calendar = Calendar.current
        var currentSearchDateComponent = DateComponents()
        currentSearchDateComponent.year = Int(searchText)
        let searchDate = calendar.date(from: currentSearchDateComponent)!
        
        filteredProducts = products.filter({ (searchDate >= $0.productSOP! as Date) && ($0.productEOP! as Date >= searchDate) })
        print(filteredProducts)
        if (searchText == "") {
            filteredProducts = products
        }
        tableView.reloadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
}

