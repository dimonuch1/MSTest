//
//  MainTableView.swift
//  MSTest
//
//  Created by dima on 1/5/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit
import CoreData

class MainTableView: UITableView {

//    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Article> = {
//        // Create Fetch Request
//        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
//        
//        // Configure Fetch Request
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
//        
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//
//        // Create Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
//        
//        // Configure Fetched Results Controller
//        fetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
//        
//        return fetchedResultsController
//    }()
    
    var articles = [Article]() {
        didSet {
            reloadData()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Article>!
    
    func customReloadData() {
        initializeFetchedResultsController()
        self.reloadData()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<Article>(entityName: "Article")
        let departmentSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [departmentSort]
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let moc =  appDelegate?.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

}

//MARK: - UITableViewDataSource
extension MainTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = self.fetchedResultsController?.fetchedObjects
        return (object?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MainTableViewCell
        
        guard let object = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.title.text = object.title
        cell.picture.image = UIImage(data: object.image_medium! as Data)
        
        return cell
    }
}

extension MainTableView: UITableViewDelegate {
    
}

extension ViewController: NSFetchedResultsControllerDelegate {}
