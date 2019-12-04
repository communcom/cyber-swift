//
//  City.swift
//  CyberSwift
//
//  Created by msm72 on 4/10/19.
//  Copyright © 2019 golos.io. All rights reserved.
//
//  https://www.countryflags.com/en/
//  https://en.wikipedia.org/wiki/List_of_mobile_telephone_prefixes_by_country#cite_note-prefix_note-1
//

import Foundation

public class Country: Encodable {
    public var code: UInt16
    public var shortCode: String
    public var label: String
    public var flagURL: URL
    public var `default`: Bool
    public var verificationPhone: String
    public var verificationOverrides: Override?
    public var nsn: UInt?

    public var phoneCode: String {
        return "+\(code)"
    }


    init(codeValue: UInt16, shortCodeValue: String, labelValue: String, flagURLString: String, defaultValue: Bool = false, verificationPhoneValue: String = "", verificationOverridesValue: Override? = nil, nsnValue: UInt? = nil) {
        self.code = codeValue
        self.shortCode = shortCodeValue
        self.label = labelValue
        self.flagURL = URL(string: flagURLString)!
        self.default = defaultValue
        self.verificationPhone = verificationPhoneValue
        self.verificationOverrides = verificationOverridesValue
        self.nsn = nsnValue
    }
    
    public var localizedName: String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: shortCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return label
        }
    }
}

public struct Override: Encodable {
    let startsWith: [String]
    let verificationPhone: String
}


