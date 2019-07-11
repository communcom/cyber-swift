//
//  RequestParameterAPI.swift
//  GoloSwift
//
//  Created by msm72 on 01.06.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import UIKit

protocol RequestParameterAPIOperationPropertiesSupport {
    var code: Int? { get set }
    var name: String? { get set }
    func getProperties() -> [String: Any]
    func getPropertiesNames() -> [String]
}

public enum NsfwContentMode: String {
    case alwaysAlert    =   "Always alert"
}

public struct RequestParameterAPI {
    static func decodeToString(model: RequestParameterAPIOperationPropertiesSupport) -> String? {
        // Data encoder
        let jsonEncoder = JSONEncoder()
        var jsonData = Data()
        
        // Add operation name
        var result = String(format: "\"%@\",{", model.name ?? "")
        Logger.log(message: "\nResult + operationName:\n\t\(result)", event: .debug)
        
        let properties = model.getProperties()
        let propertiesNames = model.getPropertiesNames()
        
        do {
            for (_, propertyName) in propertiesNames.enumerated() {
                let propertyValue = properties.first(where: { $0.key == propertyName })!.value
                
                // Casting Types
                if propertyValue is String {
                    jsonData = try jsonEncoder.encode(["\(propertyName)": "\(propertyValue)"])
                }
                    
                else if propertyValue is Int64 {
                    jsonData = try jsonEncoder.encode(["\(propertyName)": propertyValue as! Int64])
                }
                    
                else if let data = try? JSONSerialization.data(withJSONObject: propertyValue, options: []) {
                    jsonData = data
                    result += "\"\(propertyName)\":" + "\(String(data: jsonData, encoding: .utf8)!),"
                    continue
                }
                
                result += "\(String(data: jsonData, encoding: .utf8)!)"
                Logger.log(message: "\nResult + \"\(propertyName)\":\n\t\(result)", event: .debug)
            }
            
            return  result
                .replacingOccurrences(of: "{{", with: "{")
                .replacingOccurrences(of: "}{", with: ",")
                .replacingOccurrences(of: "],{", with: "],")
                .replacingOccurrences(of: "}\"}", with: "}\"")
        } catch {
            Logger.log(message: "Error: \(error.localizedDescription)", event: .error)
            return nil
        }
    }
    
    
    // MARK: -
    public struct BasicOptions: Encodable {
        // MARK: - Properties
        public let language: String
        public let nsfwContent: String
        
        
        // MARK: - Initialization
        public init(language: String = "ru", nsfwContent: String = NsfwContentMode.alwaysAlert.rawValue) {
            self.language           =   language
            self.nsfwContent        =   nsfwContent
        }
        
        
        // MARK: - Functions
        // Template: "language": <languageValue>, "nsfwContent": <nsfwContentValue>
        public func getBasicOptionsValues() -> String {
            return  String(format: "\"language\": %@, \"nsfwContent\": %@", self.language, self.nsfwContent)
        }
    }
        

    // MARK: -
    public struct NoticeOptions: Encodable {
        // MARK: - Properties
        public let upvote: Bool
        public let downvote: Bool
        public let transfer: Bool
        public let reply: Bool
        public let subscribe: Bool
        public let unsubscribe: Bool
        public let mention: Bool
        public let repost: Bool
        public let reward: Bool
        public let curatorReward: Bool
        public let witnessVote: Bool
        public let witnessCancelVote: Bool
        
        
        // MARK: - Initialization
        public init(upvote: Bool = true, downvote: Bool = true, transfer: Bool = true, reply: Bool = true, subscribe: Bool = true, unsubscribe: Bool = true, mention: Bool = true, repost: Bool = true, reward: Bool = true, curatorReward: Bool = true, message: Bool = true, witnessVote: Bool = true, witnessCancelVote: Bool = true) {
            self.upvote             =   upvote
            self.downvote           =   downvote
            self.transfer           =   transfer
            self.reply              =   reply
            self.subscribe          =   subscribe
            self.unsubscribe        =   unsubscribe
            self.mention            =   mention
            self.repost             =   repost
            self.reward             =   reward
            self.curatorReward      =   curatorReward
            self.witnessVote        =   witnessVote
            self.witnessCancelVote  =   witnessCancelVote
        }
        
        // MARK: - Functions
        // Template: "upvote": <upvote>, "downvote": <downvote>, "transfer": <transfer>, "reply": <reply>, "subscribe": <subscribe>, "unsubscribe": <unsibscribe>, "mention": <mention>, "repost": <repost>, "reward": <reward>, "curatorReward": <curatorReward>, "witnessVote": <witnessVote>, "witnessCancelVote": <witnessCancelVote>,
        public func getNoticeOptionsValues() -> String {
            return  String(format: "\"upvote\": \"%@\", \"downvote\": \"%@\", \"transfer\": \"%@\", \"reply\": \"%@\", \"subscribe\": \"%@\", \"unsubscribe\": \"%@\", \"mention\": \"%@\", \"repost\": \"%@\", \"reward\": \"%@\", \"curatorReward\": \"%@\", \"witnessVote\": \"%@\", \"witnessCancelVote\": \"%@\"", self.upvote.description, self.downvote.description, self.transfer.description, self.reply.description, self.subscribe.description, self.unsubscribe.description, self.mention.description, self.repost.description, self.reward.description, self.curatorReward.description, self.witnessVote.description, self.witnessCancelVote.description)
        }
    }
}
