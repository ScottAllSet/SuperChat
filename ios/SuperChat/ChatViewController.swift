//
//  ViewController.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController {
    @IBOutlet weak var ChatEntryText: UITextField!
    @IBOutlet weak var ChatTable: UITableView!
    var chatClient = ChatClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

