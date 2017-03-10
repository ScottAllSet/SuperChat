//
//  ViewController.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Foundation

final class ChatCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    private let redColor   = UIColor(red: 231 / 255, green: 76 / 255, blue: 60 / 255, alpha: 1)
    private let greenColor = UIColor(red: 46 / 255, green: 204 / 255, blue: 113 / 255, alpha: 1)
    
    var messageModel: ChatMessage? {
        didSet {
            layoutCell()
        }
    }
    
    private func layoutCell() {
        titleLabel.text = messageModel?.text
    }
}

class ChatViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var ChatEntryText: UITextField!
    
    @IBOutlet weak var ChatTable: UITableView!
    
    @IBOutlet weak var SendButton: UIButton!
    
    @objc private func tapReceived(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    var chatClient = ChatClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.tapReceived(sender:)))
        self.view.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func setupChatTextEntryButton() {
        SendButton.rx.tap.subscribe(onNext: {
            guard let text = self.ChatEntryText.text else {
                return
            }
            
            self.chatClient.sendMessage(chatMessage: ChatMessage(text)).subscribe(onNext: {
                worked in
                switch worked {
                case .success:
                    self.ChatEntryText.text = nil
                case .failure:
                    return
                }
            }).addDisposableTo(self.disposeBag)
        }).addDisposableTo(disposeBag)
    }
    
    private func setupChatTable() {
        self.chatClient.getMessages().filter{ $0 != nil}
            .bindTo(self.ChatTable.rx.items(cellIdentifier: "Cell", cellType: ChatCell.self)) {
                (row, element, cell) in
                cell?.messageModel = element
        }
    }
}

