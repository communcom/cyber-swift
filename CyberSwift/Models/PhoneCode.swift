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
    public var flagURL: URL
    public var `default`: Bool
    public var verificationPhone: String
    public var verificationOverrides: Override?
    
    public var phoneCode: String {
        return "+\(code)"
    }


    init(codeValue: UInt16, labelValue: String, flagURLString: String, defaultValue: Bool = false, verificationPhoneValue: String = "", verificationOverridesValue: Override? = nil) {
        self.code = codeValue
        self.label = labelValue
        self.flagURL = URL(string: flagURLString)!
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
    class func getCountries() -> [County] {
        return [ UnitedStates(codeValue: 1, labelValue: "United States", flagURLString: "https://cdn.countryflags.com/thumbs/united-states-of-america/flag-800.png"),
                 Russia(codeValue: 7, labelValue: "Russia", flagURLString: "https://cdn.countryflags.com/thumbs/russia/flag-800.png", defaultValue: true, verificationPhoneValue: "+7 (916) 930-63-59"),
                 Kazakhstan(codeValue: 7, labelValue: "Kazakhstan", flagURLString: "https://cdn.countryflags.com/thumbs/kazakhstan/flag-800.png", verificationPhoneValue: "+7 (777) 007-69-77"),
                 Lithuania(codeValue: 370, labelValue: "Lithuania", flagURLString: "https://cdn.countryflags.com/thumbs/lithuania/flag-800.png"),
                 Belarus(codeValue: 375, labelValue: "Belarus", flagURLString: "https://cdn.countryflags.com/thumbs/belarus/flag-800.png", verificationPhoneValue: "+375 (29) 230-87-70"),
                 Ukraine(codeValue: 380, labelValue: "Ukraine", flagURLString: "https://cdn.countryflags.com/thumbs/ukraine/flag-800.png", verificationPhoneValue: "+380 (93) 177-77-72", verificationOverridesValue: Override(startsWith: ["62", "64", "71", "72"], verificationPhone: "+7 (916) 930-63-59")),
                 Afghanistan(codeValue: 93, labelValue: "Afghanistan", flagURLString: "https://cdn.countryflags.com/thumbs/afghanistan/flag-800.png"),
                 Albania(codeValue: 355, labelValue: "Albania", flagURLString: "https://cdn.countryflags.com/thumbs/albania/flag-800.png"),
                 Algeria(codeValue: 213, labelValue: "Algeria", flagURLString: "https://cdn.countryflags.com/thumbs/algeria/flag-800.png"),
                 AmericanSamoa(codeValue: 1, labelValue: "American Samoa", flagURLString: "https://cdn.countryflags.com/thumbs/samoa/flag-800.png"),
                 Andorra(codeValue: 376, labelValue: "Andorra", flagURLString: "https://cdn.countryflags.com/thumbs/andorra/flag-800.png"),
                 Angola(codeValue: 244, labelValue: "Angola", flagURLString: "https://cdn.countryflags.com/thumbs/angola/flag-800.png")
        ]
    }
}
