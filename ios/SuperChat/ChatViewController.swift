//
//  ViewController.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ChatEntryText: UITextField!
    @IBOutlet weak var ChatTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make the text box's delegate this object (for brevity)
        ChatEntryText.delegate = self
    }
    
    //reference to the class that handles client/server communication
    var chatClient = ChatClient()
    
    func showAlert(withTitle title: String, withMessage message: String, withStyle style: UIAlertControllerStyle = .alert, withAction action: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        //note: I use the _ suffix to show its a temporary local variable of the same name as an optional parameter.
        var action_: UIAlertAction
        
        //if the user hasn't specified an action, create a default one
        if action != nil {
            action_ = action!
        }
        else
        {
            action_ = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
        }
        
        alertController.addAction(action_)
        
        //actually show the alert box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //handle the event that says "the user is done with the text box" by pressing Return etc..
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //make the text box lose focus
        ChatEntryText.resignFirstResponder()
        
        //if the user didn't enter anything and hits enter then just lose focus but don't send a message.
        guard let text = ChatEntryText.text else {
            return true
        }
        
        //actually send the message to the API
        let response = self.chatClient.sendMessage(chatMessage: ChatMessage(text))
        
        switch response {
        case let .failure(errorInfo):
            //show error message
            self.showAlert(withTitle: errorInfo.title, withMessage: errorInfo.message)
        default:
            break //good, don't worry about it
        }
        
        return true
    }
}

