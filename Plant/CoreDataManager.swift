//
//  CoreDataManager.swift
//  Groupon
//
//  Created by Peter Michael Gits on 2/13/17.
//  Copyright © 2017 GeekGaps.com. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    // MARK: - Core Data stack
    static let sharedInstance = CoreDataManager()
    static let myStoreInstance:String = "Plant"
    
    private lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    public func getManagedObjectModel()->NSManagedObjectModel {
        return self.managedObjectModel;
    }
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: myStoreInstance, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    func preloadDBData()
    {
        let sqlitePath = Bundle.main.path(forResource: CoreDataManager.myStoreInstance, ofType: "sqlite")
        let sqlitePath_shm = Bundle.main.path(forResource: CoreDataManager.myStoreInstance, ofType: "sqlite-shm")
        let sqlitePath_wal = Bundle.main.path(forResource: CoreDataManager.myStoreInstance, ofType: "sqlite-wal")
        
        let URL1 = URL(fileURLWithPath: sqlitePath!)
        let URL2 = URL(fileURLWithPath: sqlitePath_shm!)
        let URL3 = URL(fileURLWithPath: sqlitePath_wal!)
        let URL4 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/" + CoreDataManager.myStoreInstance + ".sqlite")
        let URL5 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/" + CoreDataManager.myStoreInstance + ".sqlite-shm")
        let URL6 = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/" + CoreDataManager.myStoreInstance + ".sqlite-wal")
        
        if !FileManager.default.fileExists(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/" + CoreDataManager.myStoreInstance + ".sqlite") {
            // Copy 3 files
            do {
                try FileManager.default.copyItem(at: URL1, to: URL4)
                try FileManager.default.copyItem(at: URL2, to: URL5)
                try FileManager.default.copyItem(at: URL3, to: URL6)
                
                print("=======================")
                print("FILES COPIED")
                print("=======================")
                
            } catch {
                print("=======================")
                print("ERROR IN COPY OPERATION")
                print("=======================")
            }
        } else {
            print("=======================")
            print("FILES EXIST")
            print("=======================")
        }
    }
    

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent( myStoreInstance + ".sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            // Configure automatic migration.
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        var managedObjectContext: NSManagedObjectContext?
        if #available(iOS 10.0, *){
            
            managedObjectContext = self.persistentContainer.viewContext
        }
        else{
            // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            let coordinator = self.persistentStoreCoordinator
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext?.persistentStoreCoordinator = coordinator
            
        }
        return managedObjectContext!
    }()
    // iOS-10
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: myStoreInstance)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        print("\(self.applicationDocumentsDirectory)")
        return container
    }()
    
    func createUser(userID: String) {
        //1
        let managedContext = self.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entity(forEntityName: "UserDeviceDetails",
                                                 in:managedContext)
        
        let userDeviceDetailsMessage = NSManagedObject(entity: entity!,
                                              insertInto: managedContext) as! UserDeviceDetails
        userDeviceDetailsMessage.userID = userID
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func fetchUserDetails()->UserDeviceDetails? {
        let moc = self.managedObjectContext
        let request = NSFetchRequest<UserDeviceDetails>(entityName: "UserDeviceDetails")
        //request.resultType = UserDeviceDetails
        let idSort = NSSortDescriptor(key: "userID", ascending: true)
        request.sortDescriptors = [idSort]
        do {
            let fetchedUser = try moc.fetch(request)
            
            print(fetchedUser as Any)
            if(fetchedUser.count > 0){
                return fetchedUser[0]
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        let myEmptyDetails:UserDeviceDetails? = nil
        return myEmptyDetails
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
