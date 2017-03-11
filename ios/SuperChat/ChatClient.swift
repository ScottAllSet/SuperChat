//
//  ChatClient.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import Alamofire

struct UserErrorInfo {
    let message: String
    let title: String
}

enum ChatSendMessageResult {
    case success
    case failure(UserErrorInfo)
}

class ChatClient {
    private let url: String = "nothing"
    
    func sendMessage(chatMessage: ChatMessage) -> ChatSendMessageResult {
        //TODO stubbed
        return ChatSendMessageResult.success
    }
    
    func getMessages() -> [ChatMessage] {
        //TODO stubbed
        return [ChatMessage]()
    }
}
