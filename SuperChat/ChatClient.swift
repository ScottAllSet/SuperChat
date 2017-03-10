//
//  ChatClient.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

enum ChatSendMessageResult {
    case success
    case failure
}

class ChatClient {
    private let url: String = "nothing"
    
    func sendMessage(chatMessage: ChatMessage) -> Observable<ChatSendMessageResult> {
        //stubbed
        return Observable.just(ChatSendMessageResult.success)
    }
    
    func getMessages() -> Observable<ChatMessage> {
        //also stubbed
        return Observable.just(ChatMessage("test"))
    }
}
