//
//  AppDelegate.swift
//  MSTest
//
//  Created by dima on 1/4/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //http://madiosgames.com/api/v1/application/ios_test_task/articles
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Article", in: managedObjectContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        
        do {
            //delete all
            try managedObjectContext.execute(request)
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
  
        }
        
        
        
        
        
        
        
        
        
        
        

        
        
        
        
        Alamofire.request("http://madiosgames.com/api/v1/application/ios_test_task/articles").responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                //print(swiftyJsonVar)
            }
        }
        
        
        
        
        
        
        Alamofire.request("http://madiosgames.com/api/v1/application/ios_test_task/articles", method: .get, encoding: JSONEncoding.default).responseJSON { response in
            //create entity
            do {
                let jsonObj = JSON(response.data!)
                if jsonObj != JSON.null {
                    for obj in jsonObj {
                    
                        //print(obj )
//                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                                return
//                        }
//                        let managedContext = appDelegate.persistentContainer.viewContext
            
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Article",
                                                       in: self.managedObjectContext)!
            
                        let person = NSManagedObject(entity: entity,
                                                     insertInto: self.managedObjectContext)

                        person.setValue(obj.1["title"].string, forKeyPath: "title")
                        person.setValue(obj.1["id"].int, forKeyPath: "id")
                        person.setValue(obj.1["content_url"].stringValue, forKeyPath: "content_url")
                        
                        //image_medium
                        
                        
                        
                        print(obj.1["image_medium"].stringValue)
                        print(obj.1["image_medium"].stringValue)
                        //print(obj.1["content_url"])
                        
                        
                        
                        
//                        print(obj.1["image_thumb"].stringValue)
                        let string = obj.1["image_thumb"].stringValue
//                        print(string)
//                        print(obj.1["image_thumb"].stringValue)

                       
                        
                        
                        
                        Alamofire.download(obj.1["image_medium"].stringValue).responseData { response in
                            print(response)
                            
                            if response.result.value != nil {
                                person.setValue(response.result.value, forKeyPath: "medium​")
                            }
                        }
                        
                     
                        
                        //image_thumb
//                        guard let path_image_thumb = obj.1["image_thumb​"].string else {
//                            return
//                        }
                       
                        Alamofire.download(obj.1["image_thumb"].stringValue).responseData { response in
                           print(response)
                            if response.result.value != nil {
                                person.setValue(response.result.value, forKeyPath: "thumb​")
                            }
                        }
                       
                        
                        print(obj.1["image_thumb​"].stringValue)
                        //let string = obj.1["image_thumb​"].stringValue
                        //print(string)
                        let url = URL(string: string)
                        print(string)
                        print(url)
                        let data = try? Data(contentsOf: url!)
                        person.setValue(data, forKeyPath: "medium​")
                        print(data)
//
                        do {
                            //try person.managedObjectContext?.save()
                            try self.managedObjectContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }

                        
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error { print(error.localizedDescription) }
            
        }
        
        return true
    }
    
    
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MSTest")
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
        return container
    }()
    
    
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        return managedContext!
    }()
    
    
    

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

