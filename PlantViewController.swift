//
//  PlantViewController.swift
//  Plant
//
//  Created by Kun Huang on 5/30/17.
//  Copyright © 2017 Kun Huang. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PlantViewController: UIViewController, DataEnteredDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: fetch request init
    var fetchRequest: NSFetchRequest<ResourceCategoryEntity> = ResourceCategoryEntity.fetchRequest()
    
    public let persistentContainer = NSPersistentContainer(name: "Plant")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ResourceCategoryEntity> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<ResourceCategoryEntity> = ResourceCategoryEntity.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ResourceCategoryEntity.name), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "(type == 'plant' || type == 'building') && name BEGINSWITH[cd] 'A'")
        //        fetchRequest.predicate = NSPredicate(format: "type == 'plant'")
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: #keyPath(ResourceCategoryEntity.name), cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    var myArray = ["A","B","C","D","E",
                   "F","G","H","I","J",
                   "K","L","M","N","O",
                   "P","Q","R","S","T",
                   "U","V","W","X","Y",
                   "Z", "*"]
    
    var cellColorArray = [Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // init core data sources
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.createResources()
        
        for _ in 0...26 {
            cellColorArray.append(false)
        }
        cellColorArray[0] = true
        
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                self.setupView()
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - View Methods
    public func setupView() {
        
        updateView()
    }
    
    fileprivate func updateView() {
        var hasPlace = false
        
        if let places = fetchedResultsController.fetchedObjects {
            hasPlace = places.count > 0
        }
        
        tableView.isHidden = !hasPlace
    }
    
    // MARK: - Notification Handling
    func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //Mark: DataEnteredDelegate
    func synccellColorArray(info: Array<Bool>) {
        self.cellColorArray = info
        
        for i in 0...26 {
            if(cellColorArray[i] == true){
                collectionView.scrollToItem(at: IndexPath.init(row: i, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                var predicate = NSPredicate()
                var myIndexPath = IndexPath.init(row: i, section: 0)
                if (myIndexPath.row != 26) {
                    predicate = NSPredicate(format: "(type == 'plant' || type == 'building') && name BEGINSWITH[cd] %@",myArray[myIndexPath.row])
                } else {
                    predicate = NSPredicate(format: "(type == 'plant' || type == 'building') && (name BEGINSWITH[cd] '7')")
                }
                
                self.fetchedResultsController.fetchRequest.predicate = predicate
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                tableView.reloadData()
                break
            }
        }
        collectionView.reloadData()
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

extension PlantViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? PlantTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
}

extension PlantViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "plantCell", for: indexPath) as? PlantTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: PlantTableViewCell, at indexPath: IndexPath) {
        // Fetch Quote
        let place = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.plantNameLbl.text = place.name!
        if (place.type == "plant") {
            let countryNameStr = place.plant?.plantAddress?.countryCode
            let flagName = findCountryFlagName(inputStr: countryNameStr!)
            cell.countryFlagImgView.image = UIImage(named: flagName)
        } else {
            cell.countryFlagImgView.image = nil
        }
        
    
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
    
}

extension PlantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //select action
        searchBar.resignFirstResponder()
        let currentPlace = fetchedResultsController.object(at: indexPath)
    
        if (currentPlace.type == "plant") {
//            let lat = currentPlace.plant?.plantAddress?.gpsLatitude
//            let long = currentPlace.plant?.plantAddress?.gpsLongitude
//            let placeStr = (currentPlace.plant?.plantAddress?.city!)! + " " + (currentPlace.plant?.plantAddress?.streetName1!)! + " " + (currentPlace.plant?.plantAddress?.countryCode)!
//            openMapForPlace(lat: lat!, long: long!, placeName: placeStr)
            let plVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
            plVC.currentPlant = currentPlace.plant!
            plVC.cellColorArray = cellColorArray
            plVC.delegate = self
            
            self.navigationController?.pushViewController(plVC, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Alert", message: "No GPS information current", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //open map function
    func openMapForPlace(lat: CLLocationDegrees, long: CLLocationDegrees, placeName: String) {
        
        let myTargetCLLocation:CLLocation = CLLocation(latitude: lat, longitude: long) as CLLocation
        let coordinate = CLLocationCoordinate2DMake(myTargetCLLocation.coordinate.latitude,myTargetCLLocation.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = placeName
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapTypeKey : MKMapType.satellite.rawValue])
        //        mapItem.openInMaps(launchOptions: nil)
        //TODU: change map item image
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
}

extension PlantViewController: UICollectionViewDataSource {
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

extension PlantViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0...26 {
            cellColorArray[i] = false
        }
        cellColorArray[indexPath.row] = true
        collectionView.reloadData()
        
        //Mark: show spefic table view data
        
        var predicate = NSPredicate()
        
        if (indexPath.row != 26) {
            predicate = NSPredicate(format: "(type == 'plant' || type == 'building') && name BEGINSWITH[cd] %@",myArray[indexPath.row])
        } else {
            predicate = NSPredicate(format: "(type == 'plant' || type == 'building') && (name BEGINSWITH[cd] '7')")
        }
        
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        tableView.reloadData()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
    
}

extension PlantViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var predicate:NSPredicate? = nil
        if searchBar.text?.characters.count != 0 {
            predicate = NSPredicate(format: "(name contains [cd] %@) && (type == 'plant' || type == 'building')", searchBar.text!)
        }
        
        self.fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    
}
