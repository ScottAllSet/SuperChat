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
    
    //reference to a Timer instance used to refresh the chat messages in the table
    var getMessagesTimer: Timer? = nil
    
    //declaring the store using ! means that it's an implicitly unwrapped optional.
    //that is, it's optional but you don't need to access it using ? when you deref.
    var chatMessageStore: ChatMessageStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //do an initial get of the messages so it doesn't need to wait for the timer to fire
        self.getMessages()
        
        //setup the timer to refresh the messages every two seconds
        self.getMessagesTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {
            _ in
            self.getMessages()
        })
    }
    
    //this helps the keyboard show up when you touch the chat entry text
    override func viewWillDisappear(_ animated: Bool) {
        self.resignFirstResponder()
    }
    
    //MARK: chat message table handling
    
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
        
        //if the user didn't enter anything and hits enter then ignore
        guard let text = self.chatEntryText.text, text != "" else {
            return true
        }
        
        //actually send the message to the API
        self.chatClient.sendMessage(chatMessage: ChatMessage(text)) {
            response in
            
            switch response {
            case let .failure(errorInfo):
                //show error message
                self.showAlert(withTitle: errorInfo.title, withMessage: errorInfo.message)
            default:
                break //good, don't worry about it
            }
            
            //reset the text box so we can continue sending messages
            self.chatEntryText.text = nil
            
            //refresh the displayed messages
            self.getMessages()
        }
        
        //note: this isn't optimal as the textField will always return.
        //in a real app I would make that determined based on the success status of the send.
        
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
    
    private func getMessages() {
        self.chatClient.getMessages(callback: {
            result, messages in
            switch result {
            case .success:
                
                //(very) redumentary check to see if there's any new items.
                //in a real application I'd need to do more work here as new items could be deleted
                //this prevents the chat text from scrolling back to the bottom if the user has scrolled manually
                //however, if new messages show up, it'll scroll to the bottom.
                if messages!.count == self.chatMessageStore.allItems.count {
                    return
                }
                
                //since we successfully got messages
                
                //clear the chat messages from the store
                self.chatMessageStore.allItems.removeAll()
                
                //add them and sort by their timestamp
                self.chatMessageStore.allItems.append(contentsOf: messages!.sorted(by: {
                    left, right in
                    left.timestamp < right.timestamp
                }))
                
                //refresh the table on the UI thread
                DispatchQueue.main.async {
                    self.chatTable.reloadData()
                    
                    //scroll the table to the bottom to show the last message
                    self.chatTable.scrollToRow(at: IndexPath(row: self.chatMessageStore.allItems.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
                }
            case let .failure(error):
                //show the user the error message
                self.showAlert(withTitle: error.title, withMessage: error.message)
            }
        })
    }
}

