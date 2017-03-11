//
//  ChatClient.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct UserErrorInfo {
    let message: String
    let title: String
}

enum ChatClientResult {
    case success
    case failure(UserErrorInfo)
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


class ChatClient {
    private let url: String = "https://6e994zg4yi.execute-api.us-east-1.amazonaws.com/v1/chatmessages"
    private let _sessionManager = SessionManager.default
    private let _dispatchQueue = DispatchQueue.global()
    
    func sendMessage(chatMessage: ChatMessage, callback: @escaping (ChatClientResult) -> Void){
        
        //create the json payload to send to the server
        //note: in a real application I'd have an optional init on the model class that handles serialization/deserialization
        var payload: [String: Any] = [:]
        
        payload["text"] = chatMessage.text
        payload["timestamp"] = Int(chatMessage.timestamp.timeIntervalSinceReferenceDate)
        
        let req = self._sessionManager.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default)
        
        //validate that the request's response code was in the 200 range.
        req.validate()
            //process the response and return the appropriate result
           .responseData {
                switch $0.result {
                case .success:
                    callback(ChatClientResult.success)
                case .failure:
                    callback(ChatClientResult.failure(UserErrorInfo(message: "Failed to send message", title: "Error")))
                }
        }
    }
    
    func getMessages(callback: @escaping (ChatClientResult, [ChatMessage]?) -> Void){
        let req = self._sessionManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        
        req.validate()
            //process the response as a JSON blob and return the list of chat messages
            .responseJSON(queue: self._dispatchQueue) {
                switch $0.result {
                case let .success(data):
                    
                    let json = JSON(data)
                    
                    let c = json.count
                    
                    var messages = [ChatMessage]()
                                        
                    json.array!.forEach {
                        j in
                        messages.append(ChatMessage(text: j["text"].stringValue, timestamp: Date(timeIntervalSinceReferenceDate: Double(j["timestamp"].intValue))))
                    }
                    
                    callback(ChatClientResult.success, messages)
                case .failure(_):
                    //NOTE: In a real app I'd log the error message and show something nice to the user in their language.
                    //here I'm just ignoring the error and showing a basic error message
                    callback(ChatClientResult.failure(UserErrorInfo.init(message: "Failed to get chat messages", title: "Error")), nil)
                }
        }
    }
}
