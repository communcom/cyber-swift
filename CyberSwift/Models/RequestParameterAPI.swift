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
        public init(languageValue: String = "ru", nsfwContentValue: String = NsfwContentMode.alwaysAlert.rawValue) {
            self.language           =   languageValue
            self.nsfwContent        =   nsfwContentValue
        }
        
        
        // MARK: - Functions
        // Template: "language": <languageValue>, "nsfwContent": <nsfwContentValue>
        public func getBasicOptionsValues() -> String {
            return  String(format: "\"language\": %@, \"nsfwContent\": %@", self.language, self.nsfwContent)
        }
    }
        

    // MARK: -
    public struct PushOptions: Encodable {
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
        public let message: Bool
        public let witnessVote: Bool
        public let witnessCancelVote: Bool
        
        
        // MARK: - Initialization
        public init(upvoteValue: Bool = true, downvoteValue: Bool = true, transferValue: Bool = true, replyValue: Bool = true, subscribeValue: Bool = true, unsubscribeValue: Bool = true, mentionValue: Bool = true, repostValue: Bool = true, rewardValue: Bool = true, curatorRewardValue: Bool = true, messageValue: Bool = true, witnessVoteValue: Bool = true, witnessCancelVoteValue: Bool = true) {
            self.upvote             =   upvoteValue
            self.downvote           =   downvoteValue
            self.transfer           =   transferValue
            self.reply              =   replyValue
            self.subscribe          =   subscribeValue
            self.unsubscribe        =   unsubscribeValue
            self.mention            =   mentionValue
            self.repost             =   repostValue
            self.reward             =   rewardValue
            self.curatorReward      =   curatorRewardValue
            self.message            =   messageValue
            self.witnessVote        =   witnessVoteValue
            self.witnessCancelVote  =   witnessCancelVoteValue
        }
        
        public init(languageValue: String = "ru", imageViews: [UIImageView]) {
            self.upvote             =   !imageViews[0].isHighlighted
            self.downvote           =   !imageViews[1].isHighlighted
            self.transfer           =   !imageViews[2].isHighlighted
            self.reply              =   !imageViews[3].isHighlighted
            self.subscribe          =   !imageViews[4].isHighlighted
            self.unsubscribe        =   !imageViews[5].isHighlighted
            self.mention            =   !imageViews[6].isHighlighted
            self.repost             =   !imageViews[7].isHighlighted
            self.reward             =   !imageViews[8].isHighlighted
            self.curatorReward      =   !imageViews[9].isHighlighted
            self.message            =   !imageViews[10].isHighlighted
            self.witnessVote        =   !imageViews[11].isHighlighted
            self.witnessCancelVote  =   !imageViews[12].isHighlighted
        }

        
        // MARK: - Functions
        // Template: "upvote": <upvoteValue>, "downvote": <downvoteValue>, "reply": <replyValue>, "transfer": <transferValue>, "subscribe": <subscribeValue>, "unsubscribe": <unsibscribeValue>, "mention": <mentionValue>, "repost": <repostValue>,  "message": <messageValue>, "witnessVote": <witnessVoteValue>, "witnessCancelVote": <witnessCancelVoteValue>, "reward": <rewardValue>, "curatorReward": <curatorRewardValue>
        public func getPushOptionsValues() -> String {
            return  String(format: "\"vote\": %d, \"flag\": %d, \"reply\": %d, \"transfer\": %d, \"subscribe\": %d, \"unsubscribe\": %d, \"mention\": %d, \"repost\": %d, \"message\": %d, \"witnessVote\": %d, \"witnessCancelVote\": %d, \"reward\": %d, \"curatorReward\": %d", self.upvote.intValue, self.downvote.intValue, self.reply.intValue, self.transfer.intValue, self.subscribe.intValue, self.unsubscribe.intValue, self.mention.intValue, self.repost.intValue, self.message.intValue, self.witnessVote.intValue, self.witnessCancelVote.intValue, self.reward.intValue, self.curatorReward.intValue)
        }
    }
}
