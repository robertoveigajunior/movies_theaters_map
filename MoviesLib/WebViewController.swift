//
//  WebViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    
    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            let urlPage = URL(string: url)
            let request = URLRequest(url: urlPage!)
            self.webView.loadRequest(request)
            self.webView.scrollView.bounces = false
        } else {
            print("erro")
        }
    }
    
    @IBAction func runJS(_ sender: Any) {
        self.webView.stringByEvaluatingJavaScript(from: "alert('Isto é um teste')")
    }
    
}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.aiLoading.stopAnimating()
    }
}
