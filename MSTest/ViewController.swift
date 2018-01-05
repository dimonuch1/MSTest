//
//  ViewController.swift
//  MSTest
//
//  Created by dima on 1/4/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //let managedObjectContext = UIApplication.shared.delegate.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Article", in: managedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedContext.fetch(fetchRequest)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