public class PhoneCode {
    // MARK: - Properties
    class UnitedStates: Country {}
    class Russia: Country {}
    class Kazakhstan: Country {}
    class Lithuania: Country {}
    class Belarus: Country {}
    class Ukraine: Country {}
    class Afghanistan: Country {}
    class Albania: Country {}
    class Algeria: Country {}
    class AmericanSamoa: Country {}
    class Andorra: Country {}
    class Angola: Country {}
    class Anguilla: Country {}
    class Antigua: Country {}
    class Argentina: Country {}
    class Armenia: Country {}
    class Aruba: Country {}
    class Australia: Country {}
    class Austria: Country {}
    class Azerbaijan: Country {}
    class Bahrain: Country {}
    class Bangladesh: Country {}
    class Barbados: Country {}
    class Belgium: Country {}
    class Belize: Country {}
    class Benin: Country {}
    class Bermuda: Country {}
    class Bhutan: Country {}
    class Bolivia: Country {}
    class BonaireSintEustatiusSaba: Country {}
    class BosniaHerzegovina: Country {}
    class Botswana: Country {}
    class Brazil: Country {}
    class BritishIndianOceanTerritory: Country {}
    class BritishVirginIslands: Country {}
    class Brunei: Country {}
    class Bulgaria: Country {}
    class BurkinaFaso: Country {}
    class Burundi: Country {}
    class Cambodia: Country {}
    class Cameroon: Country {}
    class Canada: Country {}
    class CapeVerde: Country {}
    class CaymanIslands: Country {}
    class CentralAfricanRepublic: Country {}
    class Chad: Country {}
    class Chile: Country {}
    class China: Country {}
    class Colombia: Country {}
    class Comoros: Country {}
    class CookIslands: Country {}
    class CostaRica: Country {}
    class CoteDivoire: Country {}
    class Croatia: Country {}
    class Cuba: Country {}
//    class Curacao: Country {}
    class Cyprus: Country {}
    class CzechRepublic: Country {}
    class DemocraticRepublicCongo: Country {}
    class Denmark: Country {}
    class Djibouti: Country {}
    class Dominica: Country {}
    class DominicanRepublic: Country {}
    class Ecuador: Country {}
    class Egypt: Country {}
    class ElSalvador: Country {}
    class EquatorialGuinea: Country {}
    class Eritrea: Country {}
    class Estonia: Country {}
    class Ethiopia: Country {}
    class FalklandIslands: Country {}
    class FaroeIslands: Country {}
    class FederatedStatesMicronesia: Country {}
    class Fiji: Country {}
    class Finland: Country {}
    class France: Country {}
    class FrenchGuiana: Country {}
    class FrenchPolynesia: Country {}
    class Gabon: Country {}
    class Georgia: Country {}
    class Germany: Country {}
    class Ghana: Country {}
    class Gibraltar: Country {}
    class Greece: Country {}
    class Greenland: Country {}
    class Grenada: Country {}
    class Guadeloupe: Country {}
    class Guam: Country {}
    class Guatemala: Country {}
    class Guernsey: Country {}
    class Guinea: Country {}
    class GuineaBissau: Country {}
    class Guyana: Country {}
    class Haiti: Country {}
    class Honduras: Country {}
    class HongKong: Country {}
    class Hungary: Country {}
    class Iceland: Country {}
    class India: Country {}
    class Indonesia: Country {}
    class Iran: Country {}
    class Iraq: Country {}
    class Ireland: Country {}
    class IsleMan: Country {}
    class Israel: Country {}
    class Italy: Country {}
    class Jamaica: Country {}
    class Japan: Country {}
    class Jersey: Country {}
    class Jordan: Country {}
    class Kenya: Country {}
    class Kiribati: Country {}
    class Kosovo: Country {}
    class Kuwait: Country {}
    class Kyrgyzstan: Country {}
    class Laos: Country {}
    class Latvia: Country {}
    class Lebanon: Country {}
    class Lesotho: Country {}
    class Liberia: Country {}
    class Libya: Country {}
    class Liechtenstein: Country {}
    class Luxembourg: Country {}
    class Macau: Country {}
    class Macedonia: Country {}
    class Madagascar: Country {}
    class Malawi: Country {}
    class Malaysia: Country {}
    class Maldives: Country {}
    class Mali: Country {}
    class Malta: Country {}
    class MarshallIslands: Country {}
    class Martinique: Country {}
    class Mauritania: Country {}
    class Mauritius: Country {}
    class Mayotte: Country {}
    class Mexico: Country {}
    class Moldova: Country {}
    class Monaco: Country {}
    class Mongolia: Country {}
    class Montenegro: Country {}
    class Montserrat: Country {}
    class Morocco: Country {}
    class Mozambique: Country {}
    class Myanmar: Country {}
    class Namibia: Country {}
    class Nauru: Country {}
    class Netherlands: Country {}
    class NewCaledonia: Country {}
    class NewZealand: Country {}
    class Nicaragua: Country {}
    class Niger: Country {}
    class Nigeria: Country {}
    class Niue: Country {}
    class NorfolkIsland: Country {}
    class NorthKorea: Country {}
    class NorthernMarianaIslands: Country {}
    class Norway: Country {}
    class Oman: Country {}
    class Pakistan: Country {}
    class Palau: Country {}
    class Palestine: Country {}
    class Panama: Country {}
    class PapuaNewGuinea: Country {}
    class Paraguay: Country {}
    class Peru: Country {}
    class Philippines: Country {}
    class Poland: Country {}
    class Portugal: Country {}
    class PuertoRico: Country {}
    class Qatar: Country {}
    class RepublicCongo: Country {}
    class Réunion: Country {}
    class Romania: Country {}
    class Rwanda: Country {}
    class SaintBarthélemy: Country {}
    class SaintHelena: Country {}
    class SaintKittsNevis: Country {}
    class SaintMartin: Country {}
    class SaintPierreMiquelon: Country {}
    class SaintVincentGrenadines: Country {}
    class Samoa: Country {}
    class SanMarino: Country {}
    class SaoTomePrincipe: Country {}
    class SaudiArabia: Country {}
    class Senegal: Country {}
    class Serbia: Country {}
    class Seychelles: Country {}
    class SierraLeone: Country {}
    class Singapore: Country {}
    class SintMaarten: Country {}
    class Slovakia: Country {}
    class Slovenia: Country {}
    class SolomonIslands: Country {}
    class Somalia: Country {}
    class SouthAfrica: Country {}
    class SouthKorea: Country {}
    class SouthSudan: Country {}
    class Spain: Country {}
    class SriLanka: Country {}
    class SaintLucia: Country {}
    class Sudan: Country {}
    class Suriname: Country {}
    class Swaziland: Country {}
    class Sweden: Country {}
    class Switzerland: Country {}
    class Syria: Country {}
    class Taiwan: Country {}
    class Tajikistan: Country {}
    class Tanzania: Country {}
    class Thailand: Country {}
    class Bahamas: Country {}
    class Gambia: Country {}
    class TimorLeste: Country {}
    class Togo: Country {}
    class Tokelau: Country {}
    class Tonga: Country {}
    class TrinidadTobago: Country {}
    class Tunisia: Country {}
    class Turkey: Country {}
    class Turkmenistan: Country {}
    class TurksCaicosIslands: Country {}
    class Tuvalu: Country {}
    class Uganda: Country {}
    class UnitedArabEmirates: Country {}
    class UnitedKingdom: Country {}
    class Uruguay: Country {}
    class USVirginIslands: Country {}
    class Uzbekistan: Country {}
    class Vanuatu: Country {}
    class VaticanCity: Country {}
    class Venezuela: Country {}
    class Vietnam: Country {}
    class WallisFutuna: Country {}
    class WesternSahara: Country {}
    class Yemen: Country {}
    class Zambia: Country {}
    class Zimbabwe: Country {}

    
    // MARK: - Functions
    public class func getCountries() -> [Country] {
        return [ UnitedStates(codeValue: 1, shortCodeValue: "US", labelValue: "United States", flagURLString: "https://cdn.countryflags.com/thumbs/united-states-of-america/flag-800.png"),
                 Russia(codeValue: 7, shortCodeValue: "RU", labelValue: "Russia", flagURLString: "https://cdn.countryflags.com/thumbs/russia/flag-800.png", defaultValue: true, verificationPhoneValue: "+7 (916) 930-63-59", nsnValue: 10),
                 Kazakhstan(codeValue: 7, shortCodeValue: "KZ", labelValue: "Kazakhstan", flagURLString: "https://cdn.countryflags.com/thumbs/kazakhstan/flag-800.png", verificationPhoneValue: "+7 (777) 007-69-77", nsnValue: 10),
                 Lithuania(codeValue: 370, shortCodeValue: "LT", labelValue: "Lithuania", flagURLString: "https://cdn.countryflags.com/thumbs/lithuania/flag-800.png", nsnValue: 8),
                 Belarus(codeValue: 375, shortCodeValue: "BY", labelValue: "Belarus", flagURLString: "https://cdn.countryflags.com/thumbs/belarus/flag-800.png", verificationPhoneValue: "+375 (29) 230-87-70", nsnValue: 9),
                 Ukraine(codeValue: 380, shortCodeValue: "UA", labelValue: "Ukraine", flagURLString: "https://cdn.countryflags.com/thumbs/ukraine/flag-800.png", verificationPhoneValue: "+380 (93) 177-77-72", verificationOverridesValue: Override(startsWith: ["62", "64", "71", "72"], verificationPhone: "+7 (916) 930-63-59"), nsnValue: 9),
                 Afghanistan(codeValue: 93, shortCodeValue: "AF", labelValue: "Afghanistan", flagURLString: "https://cdn.countryflags.com/thumbs/afghanistan/flag-800.png", nsnValue: 9),
                 Albania(codeValue: 355, shortCodeValue: "AL", labelValue: "Albania", flagURLString: "https://cdn.countryflags.com/thumbs/albania/flag-800.png", nsnValue: 9),
                 Algeria(codeValue: 213, shortCodeValue: "DZ", labelValue: "Algeria", flagURLString: "https://cdn.countryflags.com/thumbs/algeria/flag-800.png"),
                 AmericanSamoa(codeValue: 1, shortCodeValue: "AS", labelValue: "American Samoa", flagURLString: "https://cdn.countryflags.com/thumbs/samoa/flag-800.png"),
                 Andorra(codeValue: 376, shortCodeValue: "AD", labelValue: "Andorra", flagURLString: "https://cdn.countryflags.com/thumbs/andorra/flag-800.png"),
                 Angola(codeValue: 244, shortCodeValue: "AO", labelValue: "Angola", flagURLString: "https://cdn.countryflags.com/thumbs/angola/flag-800.png"),
                 Anguilla(codeValue: 1, shortCodeValue: "AI", labelValue: "Anguilla", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Flag_of_Anguilla.svg/2880px-Flag_of_Anguilla.svg.png", nsnValue: 10),
                 Antigua(codeValue: 1, shortCodeValue: "AG", labelValue: "Antigua", flagURLString: "https://cdn.countryflags.com/thumbs/antigua-and-barbuda/flag-800.png", nsnValue: 10),
                 Argentina(codeValue: 54, shortCodeValue: "AR", labelValue: "Argentina", flagURLString: "https://cdn.countryflags.com/thumbs/argentina/flag-800.png"),
                 Armenia(codeValue: 374, shortCodeValue: "AM", labelValue: "Armenia", flagURLString: "https://cdn.countryflags.com/thumbs/armenia/flag-800.png"),
                 Aruba(codeValue: 297, shortCodeValue: "AW", labelValue: "Aruba", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Aruba.svg/2560px-Flag_of_Aruba.svg.png"),
                 Australia(codeValue: 61, shortCodeValue: "AU", labelValue: "Australia", flagURLString: "https://cdn.countryflags.com/thumbs/australia/flag-800.png", nsnValue: 9),
                 Austria(codeValue: 43, shortCodeValue: "AT", labelValue: "Austria", flagURLString: "https://cdn.countryflags.com/thumbs/austria/flag-800.png", nsnValue: 10),
                 Azerbaijan(codeValue: 994, shortCodeValue: "AZ", labelValue: "Azerbaijan", flagURLString: "https://cdn.countryflags.com/thumbs/azerbaijan/flag-800.png"),
                 Bahrain(codeValue: 973, shortCodeValue: "BH", labelValue: "Bahrain", flagURLString: "https://cdn.countryflags.com/thumbs/bahrain/flag-800.png"),
                 Bangladesh(codeValue: 880, shortCodeValue: "BD", labelValue: "Bangladesh", flagURLString: "https://cdn.countryflags.com/thumbs/bangladesh/flag-800.png"),
                 Barbados(codeValue: 1, shortCodeValue: "BB", labelValue: "Barbados", flagURLString: "https://cdn.countryflags.com/thumbs/barbados/flag-800.png", nsnValue: 10),
                 Belgium(codeValue: 32, shortCodeValue: "BE", labelValue: "Belgium", flagURLString: "https://cdn.countryflags.com/thumbs/belgium/flag-800.png", nsnValue: 9),
                 Belize(codeValue: 501, shortCodeValue: "BZ", labelValue: "Belize", flagURLString: "https://cdn.countryflags.com/thumbs/belize/flag-800.png"),
                 Benin(codeValue: 229, shortCodeValue: "BJ", labelValue: "Benin", flagURLString: "https://cdn.countryflags.com/thumbs/benin/flag-800.png"),
                 Bermuda(codeValue: 1, shortCodeValue: "BM", labelValue: "Bermuda", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Flag_of_Bermuda.svg/2880px-Flag_of_Bermuda.svg.png", nsnValue: 10),
                 Bhutan(codeValue: 975, shortCodeValue: "BT", labelValue: "Bhutan", flagURLString: "https://cdn.countryflags.com/thumbs/bhutan/flag-800.png"),
                 Bolivia(codeValue: 591, shortCodeValue: "BO", labelValue: "Bolivia", flagURLString: "https://cdn.countryflags.com/thumbs/bolivia/flag-800.png"),
                 BonaireSintEustatiusSaba(codeValue: 599, shortCodeValue: "BS", labelValue: "Bonaire, Sint Eustatius and Saba", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/2560px-Flag_of_the_Netherlands.svg.png"),
                 BosniaHerzegovina(codeValue: 387, shortCodeValue: "BA", labelValue: "Bosnia and Herzegovina", flagURLString: "https://cdn.countryflags.com/thumbs/bosnia-and-herzegovina/flag-800.png"),
                 Botswana(codeValue: 267, shortCodeValue: "BW", labelValue: "Botswana", flagURLString: "https://cdn.countryflags.com/thumbs/botswana/flag-800.png"),
                 Brazil(codeValue: 55, shortCodeValue: "BR", labelValue: "Brazil", flagURLString: "https://cdn.countryflags.com/thumbs/brazil/flag-800.png", nsnValue: 11),
                 BritishIndianOceanTerritory(codeValue: 246, shortCodeValue: "IO", labelValue: "British Indian Ocean Territory", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Flag_of_the_British_Indian_Ocean_Territory.svg/2880px-Flag_of_the_British_Indian_Ocean_Territory.svg.png"),
                 BritishVirginIslands(codeValue: 1, shortCodeValue: "VG", labelValue: "British Virgin Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Flag_of_the_British_Virgin_Islands.svg/2880px-Flag_of_the_British_Virgin_Islands.svg.png", nsnValue: 10),
                 Brunei(codeValue: 673, shortCodeValue: "BN", labelValue: "Brunei", flagURLString: "https://cdn.countryflags.com/thumbs/brunei/flag-800.png"),
                 Bulgaria(codeValue: 359, shortCodeValue: "BG", labelValue: "Bulgaria", flagURLString: "https://cdn.countryflags.com/thumbs/bulgaria/flag-800.png"),
                 BurkinaFaso(codeValue: 226, shortCodeValue: "BF", labelValue: "Burkina Faso", flagURLString: "https://cdn.countryflags.com/thumbs/burkina-faso/flag-800.png"),
                 Burundi(codeValue: 257, shortCodeValue: "BI", labelValue: "Burundi", flagURLString: "https://cdn.countryflags.com/thumbs/burundi/flag-800.png"),
                 Cambodia(codeValue: 855, shortCodeValue: "KH", labelValue: "Cambodia", flagURLString: "https://cdn.countryflags.com/thumbs/cambodia/flag-800.png"),
                 Cameroon(codeValue: 237, shortCodeValue: "CM", labelValue: "Cameroon", flagURLString: "https://cdn.countryflags.com/thumbs/cameroon/flag-800.png"),
                 Canada(codeValue: 1, shortCodeValue: "CA", labelValue: "Canada", flagURLString: "https://cdn.countryflags.com/thumbs/canada/flag-800.png", nsnValue: 10),
                 CapeVerde(codeValue: 238, shortCodeValue: "CV", labelValue: "Cape Verde", flagURLString: "https://cdn.countryflags.com/thumbs/cape-verde/flag-800.png"),
                 CaymanIslands(codeValue: 1, shortCodeValue: "KY", labelValue: "Cayman Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Flag_of_the_Cayman_Islands.svg/2880px-Flag_of_the_Cayman_Islands.svg.png", nsnValue: 10),
                 CentralAfricanRepublic(codeValue: 236, shortCodeValue: "CF", labelValue: "Central African Republic", flagURLString: "https://cdn.countryflags.com/thumbs/central-african-republic/flag-800.png"),
                 Chad(codeValue: 235, shortCodeValue: "TD", labelValue: "Chad", flagURLString: "https://cdn.countryflags.com/thumbs/chad/flag-800.png"),
                 Chile(codeValue: 56, shortCodeValue: "CL", labelValue: "Chile", flagURLString: "https://cdn.countryflags.com/thumbs/chile/flag-800.png", nsnValue: 9),
                 China(codeValue: 86, shortCodeValue: "CN", labelValue: "China", flagURLString: "https://cdn.countryflags.com/thumbs/china/flag-800.png", nsnValue: 11),
                 Colombia(codeValue: 57, shortCodeValue: "CO", labelValue: "Colombia", flagURLString: "https://cdn.countryflags.com/thumbs/colombia/flag-800.png", nsnValue: 10),
                 Comoros(codeValue: 269, shortCodeValue: "KM", labelValue: "Comoros", flagURLString: "https://cdn.countryflags.com/thumbs/comoros/flag-800.png"),
                 CookIslands(codeValue: 682, shortCodeValue: "CK", labelValue: "Cook Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Flag_of_the_Cook_Islands.svg/2880px-Flag_of_the_Cook_Islands.svg.png"),
                 CostaRica(codeValue: 506, shortCodeValue: "CR", labelValue: "Costa Rica", flagURLString: "https://cdn.countryflags.com/thumbs/costa-rica/flag-800.png"),
                 CoteDivoire(codeValue: 225, shortCodeValue: "CI", labelValue: "Côte d'Ivoire", flagURLString: "https://cdn.countryflags.com/thumbs/cote-d-ivoire/flag-800.png"),
                 Croatia(codeValue: 385, shortCodeValue: "HR", labelValue: "Croatia", flagURLString: "https://cdn.countryflags.com/thumbs/croatia/flag-800.png"),
                 Cuba(codeValue: 53, shortCodeValue: "CU", labelValue: "Cuba", flagURLString: "https://cdn.countryflags.com/thumbs/cuba/flag-800.png"),
//                 Curacao(codeValue: 599, shortCodeValue: "CW", labelValue: "Curaçao", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Flag_of_Curaçao.svg/2560px-Flag_of_Curaçao.svg.png"),
                 Cyprus(codeValue: 357, shortCodeValue: "CY", labelValue: "Cyprus", flagURLString: "https://cdn.countryflags.com/thumbs/cyprus/flag-800.png"),
                 CzechRepublic(codeValue: 420, shortCodeValue: "CZ", labelValue: "Czech Republic", flagURLString: "https://cdn.countryflags.com/thumbs/czech-republic/flag-800.png"),
                 DemocraticRepublicCongo(codeValue: 243, shortCodeValue: "CD", labelValue: "Democratic Republic of the Congo", flagURLString: "https://cdn.countryflags.com/thumbs/congo-democratic-republic-of-the/flag-800.png"),
                 Denmark(codeValue: 45, shortCodeValue: "DK", labelValue: "Denmark", flagURLString: "https://cdn.countryflags.com/thumbs/denmark/flag-800.png", nsnValue: 8),
                 Djibouti(codeValue: 253, shortCodeValue: "DJ", labelValue: "Djibouti", flagURLString: "https://cdn.countryflags.com/thumbs/djibouti/flag-800.png"),
                 Dominica(codeValue: 1, shortCodeValue: "DM", labelValue: "Dominica", flagURLString: "https://cdn.countryflags.com/thumbs/dominica/flag-800.png", nsnValue: 10),
                 DominicanRepublic(codeValue: 1, shortCodeValue: "DO", labelValue: "Dominican Republic", flagURLString: "https://cdn.countryflags.com/thumbs/dominican-republic/flag-800.png", nsnValue: 10),
                 Ecuador(codeValue: 593, shortCodeValue: "EC", labelValue: "Ecuador", flagURLString: "https://cdn.countryflags.com/thumbs/ecuador/flag-800.png"),
                 Egypt(codeValue: 20, shortCodeValue: "EG", labelValue: "Egypt", flagURLString: "https://cdn.countryflags.com/thumbs/egypt/flag-800.png", nsnValue: 10),
                 ElSalvador(codeValue: 503, shortCodeValue: "SV", labelValue: "El Salvador", flagURLString: "https://cdn.countryflags.com/thumbs/el-salvador/flag-800.png"),
                 EquatorialGuinea(codeValue: 240, shortCodeValue: "GQ", labelValue: "Equatorial Guinea", flagURLString: "https://cdn.countryflags.com/thumbs/equatorial-guinea/flag-800.png"),
                 Eritrea(codeValue: 291, shortCodeValue: "ER", labelValue: "Eritrea", flagURLString: "https://cdn.countryflags.com/thumbs/eritrea/flag-800.png"),
                 Estonia(codeValue: 372, shortCodeValue: "EE", labelValue: "Estonia", flagURLString: "https://cdn.countryflags.com/thumbs/estonia/flag-800.png"),
                 Ethiopia(codeValue: 251, shortCodeValue: "ET", labelValue: "Ethiopia", flagURLString: "https://cdn.countryflags.com/thumbs/ethiopia/flag-800.png"),
                 FalklandIslands(codeValue: 500, shortCodeValue: "FK", labelValue: "Falkland Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Flag_of_the_Falkland_Islands.svg/2880px-Flag_of_the_Falkland_Islands.svg.png"),
                 FaroeIslands(codeValue: 298, shortCodeValue: "FO", labelValue: "Faroe Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Flag_of_the_Faroe_Islands.svg/1920px-Flag_of_the_Faroe_Islands.svg.png"),
                 FederatedStatesMicronesia(codeValue: 691, shortCodeValue: "FM", labelValue: "Federated States of Micronesia", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Flag_of_the_Federated_States_of_Micronesia.svg/2560px-Flag_of_the_Federated_States_of_Micronesia.svg.png"),
                 Fiji(codeValue: 679, shortCodeValue: "FJ", labelValue: "Fiji", flagURLString: "https://cdn.countryflags.com/thumbs/fiji/flag-800.png"),
                 Finland(codeValue: 358, shortCodeValue: "FI", labelValue: "Finland", flagURLString: "https://cdn.countryflags.com/thumbs/finland/flag-800.png"),
                 France(codeValue: 33, shortCodeValue: "FR", labelValue: "France", flagURLString: "https://cdn.countryflags.com/thumbs/france/flag-800.png", nsnValue: 9),
                 FrenchGuiana(codeValue: 594, shortCodeValue: "GF", labelValue: "French Guiana", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 FrenchPolynesia(codeValue: 689, shortCodeValue: "PF", labelValue: "French Polynesia", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Flag_of_French_Polynesia.svg/2560px-Flag_of_French_Polynesia.svg.png"),
                 Gabon(codeValue: 241, shortCodeValue: "GA", labelValue: "Gabon", flagURLString: "https://cdn.countryflags.com/thumbs/gabon/flag-800.png"),
                 Georgia(codeValue: 995, shortCodeValue: "GE", labelValue: "Georgia", flagURLString: "https://cdn.countryflags.com/thumbs/georgia/flag-800.png"),
                 Germany(codeValue: 49, shortCodeValue: "DE", labelValue: "Germany", flagURLString: "https://cdn.countryflags.com/thumbs/germany/flag-800.png", nsnValue: 10),
                 Ghana(codeValue: 233, shortCodeValue: "GH", labelValue: "Ghana", flagURLString: "https://cdn.countryflags.com/thumbs/ghana/flag-800.png"),
                 Gibraltar(codeValue: 350, shortCodeValue: "GI", labelValue: "Gibraltar", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Flag_of_Gibraltar.svg/2880px-Flag_of_Gibraltar.svg.png"),
                 Greece(codeValue: 30, shortCodeValue: "GR", labelValue: "Greece", flagURLString: "https://cdn.countryflags.com/thumbs/greece/flag-800.png", nsnValue: 10),
                 Greenland(codeValue: 299, shortCodeValue: "GL", labelValue: "Greenland", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_Greenland.svg/2560px-Flag_of_Greenland.svg.png"),
                 Grenada(codeValue: 1, shortCodeValue: "GD", labelValue: "Grenada", flagURLString: "https://cdn.countryflags.com/thumbs/grenada/flag-800.png", nsnValue: 10),
                 Guadeloupe(codeValue: 590, shortCodeValue: "GP", labelValue: "Guadeloupe", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 Guam(codeValue: 1, shortCodeValue: "GU", labelValue: "Guam", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Flag_of_Guam.svg/2560px-Flag_of_Guam.svg.png", nsnValue: 10),
                 Guatemala(codeValue: 502, shortCodeValue: "GT", labelValue: "Guatemala", flagURLString: "https://cdn.countryflags.com/thumbs/guatemala/flag-800.png"),
                 Guernsey(codeValue: 44, shortCodeValue: "GG", labelValue: "Guernsey", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_Guernsey.svg/2560px-Flag_of_Guernsey.svg.png", nsnValue: 10),
                 Guinea(codeValue: 224, shortCodeValue: "GN", labelValue: "Guinea", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Flag_of_Guinea.svg/2560px-Flag_of_Guinea.svg.png"),
                 GuineaBissau(codeValue: 245, shortCodeValue: "GW", labelValue: "Guinea-Bissau", flagURLString: "https://cdn.countryflags.com/thumbs/guinea-bissau/flag-800.png"),
                 Guyana(codeValue: 592, shortCodeValue: "GY", labelValue: "Guyana", flagURLString: "https://cdn.countryflags.com/thumbs/guyana/flag-800.png"),
                 Haiti(codeValue: 509, shortCodeValue: "HT", labelValue: "Haiti", flagURLString: "https://cdn.countryflags.com/thumbs/haiti/flag-800.png"),
                 Honduras(codeValue: 504, shortCodeValue: "HN", labelValue: "Honduras", flagURLString: "https://cdn.countryflags.com/thumbs/honduras/flag-800.png"),
                 HongKong(codeValue: 852, shortCodeValue: "HK", labelValue: "Hong Kong", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Flag_of_Hong_Kong.svg/2560px-Flag_of_Hong_Kong.svg.png"),
                 Hungary(codeValue: 36, shortCodeValue: "HU", labelValue: "Hungary", flagURLString: "https://cdn.countryflags.com/thumbs/hungary/flag-800.png", nsnValue: 9),
                 Iceland(codeValue: 354, shortCodeValue: "IS", labelValue: "Iceland", flagURLString: "https://cdn.countryflags.com/thumbs/iceland/flag-800.png"),
                 India(codeValue: 91, shortCodeValue: "IN", labelValue: "India", flagURLString: "https://cdn.countryflags.com/thumbs/india/flag-800.png", nsnValue: 10),
                 Indonesia(codeValue: 62, shortCodeValue: "ID", labelValue: "Indonesia", flagURLString: "https://cdn.countryflags.com/thumbs/indonesia/flag-800.png", nsnValue: 10),
                 Iran(codeValue: 98, shortCodeValue: "IR", labelValue: "Iran", flagURLString: "https://cdn.countryflags.com/thumbs/iran/flag-800.png", nsnValue: 10),
                 Iraq(codeValue: 964, shortCodeValue: "IQ", labelValue: "Iraq", flagURLString: "https://cdn.countryflags.com/thumbs/iraq/flag-800.png"),
                 Ireland(codeValue: 353, shortCodeValue: "IE", labelValue: "Ireland", flagURLString: "https://cdn.countryflags.com/thumbs/ireland/flag-800.png"),
                 IsleMan(codeValue: 44, shortCodeValue: "IM", labelValue: "Isle Of Man", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Flag_of_the_Isle_of_Mann.svg/2880px-Flag_of_the_Isle_of_Mann.svg.png", nsnValue: 10),
                 Israel(codeValue: 972, shortCodeValue: "IL", labelValue: "Israel", flagURLString: "https://cdn.countryflags.com/thumbs/israel/flag-800.png"),
                 Italy(codeValue: 39, shortCodeValue: "IT", labelValue: "Italy", flagURLString: "https://cdn.countryflags.com/thumbs/italy/flag-800.png", nsnValue: 10),
                 Jamaica(codeValue: 1, shortCodeValue: "JM", labelValue: "Jamaica", flagURLString: "https://cdn.countryflags.com/thumbs/jamaica/flag-800.png", nsnValue: 10),
                 Japan(codeValue: 81, shortCodeValue: "JP", labelValue: "Japan", flagURLString: "https://cdn.countryflags.com/thumbs/japan/flag-800.png", nsnValue: 11),
                 Jersey(codeValue: 44, shortCodeValue: "JE", labelValue: "Jersey", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Flag_of_Jersey.svg/2560px-Flag_of_Jersey.svg.png", nsnValue: 10),
                 Jordan(codeValue: 962, shortCodeValue: "JO", labelValue: "Jordan", flagURLString: "https://cdn.countryflags.com/thumbs/jordan/flag-800.png"),
                 Kenya(codeValue: 254, shortCodeValue: "KE", labelValue: "Kenya", flagURLString: "https://cdn.countryflags.com/thumbs/kenya/flag-800.png"),
                 Kiribati(codeValue: 686, shortCodeValue: "KI", labelValue: "Kiribati", flagURLString: "https://cdn.countryflags.com/thumbs/kiribati/flag-800.png"),
                 Kosovo(codeValue: 383, shortCodeValue: "XK", labelValue: "Kosovo", flagURLString: "https://cdn.countryflags.com/thumbs/kosovo/flag-800.png"),
                 Kuwait(codeValue: 965, shortCodeValue: "KW", labelValue: "Kuwait", flagURLString: "https://cdn.countryflags.com/thumbs/kuwait/flag-800.png"),
                 Kyrgyzstan(codeValue: 996, shortCodeValue: "KG", labelValue: "Kyrgyzstan", flagURLString: "https://cdn.countryflags.com/thumbs/kyrgyzstan/flag-800.png"),
                 Laos(codeValue: 856, shortCodeValue: "LA", labelValue: "Laos", flagURLString: "https://cdn.countryflags.com/thumbs/laos/flag-800.png"),
                 Latvia(codeValue: 371, shortCodeValue: "LV", labelValue: "Latvia", flagURLString: "https://cdn.countryflags.com/thumbs/latvia/flag-800.png"),
                 Lebanon(codeValue: 961, shortCodeValue: "LB", labelValue: "Lebanon", flagURLString: "https://cdn.countryflags.com/thumbs/lebanon/flag-800.png"),
                 Lesotho(codeValue: 266, shortCodeValue: "LS", labelValue: "Lesotho", flagURLString: "https://cdn.countryflags.com/thumbs/lesotho/flag-800.png"),
                 Liberia(codeValue: 231, shortCodeValue: "LR", labelValue: "Liberia", flagURLString: "https://cdn.countryflags.com/thumbs/liberia/flag-800.png"),
                 Libya(codeValue: 218, shortCodeValue: "LY", labelValue: "Libya", flagURLString: "https://cdn.countryflags.com/thumbs/libya/flag-800.png"),
                 Liechtenstein(codeValue: 423, shortCodeValue: "LI", labelValue: "Liechtenstein", flagURLString: "https://cdn.countryflags.com/thumbs/liechtenstein/flag-800.png"),
                 Luxembourg(codeValue: 352, shortCodeValue: "LU", labelValue: "Luxembourg", flagURLString: "https://cdn.countryflags.com/thumbs/luxembourg/flag-800.png"),
                 Macau(codeValue: 853, shortCodeValue: "MO", labelValue: "Macau", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Macau.svg/2560px-Flag_of_Macau.svg.png"),
                 Macedonia(codeValue: 389, shortCodeValue: "MK", labelValue: "Macedonia", flagURLString: "https://cdn.countryflags.com/thumbs/macedonia/flag-800.png"),
                 Madagascar(codeValue: 261, shortCodeValue: "MG", labelValue: "Madagascar", flagURLString: "https://cdn.countryflags.com/thumbs/madagascar/flag-800.png"),
                 Malawi(codeValue: 265, shortCodeValue: "MW", labelValue: "Malawi", flagURLString: "https://cdn.countryflags.com/thumbs/malawi/flag-800.png"),
                 Malaysia(codeValue: 60, shortCodeValue: "MY", labelValue: "Malaysia", flagURLString: "https://cdn.countryflags.com/thumbs/malaysia/flag-800.png"),
                 Maldives(codeValue: 960, shortCodeValue: "MV", labelValue: "Maldives", flagURLString: "https://cdn.countryflags.com/thumbs/maldives/flag-800.png"),
                 Mali(codeValue: 223, shortCodeValue: "ML", labelValue: "Mali", flagURLString: "https://cdn.countryflags.com/thumbs/mali/flag-800.png"),
                 Malta(codeValue: 356, shortCodeValue: "MT", labelValue: "Malta", flagURLString: "https://cdn.countryflags.com/thumbs/malta/flag-800.png"),
                 MarshallIslands(codeValue: 692, shortCodeValue: "MH", labelValue: "Marshall Islands", flagURLString: "https://cdn.countryflags.com/thumbs/marshall-islands/flag-800.png"),
                 Martinique(codeValue: 596, shortCodeValue: "MQ", labelValue: "Martinique", flagURLString: "http://www.geognos.com/api/en/countries/flag/MQ.png"),
                 Mauritania(codeValue: 222, shortCodeValue: "MR", labelValue: "Mauritania", flagURLString: "https://cdn.countryflags.com/thumbs/mauritania/flag-800.png"),
                 Mauritius(codeValue: 230, shortCodeValue: "MU", labelValue: "Mauritius", flagURLString: "https://cdn.countryflags.com/thumbs/mauritius/flag-800.png"),
                 Mayotte(codeValue: 262, shortCodeValue: "YT", labelValue: "Mayotte", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Flag_of_Mayotte_%28local%29.svg/2560px-Flag_of_Mayotte_%28local%29.svg.png"),
                 Mexico(codeValue: 52, shortCodeValue: "MX", labelValue: "Mexico", flagURLString: "https://cdn.countryflags.com/thumbs/mexico/flag-800.png", nsnValue: 10),
                 Moldova(codeValue: 373, shortCodeValue: "MD", labelValue: "Moldova", flagURLString: "https://cdn.countryflags.com/thumbs/moldova/flag-800.png"),
                 Monaco(codeValue: 377, shortCodeValue: "MC", labelValue: "Monaco", flagURLString: "https://cdn.countryflags.com/thumbs/monaco/flag-800.png"),
                 Mongolia(codeValue: 976, shortCodeValue: "MN", labelValue: "Mongolia", flagURLString: "https://cdn.countryflags.com/thumbs/mongolia/flag-800.png"),
                 Montenegro(codeValue: 382, shortCodeValue: "ME", labelValue: "Montenegro", flagURLString: "https://cdn.countryflags.com/thumbs/montenegro/flag-800.png"),
                 Montserrat(codeValue: 1, shortCodeValue: "MS", labelValue: "Montserrat", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Flag_of_Montserrat.svg/2880px-Flag_of_Montserrat.svg.png", nsnValue: 10),
                 Morocco(codeValue: 212, shortCodeValue: "MA", labelValue: "Morocco", flagURLString: "https://cdn.countryflags.com/thumbs/morocco/flag-800.png"),
                 Mozambique(codeValue: 258, shortCodeValue: "MZ", labelValue: "Mozambique", flagURLString: "https://cdn.countryflags.com/thumbs/mozambique/flag-800.png"),
                 Myanmar(codeValue: 95, shortCodeValue: "MM", labelValue: "Myanmar", flagURLString: "https://cdn.countryflags.com/thumbs/myanmar/flag-800.png", nsnValue: 10),
                 Namibia(codeValue: 264, shortCodeValue: "NA", labelValue: "Namibia", flagURLString: "https://cdn.countryflags.com/thumbs/namibia/flag-800.png"),
                 Nauru(codeValue: 674, shortCodeValue: "NR", labelValue: "Nauru", flagURLString: "https://cdn.countryflags.com/thumbs/nauru/flag-800.png"),
                 Netherlands(codeValue: 31, shortCodeValue: "NL", labelValue: "Netherlands", flagURLString: "https://cdn.countryflags.com/thumbs/netherlands/flag-800.png", nsnValue: 9),
                 NewCaledonia(codeValue: 687, shortCodeValue: "NC", labelValue: "New Caledonia", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 NewZealand(codeValue: 64, shortCodeValue: "NZ", labelValue: "New Zealand", flagURLString: "https://cdn.countryflags.com/thumbs/new-zealand/flag-800.png"),
                 Nicaragua(codeValue: 505, shortCodeValue: "NI", labelValue: "Nicaragua", flagURLString: "https://cdn.countryflags.com/thumbs/nicaragua/flag-800.png"),
                 Niger(codeValue: 227, shortCodeValue: "NE", labelValue: "Niger", flagURLString: "https://cdn.countryflags.com/thumbs/niger/flag-800.png"),
                 Nigeria(codeValue: 234, shortCodeValue: "NG", labelValue: "Nigeria", flagURLString: "https://cdn.countryflags.com/thumbs/nigeria/flag-800.png"),
                 Niue(codeValue: 683, shortCodeValue: "NU", labelValue: "Niue", flagURLString: "https://cdn.countryflags.com/thumbs/niue/flag-800.png"),
                 NorfolkIsland(codeValue: 672, shortCodeValue: "NF", labelValue: "Norfolk Island", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Flag_of_Norfolk_Island.svg/2880px-Flag_of_Norfolk_Island.svg.png"),
                 NorthKorea(codeValue: 850, shortCodeValue: "KP", labelValue: "North Korea", flagURLString: "https://cdn.countryflags.com/thumbs/north-korea/flag-800.png"),
                 NorthernMarianaIslands(codeValue: 1, shortCodeValue: "MP", labelValue: "Northern Mariana Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Flag_of_the_Northern_Mariana_Islands.svg/2880px-Flag_of_the_Northern_Mariana_Islands.svg.png", nsnValue: 10),
                 Norway(codeValue: 47, shortCodeValue: "NO", labelValue: "Norway", flagURLString: "https://cdn.countryflags.com/thumbs/norway/flag-800.png", nsnValue: 8),
                 Oman(codeValue: 968, shortCodeValue: "OM", labelValue: "Oman", flagURLString: "https://cdn.countryflags.com/thumbs/oman/flag-800.png"),
                 Pakistan(codeValue: 92, shortCodeValue: "PK", labelValue: "Pakistan", flagURLString: "https://cdn.countryflags.com/thumbs/pakistan/flag-800.png", nsnValue: 10),
                 Palau(codeValue: 680, shortCodeValue: "PW", labelValue: "Palau", flagURLString: "https://cdn.countryflags.com/thumbs/palau/flag-800.png"),
                 Palestine(codeValue: 970, shortCodeValue: "PS", labelValue: "Palestine", flagURLString: "http://www.geognos.com/api/en/countries/flag/PS.png"),
                 Panama(codeValue: 507, shortCodeValue: "PA", labelValue: "Panama", flagURLString: "https://cdn.countryflags.com/thumbs/panama/flag-800.png"),
                 PapuaNewGuinea(codeValue: 675, shortCodeValue: "PG", labelValue: "Papua New Guinea", flagURLString: "https://cdn.countryflags.com/thumbs/papua-new-guinea/flag-800.png"),
                 Paraguay(codeValue: 595, shortCodeValue: "PY", labelValue: "Paraguay", flagURLString: "https://cdn.countryflags.com/thumbs/paraguay/flag-800.png"),
                 Peru(codeValue: 51, shortCodeValue: "PE", labelValue: "Peru", flagURLString: "https://cdn.countryflags.com/thumbs/peru/flag-800.png", nsnValue: 9),
                 Philippines(codeValue: 63, shortCodeValue: "PH", labelValue: "Philippines", flagURLString: "https://cdn.countryflags.com/thumbs/philippines/flag-800.png", nsnValue: 10),
                 Poland(codeValue: 48, shortCodeValue: "PL", labelValue: "Poland", flagURLString: "https://cdn.countryflags.com/thumbs/poland/flag-800.png", nsnValue: 9),
                 Portugal(codeValue: 351, shortCodeValue: "PT", labelValue: "Portugal", flagURLString: "https://cdn.countryflags.com/thumbs/portugal/flag-800.png"),
                 PuertoRico(codeValue: 1, shortCodeValue: "PR", labelValue: "Puerto Rico", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Flag_of_Puerto_Rico.svg/2560px-Flag_of_Puerto_Rico.svg.png", nsnValue: 10),
                 Qatar(codeValue: 974, shortCodeValue: "QA", labelValue: "Qatar", flagURLString: "https://cdn.countryflags.com/thumbs/qatar/flag-800.png"),
                 RepublicCongo(codeValue: 242, shortCodeValue: "CG", labelValue: "Republic of the Congo", flagURLString: "https://cdn.countryflags.com/thumbs/congo-democratic-republic-of-the/flag-800.png"),
                 Réunion(codeValue: 262, shortCodeValue: "RE", labelValue: "Réunion", flagURLString: "https://cdn.countryflags.com/thumbs/france/flag-800.png"),
                 Romania(codeValue: 40, shortCodeValue: "RO", labelValue: "Romania", flagURLString: "https://cdn.countryflags.com/thumbs/romania/flag-800.png"),
                 Rwanda(codeValue: 250, shortCodeValue: "RW", labelValue: "Rwanda", flagURLString: "https://cdn.countryflags.com/thumbs/rwanda/flag-800.png"),
                 SaintBarthélemy(codeValue: 590, shortCodeValue: "BL", labelValue: "Saint Barthélemy", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Flag_of_Saint_Barthelemy_%28local%29.svg/2560px-Flag_of_Saint_Barthelemy_%28local%29.svg.png"),
                 SaintHelena(codeValue: 290, shortCodeValue: "SH", labelValue: "Saint Helena", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Flag_of_Saint_Helena.svg/2880px-Flag_of_Saint_Helena.svg.png"),
                 SaintKittsNevis(codeValue: 1, shortCodeValue: "KN", labelValue: "Saint Kitts and Nevis", flagURLString: "https://cdn.countryflags.com/thumbs/saint-kitts-and-nevis/flag-800.png", nsnValue: 10),
                 SaintMartin(codeValue: 590, shortCodeValue: "MF", labelValue: "Saint Martin", flagURLString: "http://www.geognos.com/api/en/countries/flag/MF.png"),
                 SaintPierreMiquelon(codeValue: 508, shortCodeValue: "PM", labelValue: "Saint Pierre and Miquelon", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 SaintVincentGrenadines(codeValue: 1, shortCodeValue: "VC", labelValue: "Saint Vincent and the Grenadines", flagURLString: "https://cdn.countryflags.com/thumbs/saint-vincent-and-the-grenadines/flag-800.png", nsnValue: 10),
                 Samoa(codeValue: 685, shortCodeValue: "WS", labelValue: "Samoa", flagURLString: "https://cdn.countryflags.com/thumbs/samoa/flag-800.png"),
                 SanMarino(codeValue: 378, shortCodeValue: "SM", labelValue: "San Marino", flagURLString: "https://cdn.countryflags.com/thumbs/san-marino/flag-800.png"),
                 SaoTomePrincipe(codeValue: 239, shortCodeValue: "ST", labelValue: "Sao Tome and Principe", flagURLString: "https://cdn.countryflags.com/thumbs/sao-tome-and-principe/flag-800.png"),
                 SaudiArabia(codeValue: 966, shortCodeValue: "SA", labelValue: "Saudi Arabia", flagURLString: "https://cdn.countryflags.com/thumbs/saudi-arabia/flag-800.png"),
                 Senegal(codeValue: 221, shortCodeValue: "SN", labelValue: "Senegal", flagURLString: "https://cdn.countryflags.com/thumbs/senegal/flag-800.png"),
                 Serbia(codeValue: 381, shortCodeValue: "RS", labelValue: "Serbia", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Flag_of_Serbia.svg/2560px-Flag_of_Serbia.svg.png"),
                 Seychelles(codeValue: 248, shortCodeValue: "SC", labelValue: "Seychelles", flagURLString: "https://cdn.countryflags.com/thumbs/seychelles/flag-800.png"),
                 SierraLeone(codeValue: 232, shortCodeValue: "SL", labelValue: "Sierra Leone", flagURLString: "https://cdn.countryflags.com/thumbs/sierra-leone/flag-800.png"),
                 Singapore(codeValue: 65, shortCodeValue: "SG", labelValue: "Singapore", flagURLString: "https://cdn.countryflags.com/thumbs/singapore/flag-800.png", nsnValue: 8),
                 SintMaarten(codeValue: 1, shortCodeValue: "SX", labelValue: "Sint Maarten", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Sint_Maarten.svg/2560px-Flag_of_Sint_Maarten.svg.png", nsnValue: 10),
                 Slovakia(codeValue: 421, shortCodeValue: "SK", labelValue: "Slovakia", flagURLString: "https://cdn.countryflags.com/thumbs/slovakia/flag-800.png"),
                 Slovenia(codeValue: 386, shortCodeValue: "SI", labelValue: "Slovenia", flagURLString: "https://cdn.countryflags.com/thumbs/slovenia/flag-800.png"),
                 SolomonIslands(codeValue: 677, shortCodeValue: "SB", labelValue: "Solomon Islands", flagURLString: "https://cdn.countryflags.com/thumbs/solomon-islands/flag-800.png"),
                 Somalia(codeValue: 252, shortCodeValue: "SO", labelValue: "Somalia", flagURLString: "https://cdn.countryflags.com/thumbs/somalia/flag-800.png"),
                 SouthAfrica(codeValue: 27, shortCodeValue: "ZA", labelValue: "South Africa", flagURLString: "https://cdn.countryflags.com/thumbs/south-africa/flag-800.png", nsnValue: 9),
                 SouthKorea(codeValue: 82, shortCodeValue: "KR", labelValue: "South Korea", flagURLString: "https://cdn.countryflags.com/thumbs/south-korea/flag-800.png"),
                 SouthSudan(codeValue: 211, shortCodeValue: "SS", labelValue: "South Sudan", flagURLString: "https://cdn.countryflags.com/thumbs/south-sudan/flag-800.png"),
                 Spain(codeValue: 34, shortCodeValue: "ES", labelValue: "Spain", flagURLString: "https://cdn.countryflags.com/thumbs/spain/flag-800.png", nsnValue: 9),
                 SriLanka(codeValue: 94, shortCodeValue: "LK", labelValue: "Sri Lanka", flagURLString: "https://cdn.countryflags.com/thumbs/sri-lanka/flag-800.png", nsnValue: 7),
                 SaintLucia(codeValue: 1, shortCodeValue: "LC", labelValue: "Saint Lucia", flagURLString: "https://cdn.countryflags.com/thumbs/saint-lucia/flag-800.png", nsnValue: 10),
                 Sudan(codeValue: 249, shortCodeValue: "SD", labelValue: "Sudan", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Flag_of_Sudan.svg/2880px-Flag_of_Sudan.svg.png"),
                 Suriname(codeValue: 597, shortCodeValue: "SR", labelValue: "Suriname", flagURLString: "https://cdn.countryflags.com/thumbs/suriname/flag-800.png"),
                 Swaziland(codeValue: 268, shortCodeValue: "SZ", labelValue: "Swaziland", flagURLString: "https://cdn.countryflags.com/thumbs/swaziland/flag-800.png"),
                 Sweden(codeValue: 46, shortCodeValue: "SE", labelValue: "Sweden", flagURLString: "https://cdn.countryflags.com/thumbs/sweden/flag-800.png", nsnValue: 10),
                 Switzerland(codeValue: 41, shortCodeValue: "CH", labelValue: "Switzerland", flagURLString: "https://cdn.countryflags.com/thumbs/switzerland/flag-800.png", nsnValue: 9),
                 Syria(codeValue: 963, shortCodeValue: "SY", labelValue: "Syria", flagURLString: "https://cdn.countryflags.com/thumbs/syria/flag-800.png"),
                 Taiwan(codeValue: 886, shortCodeValue: "TW", labelValue: "Taiwan", flagURLString: "https://cdn.countryflags.com/thumbs/taiwan/flag-800.png"),
                 Tajikistan(codeValue: 992, shortCodeValue: "TJ", labelValue: "Tajikistan", flagURLString: "https://cdn.countryflags.com/thumbs/tajikistan/flag-800.png"),
                 Tanzania(codeValue: 255, shortCodeValue: "TZ", labelValue: "Tanzania", flagURLString: "https://cdn.countryflags.com/thumbs/tanzania/flag-800.png"),
                 Thailand(codeValue: 66, shortCodeValue: "TH", labelValue: "Thailand", flagURLString: "https://cdn.countryflags.com/thumbs/thailand/flag-800.png", nsnValue: 9),
                 Bahamas(codeValue: 1, shortCodeValue: "BS", labelValue: "The Bahamas", flagURLString: "https://cdn.countryflags.com/thumbs/bahamas/flag-800.png", nsnValue: 10),
                 Gambia(codeValue: 220, shortCodeValue: "GM", labelValue: "The Gambia", flagURLString: "https://cdn.countryflags.com/thumbs/gambia/flag-800.png"),
                 TimorLeste(codeValue: 670, shortCodeValue: "TL", labelValue: "Timor-Leste", flagURLString: "https://cdn.countryflags.com/thumbs/east-timor/flag-800.png"),
                 Togo(codeValue: 228, shortCodeValue: "TG", labelValue: "Togo", flagURLString: "https://cdn.countryflags.com/thumbs/togo/flag-800.png"),
                 Tokelau(codeValue: 690, shortCodeValue: "TK", labelValue: "Tokelau", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Flag_of_Tokelau.svg/2880px-Flag_of_Tokelau.svg.png"),
                 Tonga(codeValue: 676, shortCodeValue: "TO", labelValue: "Tonga", flagURLString: "https://cdn.countryflags.com/thumbs/tonga/flag-800.png"),
                 TrinidadTobago(codeValue: 1, shortCodeValue: "TT", labelValue: "Trinidad and Tobago", flagURLString: "https://cdn.countryflags.com/thumbs/trinidad-and-tobago/flag-800.png", nsnValue: 10),
                 Tunisia(codeValue: 216, shortCodeValue: "TN", labelValue: "Tunisia", flagURLString: "https://cdn.countryflags.com/thumbs/tunisia/flag-800.png"),
                 Turkey(codeValue: 90, shortCodeValue: "TR", labelValue: "Turkey", flagURLString: "https://cdn.countryflags.com/thumbs/turkey/flag-800.png", nsnValue: 11),
                 Turkmenistan(codeValue: 993, shortCodeValue: "TM", labelValue: "Turkmenistan", flagURLString: "https://cdn.countryflags.com/thumbs/turkmenistan/flag-800.png"),
                 TurksCaicosIslands(codeValue: 1, shortCodeValue: "TC", labelValue: "Turks and Caicos Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Flag_of_the_Turks_and_Caicos_Islands.svg/2880px-Flag_of_the_Turks_and_Caicos_Islands.svg.png", nsnValue: 10),
                 Tuvalu(codeValue: 688, shortCodeValue: "TV", labelValue: "Tuvalu", flagURLString: "https://cdn.countryflags.com/thumbs/tuvalu/flag-800.png"),
                 Uganda(codeValue: 256, shortCodeValue: "UG", labelValue: "Uganda", flagURLString: "https://cdn.countryflags.com/thumbs/uganda/flag-800.png"),
                 UnitedArabEmirates(codeValue: 971, shortCodeValue: "AE", labelValue: "United Arab Emirates", flagURLString: "https://cdn.countryflags.com/thumbs/united-arab-emirates/flag-800.png"),
                 UnitedKingdom(codeValue: 44, shortCodeValue: "GB", labelValue: "United Kingdom", flagURLString: "https://cdn.countryflags.com/thumbs/united-kingdom/flag-800.png", nsnValue: 10),
                 Uruguay(codeValue: 598, shortCodeValue: "UY", labelValue: "Uruguay", flagURLString: "https://cdn.countryflags.com/thumbs/uruguay/flag-800.png"),
                 USVirginIslands(codeValue: 1, shortCodeValue: "VI", labelValue: "US Virgin Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Flag_of_the_United_States_Virgin_Islands.svg/2560px-Flag_of_the_United_States_Virgin_Islands.svg.png", nsnValue: 10),
                 Uzbekistan(codeValue: 998, shortCodeValue: "UZ", labelValue: "Uzbekistan", flagURLString: "https://cdn.countryflags.com/thumbs/uzbekistan/flag-800.png"),
                 Vanuatu(codeValue: 678, shortCodeValue: "VU", labelValue: "Vanuatu", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Flag_of_Vanuatu_%28official%29.svg/2560px-Flag_of_Vanuatu_%28official%29.svg.png"),
                 VaticanCity(codeValue: 39, shortCodeValue: "VA", labelValue: "Vatican City", flagURLString: "https://cdn.countryflags.com/thumbs/vatican-city/flag-800.png", nsnValue: 10),
                 Venezuela(codeValue: 58, shortCodeValue: "VE", labelValue: "Venezuela", flagURLString: "https://cdn.countryflags.com/thumbs/venezuela/flag-800.png", nsnValue: 7),
                 Vietnam(codeValue: 84, shortCodeValue: "VN", labelValue: "Vietnam", flagURLString: "https://cdn.countryflags.com/thumbs/vietnam/flag-800.png", nsnValue: 9),
                 WallisFutuna(codeValue: 681, shortCodeValue: "WF", labelValue: "Wallis and Futuna", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 WesternSahara(codeValue: 212, shortCodeValue: "EH", labelValue: "Western Sahara", flagURLString: "http://www.geognos.com/api/en/countries/flag/EH.png"),
                 Yemen(codeValue: 967, shortCodeValue: "YE", labelValue: "Yemen", flagURLString: "https://cdn.countryflags.com/thumbs/yemen/flag-800.png"),
                 Zambia(codeValue: 260, shortCodeValue: "ZM", labelValue: "Zambia", flagURLString: "https://cdn.countryflags.com/thumbs/zambia/flag-800.png"),
                 Zimbabwe(codeValue: 263, shortCodeValue: "ZW", labelValue: "Zimbabwe", flagURLString: "https://cdn.countryflags.com/thumbs/zimbabwe/flag-800.png"),
        ]
    }
}
