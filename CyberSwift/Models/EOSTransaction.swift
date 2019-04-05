//
//  EOSTransaction.swift
//  CyberSwift
//
//  Created by msm72 on 2/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//
//  https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi
//

import RxSwift
import eosswift
import Foundation

public typealias Byte = UInt8
public typealias BaseT = Int64
public typealias ParentData = (refBlockNum: UInt64, permlink: String)

public class EOSTransaction: ChainTransaction {
    /// Create Post/Comment
    public struct Mssgid: Encodable {
        // MARK: - Properties
        let author: NameWriterValue
        let permlink: String
        let ref_block_num: UInt64
        
        
        // MARK: - Initialization
        init(authorValue: String = "", permlinkValue: String = "", refBlockNumValue: UInt64 = 0) {
            self.author             =   NameWriterValue(name: authorValue)
            self.permlink           =   permlinkValue
            self.ref_block_num      =   refBlockNumValue
        }
    }
    
    public struct MessageCreateArgs: Encodable {
        // MARK: - Properties
        let message_id: Mssgid
        let parent_id: Mssgid
        let beneficiaries: [Beneficiary?]
        let tokenprop: Int64
        let vestpayment: Byte
        let headermssg: String
        let bodymssg: String
        let languagemssg: String
        let tags: [Tags]?
        let jsonmetadata: String?
        
        
        // MARK: - Initialization
        init(authorValue: String, parentDataValue: ParentData? = nil, refBlockNumValue: UInt64 = 0, beneficiariesValues: [Beneficiary?] = [], tokenpropValue: Int64 = 0, vestpaymentValue: Byte = 1, headermssgValue: String = "test", bodymssgValue: String = "test", languagemssgValue: String = "ru", tagsValues: [Tags]? = [Tags()], jsonmetadataValue: String? = "") {
            let prefixTitle         =   parentDataValue == nil ? headermssgValue : "Comment"
            let messagePermlink     =   (prefixTitle + "-" + Date().convert(toStringFormat: .expirationDateType)).lowercased()
                                            .replacingOccurrences(of: " ", with: "-")
                                            .replacingOccurrences(of: ":", with: "-")
            
            self.message_id         =   Mssgid(authorValue:             authorValue,
                                               permlinkValue:           messagePermlink,
                                               refBlockNumValue:        refBlockNumValue)
            
            self.parent_id          =   parentDataValue == nil ?        Mssgid() :
                                                                        Mssgid(authorValue:         authorValue,
                                                                               permlinkValue:       parentDataValue == nil ? messagePermlink : parentDataValue!.permlink,
                                                                               refBlockNumValue:    parentDataValue == nil ? refBlockNumValue : parentDataValue!.refBlockNum)
            
            self.beneficiaries      =   beneficiariesValues
            self.tokenprop          =   tokenpropValue
            self.vestpayment        =   vestpaymentValue
            self.headermssg         =   headermssgValue
            self.bodymssg           =   bodymssgValue
            self.languagemssg       =   languagemssgValue
            self.tags               =   tagsValues
            self.jsonmetadata       =   jsonmetadataValue
            
//            self.parentprmlnk       =   parentprmlnkValue
//            self.parentacc          =   NameWriterValue(name: parentprmlnkValue.isEmpty ? parentaccValue : accountValue)
//
//
//            self.bodymssg           =   "Лондон"
            
//            self.bodymssg           =   "{{مصدر وحيد|تاريخ=ديسمبر 2018}}\n{{يتيمة|تاريخ=أغسطس 2016}}\n\n{{صندوق معلومات منظمة\n|اسم           = الوكالة الوطنية للتأمين الصحي <br/> Agence Nationale de l’Assurance Maladie\n|صورة          = \n|تعليق         = \n|حجم           = \n|بدل           = \n|خريطة         = \n|تعليق2        = \n|حجم2          = \n|بدل2          = \n|اختصار        = \n|شعار          = \n|تأسيس         = [[26 مايو]] [[2005]]\n|حل            = \n|نوع           = [[مؤسسة عمومية]]\n|حالة          = \n|اهتمامات      = \n|مقر           = 8 شارع المهدي بن بركة، حي الرياض، [[الرباط]]\n|منطقة الخدمة  = \n|عضوية         = \n|لغة           = \n|الرئيس        = جيلالي حازم\n|رتبة القائد   = \n|اسم القائد    = \n|رتبة القائد2  = \n|اسم القائد2   = \n|رتبة القائد3  = \n|اسم القائد3   = \n|جهاز          = \n|منظمة أم      = \n|انتماء        = \n|موظفون        = \n|متطوعون       = \n|ميزانية       = \n|موقع          = http://www.assurancemaladie.ma\n|ملاحظات        = \n|خريطة الموقع  = \n|دائرة عرض     = \n|خط طول        = \n}}\n’‘'الوكالة الوطنية للتأمين الصحي‘’' (ANAM) هي مؤسسة إدارية عامة [[المغرب|مغربية]]، ذات [[شخص اعتباري|شخصية اعتبارية]] وذمة مالية مستقلة، تأسست في [[26 مايو]] [[2005]]، تحت إشراف ال[[دولة]]. هدفها ضمان التنفيذ الفعال للقانون  رقم 00-65 <ref>[http://www.assurancemaladie.ma/upload/document/loi%2065-00_ar.pdf مدونة التغطیة الصحیة الأساسیة 00-65 القانون]</ref>، المتعلق بمدونة التغطية الصحية الأساسية.\n\n== المراجع ==\n{{مراجع}}\n{{شريط بوابات|الاقتصاد|المغرب|سلا}}\n\n{{بذرة}}\n[[تصنيف:الضمان الإجتماعي في المغرب]]\n[[تصنيف:تأمين]]\n[[تصنيف:تأمين صحي]]\n[[تصنيف:مؤسسات عمومية مغربية ذات طابع إداري]]"
            
            
            
//            self.bodymssg           =   "Chuck Norris doesn’t get compiler errors, the language changes itself to accommodate Chuck Norris.\n at the moment he lives at 432 Wiza Mountain, Aleenside, WY 75942-7897 \n\n<br> and YODA said: Clear your mind must be, if you are to find the villains behind this plot. \n\n witcher quote: Finish all your business before you die. Bid loved ones farewell. Write your will. Apologize to those you’ve wronged. Otherwise, you’ll never truly leave this world. \n\n Rick and Morty quote: It’s fine, everything is fine. Theres an infinite number of realities Morty and in a few dozen of those I got lucky and turned everything back to normal. \n\n SuperHero Aurora Ivy has power to Atmokinesis and Grim Reaping \n\n Harry Potter quote: Dark and difficult times lie ahead. Soon we must all face the choice between what is right and what is easy. \n\n and some Lorem to finish text: Esse recusandae modi provident et voluptatibus occaecati commodi nostrum sequi aut unde in sint pariatur dignissimos dignissimos quasi sunt beatae explicabo omnis dolorem quo ratione vel aut aliquam sint soluta quia modi quidem aut officia labore sed non nihil et rerum unde sunt at qui assumenda culpa quisquam vero eos ad voluptatem aut exercitationem fugit modi vel iusto impedit assumenda illum consequatur reprehenderit accusamus ut quod est est voluptatem cumque molestiae non dolorem asperiores modi culpa dolor delectus non alias laboriosam suscipit nobis perspiciatis similique quis ea nisi ratione laboriosam voluptatem molestias quas numquam qui doloribus officiis autem quidem debitis magni tenetur aut et incidunt dolores sunt est dolores unde dolor et dolorem voluptatum non sit aut sed ut quibusdam voluptas est ea eligendi excepturi et dolorem eius facilis reiciendis debitis totam voluptate mollitia dolore quisquam sint ut quidem omnis voluptatibus voluptatem accusantium tenetur hic vitae deserunt culpa sequi voluptate labore voluptas."
        }
    }
    
    
    /// Update Post/Comment
    public struct MessageUpdateArgs: Encodable {
        // MARK: - Properties
        let message_id: Mssgid
        let headermssg: String
        let bodymssg: String
        let languagemssg: String
        let tags: [Tags]
        let jsonmetadata: String
        
        
        // MARK: - Initialization
        init(authorValue: String = "destroyer2k", messagePermlink: String, parentDataValue: ParentData? = nil, refBlockNumValue: UInt64 = 0, headermssgValue: String = "test", bodymssgValue: String = "test", languagemssgValue: String = "ru", tagsValues: [Tags] = [Tags()], jsonmetadataValue: String = "") {
            self.message_id         =   Mssgid(authorValue:             authorValue,
                                               permlinkValue:           messagePermlink,
                                               refBlockNumValue:        refBlockNumValue)
            
            self.headermssg         =   headermssgValue
            self.bodymssg           =   bodymssgValue
            self.languagemssg       =   languagemssgValue
            self.tags               =   tagsValues
            self.jsonmetadata       =   jsonmetadataValue
        }
    }
    
    
    /// Delete Post/Comment
    public struct MessageDeleteArgs: Encodable {
        // MARK: - Properties
        let message_id: Mssgid
        
        
        // MARK: - Initialization
        init(authorValue: String = "destroyer2k", messagePermlink: String, refBlockNumValue: UInt64) {
            self.message_id     =   Mssgid(authorValue:             authorValue,
                                           permlinkValue:           messagePermlink,
                                           refBlockNumValue:        refBlockNumValue)
        }
    }
    
    
    /// Beneficiary
    public struct Beneficiary: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        let deductprcnt: BaseT
        
        
        // MARK: - Initialization
        init(accountValue: String = "", deductprcntValue: BaseT = 0) {
            self.account        =   NameWriterValue(name: accountValue)
            self.deductprcnt    =   deductprcntValue
        }
    }
    
    
    /// Tags
    public struct Tags: Encodable {
        // MARK: - Properties
        let tag: String
        
        
        // MARK: - Initialization
        init(tagValue: String = "test") {
            self.tag = tagValue
        }
    }
    
    
    /// Upvote
    public struct UpvoteArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let message_id: Mssgid
        let weight: Int16

        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, permlinkValue: String, refBlockNumValue: UInt64, weightValue: Int16) {
            self.voter      =   NameWriterValue(name: voterValue)
            
            self.message_id =   Mssgid(authorValue:         authorValue,
                                       permlinkValue:       permlinkValue,
                                       refBlockNumValue:    refBlockNumValue)
            
            self.weight     =   weightValue
        }
    }

    
    /// Unvote
    public struct UnvoteArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let message_id: Mssgid

        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, permlinkValue: String, refBlockNumValue: UInt64) {
            self.voter      =   NameWriterValue(name: voterValue)

            self.message_id =   Mssgid(authorValue:         authorValue,
                                       permlinkValue:       permlinkValue,
                                       refBlockNumValue:    refBlockNumValue)
        }
    }
    
    
    /// Transfer
    public struct TransferArgs: Encodable {
        // MARK: - Properties
        let from: NameWriterValue
        let to: NameWriterValue
        let quantity: AssetWriterValue
        let memo: String
        
        
        // MARK: - Initialization
        init(fromValue: String, toValue: String, quantityValue: String, memoValue: String) {
            self.from       =   NameWriterValue(name: fromValue)
            self.to         =   NameWriterValue(name: toValue)
            self.quantity   =   AssetWriterValue(asset: quantityValue)
            self.memo       =   memoValue
        }
    }
    
    
    /// User profile: Pin/Unpin
    public struct UserProfilePinArgs: Encodable {
        // MARK: - Properties
        let pinner: NameWriterValue
        let pinning: NameWriterValue
        
        
        // MARK: - Initialization
        init(pinnerValue: String, pinningValue: String) {
            self.pinner     =   NameWriterValue(name: pinnerValue)
            self.pinning    =   NameWriterValue(name: pinningValue)
        }
    }
    
    /// User profile: Block/Unblock
    public struct UserProfileBlockArgs: Encodable {
        // MARK: - Properties
        let blocker: NameWriterValue
        let blocking: NameWriterValue
        
        
        // MARK: - Initialization
        init(blockerValue: String, blockingValue: String) {
            self.blocker    =   NameWriterValue(name: blockerValue)
            self.blocking   =   NameWriterValue(name: blockingValue)
        }
    }
    
    /// User profile: Changereput
    public struct UserProfileChangereputArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let author: NameWriterValue
        let rshares: Int64
        
        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, rsharesValue: Int64) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.author     =   NameWriterValue(name: authorValue)
            self.rshares    =   rsharesValue
        }
    }
    
    /// User profile: Updatemeta
    public struct UserProfileAccountmetaArgs: Encodable {
        // MARK: - Properties
        let type: String?
        let app: String?
        let email: String?
        let phone: String?
        let facebook: String?
        let instagram: String?
        let telegram: String?
        let vk: String?
        let website: String?
        let first_name: String?
        let last_name: String?
        let name: String?
        let birth_date: String?
        let gender: String?
        let location: String?
        let city: String?
        let about: String?
        let occupation: String?
        let i_can: String?
        let looking_for: String?
        let business_category: String?
        let background_image: String?
        let cover_image: String?
        let profile_image: String?
        let user_image: String?
        let ico_address: String?
        let target_date: String?
        let target_plan: String?
        let target_point_a: String?
        let target_point_b: String?
        
        
        // MARK: - Initialization
        init(typeValue: String? = nil, appValue: String? = nil, emailValue: String? = nil, phoneValue: String? = nil, facebookValue: String? = nil, instagramValue: String? = nil, telegramValue: String? = nil, vkValue: String? = nil, websiteValue: String? = nil, firstNameValue: String? = nil, lastNameValue: String? = nil, nameValue: String? = nil, birthDateValue: String? = nil, genderValue: String? = nil, locationValue: String? = nil, cityValue: String? = nil, aboutValue: String? = nil, occupationValue: String? = nil, iCanValue: String? = nil, lookingForValue: String? = nil, businessCategoryValue: String? = nil, backgroundImageValue: String? = nil, coverImageValue: String? = nil, profileImageValue: String? = nil, userImageValue: String? = nil, icoAddressValue: String? = nil, targetDateValue: String? = nil, targetPlanValue: String? = nil, targetPointAValue: String? = nil, targetPointBValue: String? = nil) {
            self.type               =   typeValue
            self.app                =   appValue
            self.email              =   emailValue
            self.phone              =   phoneValue
            self.facebook           =   facebookValue
            self.instagram          =   instagramValue
            self.telegram           =   telegramValue
            self.vk                 =   vkValue
            self.website            =   websiteValue
            self.first_name         =   firstNameValue
            self.last_name          =   lastNameValue
            self.name               =   nameValue
            self.birth_date         =   birthDateValue
            self.gender             =   genderValue
            self.location           =   locationValue
            self.city               =   cityValue
            self.about              =   aboutValue
            self.occupation         =   occupationValue
            self.i_can              =   iCanValue
            self.looking_for        =   lookingForValue
            self.business_category  =   businessCategoryValue
            self.background_image   =   backgroundImageValue
            self.cover_image        =   coverImageValue
            self.profile_image      =   profileImageValue
            self.user_image         =   userImageValue
            self.ico_address        =   icoAddressValue
            self.target_date        =   targetDateValue
            self.target_plan        =   targetPlanValue
            self.target_point_a     =   targetPointAValue
            self.target_point_b     =   targetPointBValue
        }
    }
    
    /// User profile: Updatemeta
    public struct UserProfileUpdatemetaArgs: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        let meta: UserProfileAccountmetaArgs
        
        
        // MARK: - Initialization
        init(accountValue: String, metaValue: UserProfileAccountmetaArgs) {
            self.account    =   NameWriterValue(name: accountValue)
            self.meta       =   metaValue
        }
    }
    
    /// User profile: Deletemeta
    public struct UserProfileDeleteArgs: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        
        
        // MARK: - Initialization
        init(accountValue: String) {
            self.account    =   NameWriterValue(name: accountValue)
        }
    }
    
    
    // MARK: - Properties
    private let _chainApi: ChainApi
    
    
    // MARK: - Initialization
    public init(chainApi: ChainApi) {
        self._chainApi = chainApi
    }
    
    public func chainApi() -> ChainApi {
        return _chainApi
    }
}
