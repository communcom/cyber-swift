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
    public var shortCode: String
    public var label: String
    public var flagURL: URL
    public var `default`: Bool
    public var verificationPhone: String
    public var verificationOverrides: Override?
    
    public var phoneCode: String {
        return "+\(code)"
    }


    init(codeValue: UInt16, shortCodeValue: String, labelValue: String, flagURLString: String, defaultValue: Bool = false, verificationPhoneValue: String = "", verificationOverridesValue: Override? = nil) {
        self.code = codeValue
        self.shortCode = shortCodeValue
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
    class UnitedStates: County {}
    class Russia: County {}
    class Kazakhstan: County {}
    class Lithuania: County {}
    class Belarus: County {}
    class Ukraine: County {}
    class Afghanistan: County {}
    class Albania: County {}
    class Algeria: County {}
    class AmericanSamoa: County {}
    class Andorra: County {}
    class Angola: County {}
    class Anguilla: County {}
    class Antigua: County {}
    class Argentina: County {}
    class Armenia: County {}
    class Aruba: County {}
    class Australia: County {}
    class Austria: County {}
    class Azerbaijan: County {}
    class Bahrain: County {}
    class Bangladesh: County {}
    class Barbados: County {}
    class Belgium: County {}
    class Belize: County {}
    class Benin: County {}
    class Bermuda: County {}
    class Bhutan: County {}
    class Bolivia: County {}
    class BonaireSintEustatiusSaba: County {}
    class BosniaHerzegovina: County {}
    class Botswana: County {}
    class Brazil: County {}
    class BritishIndianOceanTerritory: County {}
    class BritishVirginIslands: County {}
    class Brunei: County {}
    class Bulgaria: County {}
    class BurkinaFaso: County {}
    class Burundi: County {}
    class Cambodia: County {}
    class Cameroon: County {}
    class Canada: County {}
    class CapeVerde: County {}
    class CaymanIslands: County {}
    class CentralAfricanRepublic: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}
    //    class Cameroon: County {}

    


    
    
    // MARK: - Functions
    public class func getCountries() -> [County] {
        return [ UnitedStates(codeValue: 1, shortCodeValue: "US", labelValue: "United States", flagURLString: "https://cdn.countryflags.com/thumbs/united-states-of-america/flag-800.png"),
                 Russia(codeValue: 7, shortCodeValue: "RU", labelValue: "Russia", flagURLString: "https://cdn.countryflags.com/thumbs/russia/flag-800.png", defaultValue: true, verificationPhoneValue: "+7 (916) 930-63-59"),
                 Kazakhstan(codeValue: 7, shortCodeValue: "KZ", labelValue: "Kazakhstan", flagURLString: "https://cdn.countryflags.com/thumbs/kazakhstan/flag-800.png", verificationPhoneValue: "+7 (777) 007-69-77"),
                 Lithuania(codeValue: 370, shortCodeValue: "LT", labelValue: "Lithuania", flagURLString: "https://cdn.countryflags.com/thumbs/lithuania/flag-800.png"),
                 Belarus(codeValue: 375, shortCodeValue: "BY", labelValue: "Belarus", flagURLString: "https://cdn.countryflags.com/thumbs/belarus/flag-800.png", verificationPhoneValue: "+375 (29) 230-87-70"),
                 Ukraine(codeValue: 380, shortCodeValue: "UA", labelValue: "Ukraine", flagURLString: "https://cdn.countryflags.com/thumbs/ukraine/flag-800.png", verificationPhoneValue: "+380 (93) 177-77-72", verificationOverridesValue: Override(startsWith: ["62", "64", "71", "72"], verificationPhone: "+7 (916) 930-63-59")),
                 Afghanistan(codeValue: 93, shortCodeValue: "AF", labelValue: "Afghanistan", flagURLString: "https://cdn.countryflags.com/thumbs/afghanistan/flag-800.png"),
                 Albania(codeValue: 355, shortCodeValue: "AL", labelValue: "Albania", flagURLString: "https://cdn.countryflags.com/thumbs/albania/flag-800.png"),
                 Algeria(codeValue: 213, shortCodeValue: "DZ", labelValue: "Algeria", flagURLString: "https://cdn.countryflags.com/thumbs/algeria/flag-800.png"),
                 AmericanSamoa(codeValue: 1, shortCodeValue: "AS", labelValue: "American Samoa", flagURLString: "https://cdn.countryflags.com/thumbs/samoa/flag-800.png"),
                 Andorra(codeValue: 376, shortCodeValue: "AD", labelValue: "Andorra", flagURLString: "https://cdn.countryflags.com/thumbs/andorra/flag-800.png"),
                 Angola(codeValue: 244, shortCodeValue: "AO", labelValue: "Angola", flagURLString: "https://cdn.countryflags.com/thumbs/angola/flag-800.png"),
                 Anguilla(codeValue: 1, shortCodeValue: "AI", labelValue: "Anguilla", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Flag_of_Anguilla.svg/2880px-Flag_of_Anguilla.svg.png"),
                 Antigua(codeValue: 1, shortCodeValue: "AG", labelValue: "Antigua", flagURLString: "https://cdn.countryflags.com/thumbs/antigua-and-barbuda/flag-800.png"),
                 Argentina(codeValue: 54, shortCodeValue: "AR", labelValue: "Argentina", flagURLString: "https://cdn.countryflags.com/thumbs/argentina/flag-800.png"),
                 Armenia(codeValue: 374, shortCodeValue: "AM", labelValue: "Armenia", flagURLString: "https://cdn.countryflags.com/thumbs/armenia/flag-800.png"),
                 Aruba(codeValue: 297, shortCodeValue: "AW", labelValue: "Aruba", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Aruba.svg/2560px-Flag_of_Aruba.svg.png"),
                 Australia(codeValue: 61, shortCodeValue: "AU", labelValue: "Australia", flagURLString: "https://cdn.countryflags.com/thumbs/australia/flag-800.png"),
                 Austria(codeValue: 43, shortCodeValue: "AT", labelValue: "Austria", flagURLString: "https://cdn.countryflags.com/thumbs/austria/flag-800.png"),
                 Azerbaijan(codeValue: 994, shortCodeValue: "AZ", labelValue: "Azerbaijan", flagURLString: "https://cdn.countryflags.com/thumbs/azerbaijan/flag-800.png"),
                 Bahrain(codeValue: 973, shortCodeValue: "BH", labelValue: "Bahrain", flagURLString: "https://cdn.countryflags.com/thumbs/bahrain/flag-800.png"),
                 Bangladesh(codeValue: 880, shortCodeValue: "BD", labelValue: "Bangladesh", flagURLString: "https://cdn.countryflags.com/thumbs/bangladesh/flag-800.png"),
                 Barbados(codeValue: 1, shortCodeValue: "BB", labelValue: "Barbados", flagURLString: "https://cdn.countryflags.com/thumbs/barbados/flag-800.png"),
                 Belgium(codeValue: 32, shortCodeValue: "BE", labelValue: "Belgium", flagURLString: "https://cdn.countryflags.com/thumbs/belgium/flag-800.png"),
                 Belize(codeValue: 501, shortCodeValue: "BZ", labelValue: "Belize", flagURLString: "https://cdn.countryflags.com/thumbs/belize/flag-800.png"),
                 Benin(codeValue: 229, shortCodeValue: "BJ", labelValue: "Benin", flagURLString: "https://cdn.countryflags.com/thumbs/benin/flag-800.png"),
                 Bermuda(codeValue: 1, shortCodeValue: "BM", labelValue: "Bermuda", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Flag_of_Bermuda.svg/2880px-Flag_of_Bermuda.svg.png"),
                 Bhutan(codeValue: 975, shortCodeValue: "BT", labelValue: "Bhutan", flagURLString: "https://cdn.countryflags.com/thumbs/bhutan/flag-800.png"),
                 Bolivia(codeValue: 591, shortCodeValue: "BO", labelValue: "Bolivia", flagURLString: "https://cdn.countryflags.com/thumbs/bolivia/flag-800.png"),
                 BonaireSintEustatiusSaba(codeValue: 599, shortCodeValue: "BS", labelValue: "Bonaire, Sint Eustatius and Saba", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/2560px-Flag_of_the_Netherlands.svg.png"),
                 BosniaHerzegovina(codeValue: 387, shortCodeValue: "BA", labelValue: "Bosnia and Herzegovina", flagURLString: "https://cdn.countryflags.com/thumbs/bosnia-and-herzegovina/flag-800.png"),
                 Botswana(codeValue: 267, shortCodeValue: "BW", labelValue: "Botswana", flagURLString: "https://cdn.countryflags.com/thumbs/botswana/flag-800.png"),
                 Brazil(codeValue: 55, shortCodeValue: "BR", labelValue: "Brazil", flagURLString: "https://cdn.countryflags.com/thumbs/brazil/flag-800.png"),
                 BritishIndianOceanTerritory(codeValue: 246, shortCodeValue: "IO", labelValue: "British Indian Ocean Territory", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Flag_of_the_British_Indian_Ocean_Territory.svg/2880px-Flag_of_the_British_Indian_Ocean_Territory.svg.png"),
                 BritishVirginIslands(codeValue: 1, shortCodeValue: "VG", labelValue: "British Virgin Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Flag_of_the_British_Virgin_Islands.svg/2880px-Flag_of_the_British_Virgin_Islands.svg.png"),
                 Brunei(codeValue: 673, shortCodeValue: "BN", labelValue: "Brunei", flagURLString: "https://cdn.countryflags.com/thumbs/brunei/flag-800.png"),
                 Bulgaria(codeValue: 359, shortCodeValue: "BG", labelValue: "Bulgaria", flagURLString: "https://cdn.countryflags.com/thumbs/bulgaria/flag-800.png"),
                 BurkinaFaso(codeValue: 226, shortCodeValue: "BF", labelValue: "Burkina Faso", flagURLString: "https://cdn.countryflags.com/thumbs/burkina-faso/flag-800.png"),
                 Burundi(codeValue: 257, shortCodeValue: "BI", labelValue: "Burundi", flagURLString: "https://cdn.countryflags.com/thumbs/burundi/flag-800.png"),
                 Cambodia(codeValue: 855, shortCodeValue: "KH", labelValue: "Cambodia", flagURLString: "https://cdn.countryflags.com/thumbs/cambodia/flag-800.png"),
                 Cameroon(codeValue: 237, shortCodeValue: "CM", labelValue: "Cameroon", flagURLString: "https://cdn.countryflags.com/thumbs/cameroon/flag-800.png"),
                 Canada(codeValue: 1, shortCodeValue: "CA", labelValue: "Canada", flagURLString: "https://cdn.countryflags.com/thumbs/canada/flag-800.png"),
                 CapeVerde(codeValue: 238, shortCodeValue: "CV", labelValue: "Cape Verde", flagURLString: "https://cdn.countryflags.com/thumbs/cape-verde/flag-800.png"),
                 CaymanIslands(codeValue: 1, shortCodeValue: "KY", labelValue: "Cayman Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Flag_of_the_Cayman_Islands.svg/2880px-Flag_of_the_Cayman_Islands.svg.png"),
                 CentralAfricanRepublic(codeValue: 236, shortCodeValue: "CF", labelValue: "Central African Republic", flagURLString: "https://cdn.countryflags.com/thumbs/central-african-republic/flag-800.png"),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
//            (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),

        ]
    }

    /*

    {
    "code": 236,
    "label": "Central African Republic"
    },
    {
    "code": 235,
    "label": "Chad"
    },
    {
    "code": 56,
    "label": "Chile"
    },
    {
    "code": 86,
    "label": "China"
    },
    {
    "code": 57,
    "label": "Colombia"
    },
    {
    "code": 269,
    "label": "Comoros"
    },
    {
    "code": 682,
    "label": "Cook Islands"
    },
    {
    "code": 506,
    "label": "Costa Rica"
    },
    {
    "code": 225,
    "label": "Côte d'Ivoire"
    },
    {
    "code": 385,
    "label": "Croatia"
    },
    {
    "code": 53,
    "label": "Cuba"
    },
    {
    "code": 599,
    "label": "Curaçao"
    },
    {
    "code": 357,
    "label": "Cyprus"
    },
    {
    "code": 420,
    "label": "Czech Republic"
    },
    {
    "code": 243,
    "label": "Democratic Republic of the Congo"
    },
    {
    "code": 45,
    "label": "Denmark"
    },
    {
    "code": 253,
    "label": "Djibouti"
    },
    {
    "code": 1,
    "label": "Dominica"
    },
    {
    "code": 1,
    "label": "Dominican Republic"
    },
    {
    "code": 593,
    "label": "Ecuador"
    },
    {
    "code": 20,
    "label": "Egypt"
    },
    {
    "code": 503,
    "label": "El Salvador"
    },
    {
    "code": 240,
    "label": "Equatorial Guinea"
    },
    {
    "code": 291,
    "label": "Eritrea"
    },
    {
    "code": 372,
    "label": "Estonia"
    },
    {
    "code": 251,
    "label": "Ethiopia"
    },
    {
    "code": 500,
    "label": "Falkland Islands"
    },
    {
    "code": 298,
    "label": "Faroe Islands"
    },
    {
    "code": 691,
    "label": "Federated States of Micronesia"
    },
    {
    "code": 679,
    "label": "Fiji"
    },
    {
    "code": 358,
    "label": "Finland"
    },
    {
    "code": 33,
    "label": "France"
    },
    {
    "code": 594,
    "label": "French Guiana"
    },
    {
    "code": 689,
    "label": "French Polynesia"
    },
    {
    "code": 241,
    "label": "Gabon"
    },
    {
    "code": 995,
    "label": "Georgia"
    },
    {
    "code": 49,
    "label": "Germany"
    },
    {
    "code": 233,
    "label": "Ghana"
    },
    {
    "code": 350,
    "label": "Gibraltar"
    },
    {
    "code": 30,
    "label": "Greece"
    },
    {
    "code": 299,
    "label": "Greenland"
    },
    {
    "code": 1,
    "label": "Grenada"
    },
    {
    "code": 590,
    "label": "Guadeloupe"
    },
    {
    "code": 1,
    "label": "Guam"
    },
    {
    "code": 502,
    "label": "Guatemala"
    },
    {
    "code": 44,
    "label": "Guernsey"
    },
    {
    "code": 224,
    "label": "Guinea"
    },
    {
    "code": 245,
    "label": "Guinea-Bissau"
    },
    {
    "code": 592,
    "label": "Guyana"
    },
    {
    "code": 509,
    "label": "Haiti"
    },
    {
    "code": 504,
    "label": "Honduras"
    },
    {
    "code": 852,
    "label": "Hong Kong"
    },
    {
    "code": 36,
    "label": "Hungary"
    },
    {
    "code": 354,
    "label": "Iceland"
    },
    {
    "code": 91,
    "label": "India"
    },
    {
    "code": 62,
    "label": "Indonesia"
    },
    {
    "code": 98,
    "label": "Iran"
    },
    {
    "code": 964,
    "label": "Iraq"
    },
    {
    "code": 353,
    "label": "Ireland"
    },
    {
    "code": 44,
    "label": "Isle Of Man"
    },
    {
    "code": 972,
    "label": "Israel"
    },
    {
    "code": 39,
    "label": "Italy"
    },
    {
    "code": 1,
    "label": "Jamaica"
    },
    {
    "code": 81,
    "label": "Japan"
    },
    {
    "code": 44,
    "label": "Jersey"
    },
    {
    "code": 962,
    "label": "Jordan"
    },
    {
    "code": 254,
    "label": "Kenya"
    },
    {
    "code": 686,
    "label": "Kiribati"
    },
    {
    "code": 383,
    "label": "Kosovo"
    },
    {
    "code": 965,
    "label": "Kuwait"
    },
    {
    "code": 996,
    "label": "Kyrgyzstan"
    },
    {
    "code": 856,
    "label": "Laos"
    },
    {
    "code": 371,
    "label": "Latvia"
    },
    {
    "code": 961,
    "label": "Lebanon"
    },
    {
    "code": 266,
    "label": "Lesotho"
    },
    {
    "code": 231,
    "label": "Liberia"
    },
    {
    "code": 218,
    "label": "Libya"
    },
    {
    "code": 423,
    "label": "Liechtenstein"
    },
    {
    "code": 352,
    "label": "Luxembourg"
    },
    {
    "code": 853,
    "label": "Macau"
    },
    {
    "code": 389,
    "label": "Macedonia"
    },
    {
    "code": 261,
    "label": "Madagascar"
    },
    {
    "code": 265,
    "label": "Malawi"
    },
    {
    "code": 60,
    "label": "Malaysia"
    },
    {
    "code": 960,
    "label": "Maldives"
    },
    {
    "code": 223,
    "label": "Mali"
    },
    {
    "code": 356,
    "label": "Malta"
    },
    {
    "code": 692,
    "label": "Marshall Islands"
    },
    {
    "code": 596,
    "label": "Martinique"
    },
    {
    "code": 222,
    "label": "Mauritania"
    },
    {
    "code": 230,
    "label": "Mauritius"
    },
    {
    "code": 262,
    "label": "Mayotte"
    },
    {
    "code": 52,
    "label": "Mexico"
    },
    {
    "code": 373,
    "label": "Moldova"
    },
    {
    "code": 377,
    "label": "Monaco"
    },
    {
    "code": 976,
    "label": "Mongolia"
    },
    {
    "code": 382,
    "label": "Montenegro"
    },
    {
    "code": 1,
    "label": "Montserrat"
    },
    {
    "code": 212,
    "label": "Morocco"
    },
    {
    "code": 258,
    "label": "Mozambique"
    },
    {
    "code": 95,
    "label": "Myanmar"
    },
    {
    "code": 264,
    "label": "Namibia"
    },
    {
    "code": 674,
    "label": "Nauru"
    },
    {
    "code": 977,
    "label": "Nepal"
    },
    {
    "code": 31,
    "label": "Netherlands"
    },
    {
    "code": 687,
    "label": "New Caledonia"
    },
    {
    "code": 64,
    "label": "New Zealand"
    },
    {
    "code": 505,
    "label": "Nicaragua"
    },
    {
    "code": 227,
    "label": "Niger"
    },
    {
    "code": 234,
    "label": "Nigeria"
    },
    {
    "code": 683,
    "label": "Niue"
    },
    {
    "code": 672,
    "label": "Norfolk Island"
    },
    {
    "code": 850,
    "label": "North Korea"
    },
    {
    "code": 1,
    "label": "Northern Mariana Islands"
    },
    {
    "code": 47,
    "label": "Norway"
    },
    {
    "code": 968,
    "label": "Oman"
    },
    {
    "code": 92,
    "label": "Pakistan"
    },
    {
    "code": 680,
    "label": "Palau"
    },
    {
    "code": 970,
    "label": "Palestine"
    },
    {
    "code": 507,
    "label": "Panama"
    },
    {
    "code": 675,
    "label": "Papua New Guinea"
    },
    {
    "code": 595,
    "label": "Paraguay"
    },
    {
    "code": 51,
    "label": "Peru"
    },
    {
    "code": 63,
    "label": "Philippines"
    },
    {
    "code": 48,
    "label": "Poland"
    },
    {
    "code": 351,
    "label": "Portugal"
    },
    {
    "code": 1,
    "label": "Puerto Rico"
    },
    {
    "code": 974,
    "label": "Qatar"
    },
    {
    "code": 242,
    "label": "Republic of the Congo"
    },
    {
    "code": 262,
    "label": "Réunion"
    },
    {
    "code": 40,
    "label": "Romania"
    },
    {
    "code": 250,
    "label": "Rwanda"
    },
    {
    "code": 590,
    "label": "Saint Barthélemy"
    },
    {
    "code": 290,
    "label": "Saint Helena"
    },
    {
    "code": 1,
    "label": "Saint Kitts and Nevis"
    },
    {
    "code": 590,
    "label": "Saint Martin"
    },
    {
    "code": 508,
    "label": "Saint Pierre and Miquelon"
    },
    {
    "code": 1,
    "label": "Saint Vincent and the Grenadines"
    },
    {
    "code": 685,
    "label": "Samoa"
    },
    {
    "code": 378,
    "label": "San Marino"
    },
    {
    "code": 239,
    "label": "Sao Tome and Principe"
    },
    {
    "code": 966,
    "label": "Saudi Arabia"
    },
    {
    "code": 221,
    "label": "Senegal"
    },
    {
    "code": 381,
    "label": "Serbia"
    },
    {
    "code": 248,
    "label": "Seychelles"
    },
    {
    "code": 232,
    "label": "Sierra Leone"
    },
    {
    "code": 65,
    "label": "Singapore"
    },
    {
    "code": 1,
    "label": "Sint Maarten"
    },
    {
    "code": 421,
    "label": "Slovakia"
    },
    {
    "code": 386,
    "label": "Slovenia"
    },
    {
    "code": 677,
    "label": "Solomon Islands"
    },
    {
    "code": 252,
    "label": "Somalia"
    },
    {
    "code": 27,
    "label": "South Africa"
    },
    {
    "code": 82,
    "label": "South Korea"
    },
    {
    "code": 211,
    "label": "South Sudan"
    },
    {
    "code": 34,
    "label": "Spain"
    },
    {
    "code": 94,
    "label": "Sri Lanka"
    },
    {
    "code": 1,
    "label": "St. Lucia"
    },
    {
    "code": 249,
    "label": "Sudan"
    },
    {
    "code": 597,
    "label": "Suriname"
    },
    {
    "code": 268,
    "label": "Swaziland"
    },
    {
    "code": 46,
    "label": "Sweden"
    },
    {
    "code": 41,
    "label": "Switzerland"
    },
    {
    "code": 963,
    "label": "Syria"
    },
    {
    "code": 886,
    "label": "Taiwan"
    },
    {
    "code": 992,
    "label": "Tajikistan"
    },
    {
    "code": 255,
    "label": "Tanzania"
    },
    {
    "code": 66,
    "label": "Thailand"
    },
    {
    "code": 1,
    "label": "The Bahamas"
    },
    {
    "code": 220,
    "label": "The Gambia"
    },
    {
    "code": 670,
    "label": "Timor-Leste"
    },
    {
    "code": 228,
    "label": "Togo"
    },
    {
    "code": 690,
    "label": "Tokelau"
    },
    {
    "code": 676,
    "label": "Tonga"
    },
    {
    "code": 1,
    "label": "Trinidad and Tobago"
    },
    {
    "code": 216,
    "label": "Tunisia"
    },
    {
    "code": 90,
    "label": "Turkey"
    },
    {
    "code": 993,
    "label": "Turkmenistan"
    },
    {
    "code": 1,
    "label": "Turks and Caicos Islands"
    },
    {
    "code": 688,
    "label": "Tuvalu"
    },
    {
    "code": 256,
    "label": "Uganda"
    },
    {
    "code": 971,
    "label": "United Arab Emirates"
    },
    {
    "code": 44,
    "label": "United Kingdom"
    },
    {
    "code": 598,
    "label": "Uruguay"
    },
    {
    "code": 1,
    "label": "US Virgin Islands"
    },
    {
    "code": 998,
    "label": "Uzbekistan"
    },
    {
    "code": 678,
    "label": "Vanuatu"
    },
    {
    "code": 39,
    "label": "Vatican City"
    },
    {
    "code": 58,
    "label": "Venezuela"
    },
    {
    "code": 84,
    "label": "Vietnam"
    },
    {
    "code": 681,
    "label": "Wallis and Futuna"
    },
    {
    "code": 212,
    "label": "Western Sahara"
    },
    {
    "code": 967,
    "label": "Yemen"
    },
    {
    "code": 260,
    "label": "Zambia"
    },
    {
    "code": 263,
    "label": "Zimbabwe"
    }
 */
    
}
