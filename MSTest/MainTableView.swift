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

   
    
    
    
    func customReloadData() {
        initializeFetchedResultsController()
        self.reloadData()
    }
    
    var fetchedResultsController: NSFetchedResultsController<Article>!
    
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
        cell.picture.image = UIImage(data: object.image_thumb! as Data)
        cell.url = object.content_url ?? ""
        cell.index = indexPath
        return cell
    }
}

extension MainTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension ViewController: NSFetchedResultsControllerDelegate {}
