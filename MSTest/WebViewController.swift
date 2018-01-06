//
//  WebViewController.swift
//  MSTest
//
//  Created by dima on 1/6/18.
//  Copyright © 2018 dima. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var url = ""
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        if let urla = URL(string: url) {
            let request = URLRequest(url: urla)
            webView.loadRequest(request)
        }
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


extension WebViewController : UIWebViewDelegate {
 
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("start load")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finish load")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
}
