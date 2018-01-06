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

    var url = ""
    var indexPath = IndexPath()
    
    @IBOutlet weak var webView: UIWebView!
    
    var activityIndicator: NVActivityIndicatorView?
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25 , y: self.view.center.y - 50, width: 100, height: 100 ) ,
                                     type: .pacman ,
                                    color: .red,
                                  padding: 0)
        activityIndicator?.startAnimating()
        self.view.addSubview(activityIndicator!)
        self.webView.delegate = self
        if self.isInternetAvailable() {
            if let urla = URL(string: url) {
                let request = URLRequest(url: urla)
                webView.loadRequest(request)
            }
        } else {
            showAlertWithOutInternet()
            activityIndicator?.stopAnimating()
        }
        
    }
    
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        initializeFetchedResultsController()
        guard let object = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        let activityVc = UIActivityViewController(activityItems: [UIImage(data: object.image_medium! as Data) ?? nil, url], applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = self.view
        self.present(activityVc, animated: true, completion: nil)
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


extension WebViewController : UIWebViewDelegate {
 
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    
    }
}
