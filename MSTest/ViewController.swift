//
//  ViewController.swift
//  MSTest
//
//  Created by dima on 1/4/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        return managedContext!
    }()
    
    
    @IBOutlet weak var tableView: MainTableView!
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteAllFromBD()
        //parseAllData()
        tableView.dataSource = tableView
        tableView.delegate   = tableView
        tableView.separatorInset.left = 0
        tableView.separatorInset.top = 0
        tableView.initializeFetchedResultsController()
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 50
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        
    }

    
//MARK: - Work with data base
    
    func showAll() {
        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Article", in: managedObjectContext)
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            print(result.count)
            if (result.count > 0) {
                for person in result {
                    print((person as! NSManagedObject).value(forKey:"title") ?? "none")
                    print((person as! NSManagedObject).value(forKey:"id") ?? "none")
                    print((person as! NSManagedObject).value(forKey:"image_thumb") ?? "none")
                    print((person as! NSManagedObject).value(forKey:"image_medium") ?? "none")
                    print((person as! NSManagedObject).value(forKey:"content_url") ?? "none")
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func deleteAllFromBD() {
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
    }
    
    
    func parseAllData() {
        Alamofire.request("http://madiosgames.com/api/v1/application/ios_test_task/articles", method: .get, encoding: JSONEncoding.default).responseJSON { response in
            do {
                let jsonObj = JSON(response.data!)
                if jsonObj != JSON.null {
                    for obj in jsonObj {
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Article",
                                                                in: self.managedObjectContext)!
                        let person = NSManagedObject(entity: entity,
                                                     insertInto: self.managedObjectContext)
                        person.setValue(obj.1["title"].string, forKey: "title")
                        person.setValue(obj.1["id"].int, forKey: "id")
                        person.setValue(obj.1["content_url"].stringValue, forKey: "content_url")
                        
                        let string = obj.1["image_thumb"].stringValue
                        let string2 = obj.1["image_medium"].stringValue
                        
                        //don't work :(
                        //                        Alamofire.download(obj.1["image_medium"].stringValue).responseData { response in
                        //                            print(response)
                        //
                        //                            if response.result.value != nil {
                        //                                person.setValue(response.result.value, forKey: "image_medium​")
                        //                            }
                        //                        }
                        
                        let url = URL(string: string)
                        let data = try? Data(contentsOf: url!)
                        let image = UIImage(data: data!)
                        let imageData = UIImageJPEGRepresentation(image!, 1)! as NSData
                        person.setValue(imageData, forKey: "image_thumb")
                        
                        
                        let url2 = URL(string: string2)
                        let data2 = try? Data(contentsOf: url2!)
                        let image2 = UIImage(data: data2!)
                        let imageData2 = UIImageJPEGRepresentation(image2!, 1)! as NSData
                        person.setValue(imageData2, forKey: "image_medium")
                        
                        do {
                            try self.managedObjectContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error { print(error.localizedDescription) }
        }
    }
}

