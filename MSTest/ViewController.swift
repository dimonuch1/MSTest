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
import NVActivityIndicatorView

class ViewController: UIViewController {
    
//MARK: - Property
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        return managedContext!
    }()
    
    @IBOutlet weak var tableView: MainTableView!
    var refreshControl = UIRefreshControl()
    var activityIndicator: NVActivityIndicatorView?
    
//MARK: - Main function
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.alpha = 0
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 50 , y: self.view.center.y - 50, width: 100, height: 100 ) ,
                                     type: .ballScaleMultiple,
                                    color: .red,
                                  padding: 0)
        activityIndicator?.startAnimating()
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
        }

        refresh()
        
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(reloadTable), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data")
        
        tableView.dataSource = tableView
        tableView.separatorInset.left = 0
        tableView.separatorInset.top = 0
        tableView.customReloadData()
    }
    
//MARK: - Helper Method
    func reloadTable() {
        tableView.isUserInteractionEnabled = false
        if self.isInternetAvailable() {
            self.deleteAllFromBD()
            self.parseAllData()
        } else {
            self.showAlertWithOutInternet()
        }
    }
    
    func refresh() {
        if self.isInternetAvailable() {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: String.NamesOfDataBase.article.rawValue)
            do {
                if try managedObjectContext.count(for: fetch) < 1 {
                    parseAllData()
                } else {
                    self.tableView.alpha = 1
                    self.activityIndicator?.stopAnimating()
                }
            }  catch {
                let saveError = error as NSError
                print(saveError)
            }
        } else {
            showAlertWithOutInternet()
            activityIndicator?.stopAnimating()
            refreshControl.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String.Segues.goToWebView.rawValue {
            if sender is MainTableViewCell {
                if let destinationViewController = segue.destination as? WebViewController {
                    destinationViewController.id = (sender as! MainTableViewCell).id
                }
            }
        }
    }
    
    func imageToData(key: String, obj: (String, JSON)) -> NSData? {
        let string = obj.1[key].stringValue
        let url = URL(string: string)
        if url != nil {
            if let data = try? Data(contentsOf: url!) {
                let image = UIImage(data: data)
                if image != nil {
                    return UIImageJPEGRepresentation(image!, 1)! as NSData
                }
            }
        }
        return nil
    }

    
//MARK: - Work with data base
    
    func deleteAllFromBD() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: String.NamesOfDataBase.article.rawValue)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedObjectContext.execute(request)
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    func parseAllData() {
        Alamofire.request("http://madiosgames.com/api/v1/application/ios_test_task/articles", method: .get, encoding: JSONEncoding.default).responseJSON { response in
                let jsonObj = JSON(response.data!)
                if jsonObj != JSON.null {
                    DispatchQueue.global(qos: .utility).async {
                        for obj in jsonObj {
                            
                            let entity = NSEntityDescription.entity(forEntityName: String.NamesOfDataBase.article.rawValue,
                                                                               in: self.managedObjectContext)!
                            let person = NSManagedObject(entity: entity,
                                                     insertInto: self.managedObjectContext)
                            person.setValue(obj.1["title"].string, forKey: "title")
                            person.setValue(obj.1["id"].int, forKey: "id")
                            person.setValue(obj.1["content_url"].stringValue, forKey: "content_url")
                            person.setValue(self.imageToData(key: "image_thumb", obj: obj as (String, JSON)), forKey: "image_thumb")
                            person.setValue(self.imageToData(key: "image_medium", obj: obj as (String, JSON)), forKey: "image_medium")
                            
                            let urla = URL(string: obj.1["content_url"].stringValue)
                            if urla != nil {
                                person.setValue(try? Data(contentsOf: urla!), forKey: "content_article")
                            }
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.customReloadData()
                            self.tableView.alpha = 1
                            self.refreshControl.endRefreshing()
                            self.activityIndicator?.stopAnimating()
                            self.tableView.isUserInteractionEnabled = true
                        }
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
        }
    }
}
