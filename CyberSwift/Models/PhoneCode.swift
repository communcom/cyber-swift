//
//  City.swift
//  CyberSwift
//
//  Created by msm72 on 4/10/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public class County: Encodable {
    public var code: UInt16
    public var label: String
    public var flagURL: String
    public var `default`: Bool
    public var verificationPhone: String
    public var verificationOverrides: Override?
    
    public var phoneCode: String {
        return "+\(code)"
    }


    init(codeValue: UInt16, labelValue: String, flagURLValue: String, defaultValue: Bool = false, verificationPhoneValue: String = "", verificationOverridesValue: Override? = nil) {
        self.code = codeValue
        self.label = labelValue
        self.flagURL = flagURLValue
        self.default = defaultValue
        self.verificationPhone = verificationPhoneValue
        self.verificationOverrides = verificationOverridesValue
    }
}

public struct Override: Encodable {
    let startsWith: [String]
    let verificationPhone: String
}


public class PhoneCode {
    // MARK: - Properties
    public var list: [Encodable] {
        return self.create()
    }
    
    public class UnitedStates: County {
    }
    
    public class Russia: County {
    }

    public class Kazakhstan: County {
    }
    
    public class Lithuania: County {
    }
    
    public class Belarus: County {
    }

    public class Ukraine: County {
    }

    public class Afghanistan: County {
    }
    
    public class Albania: County {
    }

    public class Algeria: County {
    }

    public class AmericanSamoa: County {
    }
    
    public class Andorra: County {
    }
    
    public class Angola: County {
    }

    
    
    
    // MARK: - Functions
    func create() -> [County] {
        return [ UnitedStates(codeValue: 1, labelValue: "United States", flagURLValue: "original-flag-united-states-of-america"),
                 Russia(codeValue: 7, labelValue: "Russia", flagURLValue: "original-flag-russia", defaultValue: true, verificationPhoneValue: "+7 (916) 930-63-59"),
                 Kazakhstan(codeValue: 7, labelValue: "Kazakhstan", flagURLValue: "original-flag-kazakhstan", verificationPhoneValue: "+7 (777) 007-69-77"),
                 Lithuania(codeValue: 370, labelValue: "Lithuania", flagURLValue: "original-flag-lithuania"),
                 Belarus(codeValue: 375, labelValue: "Belarus", flagURLValue: "original-flag-belarus", verificationPhoneValue: "+375 (29) 230-87-70"),
                 Ukraine(codeValue: 380, labelValue: "Ukraine", flagURLValue: "original-flag-ukraine", verificationPhoneValue: "+380 (93) 177-77-72", verificationOverridesValue: Override(startsWith: ["62", "64", "71", "72"], verificationPhone: "+7 (916) 930-63-59")),
                 Afghanistan(codeValue: 93, labelValue: "Afghanistan", flagURLValue: "original-flag-afghanistan"),
                 Albania(codeValue: 355, labelValue: "Albania", flagURLValue: "original-flag-albania"),
                 Algeria(codeValue: 213, labelValue: "Algeria", flagURLValue: "original-flag-algeria"),
                 AmericanSamoa(codeValue: 1, labelValue: "American Samoa", flagURLValue: "original-flag-samoa"),
                 Andorra(codeValue: 376, labelValue: "Andorra", flagURLValue: "original-flag-andorra"),
                 Angola(codeValue: 244, labelValue: "Angola", flagURLValue: "original-flag-angola")
        ]
    }
}
