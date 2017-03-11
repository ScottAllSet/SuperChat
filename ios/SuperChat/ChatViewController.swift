//
//  ViewController.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chatEntryText: UITextField!
    @IBOutlet weak var chatTable: UITableView!

    //reference to the class that handles client/server communication
    let chatClient = ChatClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: chat message table handling
    
    //declaring the store using ! means that it's an implicitly unwrapped optional.
    //that is, it's optional but you don't need to access it using ? when you deref.
    var chatMessageStore: ChatMessageStore!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of chat messages
        return self.chatMessageStore.allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create the cell object used to display the content
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "ChatMessageCell")
        
        //get the chat message from the store
        let chatMessage = self.chatMessageStore.allItems[indexPath.row]
        
        //set the cell's text to teh message
        cell.textLabel?.text = chatMessage.text
        
        //format the date in "hh:mm:ss" format
        //note: in a real app I'd have the format in a constant
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        dateFormatter.locale = Locale.current
        
        //set the detail text to the formatted date (actually, the time)
        cell.detailTextLabel?.text = dateFormatter.string(from: chatMessage.timestamp)
        
        return cell
    }
    
    //MARK: text message field
    
    //handle the event that says "the user is done with the text box" by pressing Return etc..
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //if the user didn't enter anything and hits enter then just lose focus but don't send a message.
        guard let text = self.chatEntryText.text else {
            return true
        }
        
        //actually send the message to the API
        let response = self.chatClient.sendMessage(chatMessage: ChatMessage(text))
        
        switch response {
        case let .failure(errorInfo):
            //show error message
            self.showAlert(withTitle: errorInfo.title, withMessage: errorInfo.message)
            return false //maintain focus so the user can try again
        default:
            break //good, don't worry about it
        }
        
        //make the text box lose focus
        self.chatEntryText.resignFirstResponder()
        self.chatEntryText.text = nil
        
        return true
    }
    
    //MARK: helpers
    
    func showAlert(withTitle title: String, withMessage message: String, withStyle style: UIAlertControllerStyle = .alert, withAction action: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        //note: I use the _ suffix to show it's a temporary local variable of the same name as an optional parameter.
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
}

