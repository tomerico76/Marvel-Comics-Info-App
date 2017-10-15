//
//  WebViewController.swift
//  MarvelProject
//
//  Created by tomer on 20/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url : URL?
    var name : String?
    
    class func webViewController() -> WebViewController{
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: .zero)
        label.text = name
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.4
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        
        navigationItem.titleView = label
        
        if let url = url{
            webView.loadRequest(URLRequest(url: url))
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
