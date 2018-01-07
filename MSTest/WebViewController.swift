//
//  WebViewController.swift
//  MSTest
//
//  Created by dima on 1/6/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var activityIndicator: NVActivityIndicatorView?
    var fetchedResultsController: NSFetchedResultsController<Article>!
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController(id: id)
       
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25 , y: self.view.center.y - 50, width: 100, height: 100 ) ,
                                     type: .pacman ,
                                    color: .red,
                                  padding: 0)
        activityIndicator?.startAnimating()
        self.view.addSubview(activityIndicator!)
        self.webView.delegate = self
        let data = self.fetchedResultsController.fetchedObjects?.first?.content_article
        let baseUrl = self.fetchedResultsController.fetchedObjects?.first?.content_url
        if data != nil && baseUrl != nil {
            webView.load(data! as Data, mimeType: "text/html", textEncodingName: "", baseURL: URL(string: baseUrl!)!)
        }
        activityIndicator?.stopAnimating()
    }
    
    func initializeFetchedResultsController(id: Int) {
        let request = NSFetchRequest<Article>(entityName: String.NamesOfDataBase.article.rawValue)
        let departmentSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [departmentSort]
        request.predicate = NSPredicate(format: "id == %d", id)
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
    
//MARK: - Actions
    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let object = self.fetchedResultsController.fetchedObjects?.first else {
            fatalError("Attempt to configure cell without a managed object")
        }
        var image = UIImage()
        if object.image_medium != nil {
            image = UIImage(data: object.image_medium! as Data)!
        }
        
        let activityVc = UIActivityViewController(activityItems: [UIImage(data: (object.image_medium as! Data)), object.content_url ?? ""], applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = self.view
        self.present(activityVc, animated: true, completion: nil)
    }
}

//MARK: - UIWebViewDelegate
extension WebViewController : UIWebViewDelegate {
 
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
    }
}
