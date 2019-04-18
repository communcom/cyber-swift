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
    class Chad: County {}
    class Chile: County {}
    class China: County {}
    class Colombia: County {}
    class Comoros: County {}
    class CookIslands: County {}
    class CostaRica: County {}
    class CoteDivoire: County {}
    class Croatia: County {}
    class Cuba: County {}
    class Curacao: County {}
    class Cyprus: County {}
    class CzechRepublic: County {}
    class DemocraticRepublicCongo: County {}
    class Denmark: County {}
    class Djibouti: County {}
    class Dominica: County {}
    class DominicanRepublic: County {}
    class Ecuador: County {}
    class Egypt: County {}
    class ElSalvador: County {}
    class EquatorialGuinea: County {}
    class Eritrea: County {}
    class Estonia: County {}
    class Ethiopia: County {}
    class FalklandIslands: County {}
    class FaroeIslands: County {}
    class FederatedStatesMicronesia: County {}
    class Fiji: County {}
    class Finland: County {}
    class France: County {}
    class FrenchGuiana: County {}
    class FrenchPolynesia: County {}
    class Gabon: County {}
    class Georgia: County {}
    class Germany: County {}
    class Ghana: County {}
    class Gibraltar: County {}
    class Greece: County {}
    class Greenland: County {}
    class Grenada: County {}
    class Guadeloupe: County {}
    class Guam: County {}
    class Guatemala: County {}
    class Guernsey: County {}
    class Guinea: County {}
    class GuineaBissau: County {}
    class Guyana: County {}
    class Haiti: County {}
    class Honduras: County {}
    class HongKong: County {}
    class Hungary: County {}
    class Iceland: County {}
    class India: County {}
    class Indonesia: County {}
    class Iran: County {}
    class Iraq: County {}
    class Ireland: County {}
    class IsleMan: County {}
    class Israel: County {}
    class Italy: County {}
    class Jamaica: County {}
    class Japan: County {}
    class Jersey: County {}
    class Jordan: County {}
    class Kenya: County {}
    class Kiribati: County {}
    class Kosovo: County {}
    class Kuwait: County {}
    class Kyrgyzstan: County {}
    class Laos: County {}
    class Latvia: County {}
    class Lebanon: County {}
    class Lesotho: County {}
    class Liberia: County {}
    class Libya: County {}
    class Liechtenstein: County {}
    class Luxembourg: County {}
    class Macau: County {}
    class Macedonia: County {}
    class Madagascar: County {}
    class Malawi: County {}
    class Malaysia: County {}
    class Maldives: County {}
    class Mali: County {}
    class Malta: County {}
    class MarshallIslands: County {}
    class Martinique: County {}
    class Mauritania: County {}
    class Mauritius: County {}
    class Mayotte: County {}
    class Mexico: County {}
    class Moldova: County {}
    class Monaco: County {}
    class Mongolia: County {}
    class Montenegro: County {}
    class Montserrat: County {}
    class Morocco: County {}
    class Mozambique: County {}
    class Myanmar: County {}
    class Namibia: County {}
    class Nauru: County {}
    class Netherlands: County {}
    class NewCaledonia: County {}

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
                 Chad(codeValue: 235, shortCodeValue: "TD", labelValue: "Chad", flagURLString: "https://cdn.countryflags.com/thumbs/chad/flag-800.png"),
                 Chile(codeValue: 56, shortCodeValue: "CL", labelValue: "Chile", flagURLString: "https://cdn.countryflags.com/thumbs/chile/flag-800.png"),
                 China(codeValue: 86, shortCodeValue: "CN", labelValue: "China", flagURLString: "https://cdn.countryflags.com/thumbs/china/flag-800.png"),
                 Colombia(codeValue: 57, shortCodeValue: "CO", labelValue: "Colombia", flagURLString: "https://cdn.countryflags.com/thumbs/colombia/flag-800.png"),
                 Comoros(codeValue: 269, shortCodeValue: "KM", labelValue: "Comoros", flagURLString: "https://cdn.countryflags.com/thumbs/comoros/flag-800.png"),
                 CookIslands(codeValue: 682, shortCodeValue: "CK", labelValue: "Cook Islands", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Flag_of_the_Cook_Islands.svg/2880px-Flag_of_the_Cook_Islands.svg.png"),
                 CostaRica(codeValue: 506, shortCodeValue: "CR", labelValue: "Costa Rica", flagURLString: "https://cdn.countryflags.com/thumbs/costa-rica/flag-800.png"),
                 CoteDivoire(codeValue: 225, shortCodeValue: "CI", labelValue: "Côte d'Ivoire", flagURLString: "https://cdn.countryflags.com/thumbs/cote-d-ivoire/flag-800.png"),
                 Croatia(codeValue: 385, shortCodeValue: "HR", labelValue: "Croatia", flagURLString: "https://cdn.countryflags.com/thumbs/croatia/flag-800.png"),
                 Cuba(codeValue: 53, shortCodeValue: "CU", labelValue: "Cuba", flagURLString: "https://cdn.countryflags.com/thumbs/cuba/flag-800.png"),
                 Curacao(codeValue: 599, shortCodeValue: "CW", labelValue: "Curaçao", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Flag_of_Curaçao.svg/2560px-Flag_of_Curaçao.svg.png"),
                 Cyprus(codeValue: 357, shortCodeValue: "CY", labelValue: "Cyprus", flagURLString: "https://cdn.countryflags.com/thumbs/cyprus/flag-800.png"),
                 CzechRepublic(codeValue: 420, shortCodeValue: "CZ", labelValue: "Czech Republic", flagURLString: "https://cdn.countryflags.com/thumbs/czech-republic/flag-800.png"),
                 DemocraticRepublicCongo(codeValue: 243, shortCodeValue: "CD", labelValue: "Democratic Republic of the Congo", flagURLString: "https://cdn.countryflags.com/thumbs/congo-democratic-republic-of-the/flag-800.png"),
                 Denmark(codeValue: 45, shortCodeValue: "DK", labelValue: "Denmark", flagURLString: "https://cdn.countryflags.com/thumbs/denmark/flag-800.png"),
                 Djibouti(codeValue: 253, shortCodeValue: "DJ", labelValue: "Djibouti", flagURLString: "https://cdn.countryflags.com/thumbs/djibouti/flag-800.png"),
                 Dominica(codeValue: 1, shortCodeValue: "DM", labelValue: "Dominica", flagURLString: "https://cdn.countryflags.com/thumbs/dominica/flag-800.png"),
                 DominicanRepublic(codeValue: 1, shortCodeValue: "DO", labelValue: "Dominican Republic", flagURLString: "https://cdn.countryflags.com/thumbs/dominican-republic/flag-800.png"),
                 Ecuador(codeValue: 593, shortCodeValue: "EC", labelValue: "Ecuador", flagURLString: "https://cdn.countryflags.com/thumbs/ecuador/flag-800.png"),
                 Egypt(codeValue: 20, shortCodeValue: "EG", labelValue: "Egypt", flagURLString: "https://cdn.countryflags.com/thumbs/egypt/flag-800.png"),
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
                 France(codeValue: 33, shortCodeValue: "FR", labelValue: "France", flagURLString: "https://cdn.countryflags.com/thumbs/france/flag-800.png"),
                 FrenchGuiana(codeValue: 594, shortCodeValue: "GF", labelValue: "French Guiana", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 FrenchPolynesia(codeValue: 689, shortCodeValue: "PF", labelValue: "French Polynesia", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Flag_of_French_Polynesia.svg/2560px-Flag_of_French_Polynesia.svg.png"),
                 Gabon(codeValue: 241, shortCodeValue: "GA", labelValue: "Gabon", flagURLString: "https://cdn.countryflags.com/thumbs/gabon/flag-800.png"),
                 Georgia(codeValue: 995, shortCodeValue: "GE", labelValue: "Georgia", flagURLString: "https://cdn.countryflags.com/thumbs/georgia/flag-800.png"),
                 Germany(codeValue: 49, shortCodeValue: "DE", labelValue: "Germany", flagURLString: "https://cdn.countryflags.com/thumbs/germany/flag-800.png"),
                 Ghana(codeValue: 233, shortCodeValue: "GH", labelValue: "Ghana", flagURLString: "https://cdn.countryflags.com/thumbs/ghana/flag-800.png"),
                 Gibraltar(codeValue: 350, shortCodeValue: "GI", labelValue: "Gibraltar", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Flag_of_Gibraltar.svg/2880px-Flag_of_Gibraltar.svg.png"),
                 Greece(codeValue: 30, shortCodeValue: "GR", labelValue: "Greece", flagURLString: "https://cdn.countryflags.com/thumbs/greece/flag-800.png"),
                 Greenland(codeValue: 299, shortCodeValue: "GL", labelValue: "Greenland", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_Greenland.svg/2560px-Flag_of_Greenland.svg.png"),
                 Grenada(codeValue: 1, shortCodeValue: "GD", labelValue: "Grenada", flagURLString: "https://cdn.countryflags.com/thumbs/grenada/flag-800.png"),
                 Guadeloupe(codeValue: 590, shortCodeValue: "GP", labelValue: "Guadeloupe", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
                 Guam(codeValue: 1, shortCodeValue: "GU", labelValue: "Guam", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Flag_of_Guam.svg/2560px-Flag_of_Guam.svg.png"),
                 Guatemala(codeValue: 502, shortCodeValue: "GT", labelValue: "Guatemala", flagURLString: "https://cdn.countryflags.com/thumbs/guatemala/flag-800.png"),
                 Guernsey(codeValue: 44, shortCodeValue: "GG", labelValue: "Guernsey", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_Guernsey.svg/2560px-Flag_of_Guernsey.svg.png"),
                 Guinea(codeValue: 224, shortCodeValue: "GN", labelValue: "Guinea", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Flag_of_Guinea.svg/2560px-Flag_of_Guinea.svg.png"),
                 GuineaBissau(codeValue: 245, shortCodeValue: "GW", labelValue: "Guinea-Bissau", flagURLString: "https://cdn.countryflags.com/thumbs/guinea-bissau/flag-800.png"),
                 Guyana(codeValue: 592, shortCodeValue: "GY", labelValue: "Guyana", flagURLString: "https://cdn.countryflags.com/thumbs/guyana/flag-800.png"),
                 Haiti(codeValue: 509, shortCodeValue: "HT", labelValue: "Haiti", flagURLString: "https://cdn.countryflags.com/thumbs/haiti/flag-800.png"),
                 Honduras(codeValue: 504, shortCodeValue: "HN", labelValue: "Honduras", flagURLString: "https://cdn.countryflags.com/thumbs/honduras/flag-800.png"),
                 HongKong(codeValue: 852, shortCodeValue: "HK", labelValue: "Hong Kong", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Flag_of_Hong_Kong.svg/2560px-Flag_of_Hong_Kong.svg.png"),
                 Hungary(codeValue: 36, shortCodeValue: "HU", labelValue: "Hungary", flagURLString: "https://cdn.countryflags.com/thumbs/hungary/flag-800.png"),
                 Iceland(codeValue: 354, shortCodeValue: "IS", labelValue: "Iceland", flagURLString: "https://cdn.countryflags.com/thumbs/iceland/flag-800.png"),
                 India(codeValue: 91, shortCodeValue: "IN", labelValue: "India", flagURLString: "https://cdn.countryflags.com/thumbs/india/flag-800.png"),
                 Indonesia(codeValue: 62, shortCodeValue: "ID", labelValue: "Indonesia", flagURLString: "https://cdn.countryflags.com/thumbs/indonesia/flag-800.png"),
                 Iran(codeValue: 98, shortCodeValue: "IR", labelValue: "Iran", flagURLString: "https://cdn.countryflags.com/thumbs/iran/flag-800.png"),
                 Iraq(codeValue: 964, shortCodeValue: "IQ", labelValue: "Iraq", flagURLString: "https://cdn.countryflags.com/thumbs/iraq/flag-800.png"),
                 Ireland(codeValue: 353, shortCodeValue: "IE", labelValue: "Ireland", flagURLString: "https://cdn.countryflags.com/thumbs/ireland/flag-800.png"),
                 IsleMan(codeValue: 44, shortCodeValue: "IM", labelValue: "Isle Of Man", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Flag_of_the_Isle_of_Mann.svg/2880px-Flag_of_the_Isle_of_Mann.svg.png"),
                 Israel(codeValue: 972, shortCodeValue: "IL", labelValue: "Israel", flagURLString: "https://cdn.countryflags.com/thumbs/israel/flag-800.png"),
                 Italy(codeValue: 39, shortCodeValue: "IT", labelValue: "Italy", flagURLString: "https://cdn.countryflags.com/thumbs/italy/flag-800.png"),
                 Jamaica(codeValue: 1, shortCodeValue: "JM", labelValue: "Jamaica", flagURLString: "https://cdn.countryflags.com/thumbs/jamaica/flag-800.png"),
                 Japan(codeValue: 81, shortCodeValue: "JP", labelValue: "Japan", flagURLString: "https://cdn.countryflags.com/thumbs/japan/flag-800.png"),
                 Jersey(codeValue: 44, shortCodeValue: "JE", labelValue: "Jersey", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Flag_of_Jersey.svg/2560px-Flag_of_Jersey.svg.png"),
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
                 Mexico(codeValue: 52, shortCodeValue: "MX", labelValue: "Mexico", flagURLString: "https://cdn.countryflags.com/thumbs/mexico/flag-800.png"),
                 Moldova(codeValue: 373, shortCodeValue: "MD", labelValue: "Moldova", flagURLString: "https://cdn.countryflags.com/thumbs/moldova/flag-800.png"),
                 Monaco(codeValue: 377, shortCodeValue: "MC", labelValue: "Monaco", flagURLString: "https://cdn.countryflags.com/thumbs/monaco/flag-800.png"),
                 Mongolia(codeValue: 976, shortCodeValue: "MN", labelValue: "Mongolia", flagURLString: "https://cdn.countryflags.com/thumbs/mongolia/flag-800.png"),
                 Montenegro(codeValue: 382, shortCodeValue: "ME", labelValue: "Montenegro", flagURLString: "https://cdn.countryflags.com/thumbs/montenegro/flag-800.png"),
                 Montserrat(codeValue: 1, shortCodeValue: "MS", labelValue: "Montserrat", flagURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Flag_of_Montserrat.svg/2880px-Flag_of_Montserrat.svg.png"),
                 Morocco(codeValue: 212, shortCodeValue: "MA", labelValue: "Morocco", flagURLString: "https://cdn.countryflags.com/thumbs/morocco/flag-800.png"),
                 Mozambique(codeValue: 258, shortCodeValue: "MZ", labelValue: "Mozambique", flagURLString: "https://cdn.countryflags.com/thumbs/mozambique/flag-800.png"),
                 Myanmar(codeValue: 95, shortCodeValue: "MM", labelValue: "Myanmar", flagURLString: "https://cdn.countryflags.com/thumbs/myanmar/flag-800.png"),
                 Namibia(codeValue: 264, shortCodeValue: "NA", labelValue: "Namibia", flagURLString: "https://cdn.countryflags.com/thumbs/namibia/flag-800.png"),
                 Nauru(codeValue: 674, shortCodeValue: "NR", labelValue: "Nauru", flagURLString: "https://cdn.countryflags.com/thumbs/nauru/flag-800.png"),
                 Netherlands(codeValue: 31, shortCodeValue: "NL", labelValue: "Netherlands", flagURLString: "https://cdn.countryflags.com/thumbs/netherlands/flag-800.png"),
                 NewCaledonia(codeValue: 687, shortCodeValue: "NC", labelValue: "New Caledonia", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),

                 
                 
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
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NZ",
     "countryName": "New Zealand",
     "countryPhoneCode": 64,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NZ.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NI",
     "countryName": "Nicaragua",
     "countryPhoneCode": 505,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NI.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NE",
     "countryName": "Niger",
     "countryPhoneCode": 227,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NG",
     "countryName": "Nigeria",
     "countryPhoneCode": 234,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NU",
     "countryName": "Niue",
     "countryPhoneCode": 683,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NU.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NF",
     "countryName": "Norfolk Island",
     "countryPhoneCode": 672,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NF.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "KP",
     "countryName": "North Korea",
     "countryPhoneCode": 850,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/KP.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "MP",
     "countryName": "Northern Mariana Islands",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/MP.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "NO",
     "countryName": "Norway",
     "countryPhoneCode": 47,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/NO.png"
     },

     
     
     
     
     
     
     
     class Oman: County {}

     Oman(codeValue: 968, shortCodeValue: "OM", labelValue: "Oman", flagURLString: "https://cdn.countryflags.com/thumbs/oman/flag-800.png"),

     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PK",
     "countryName": "Pakistan",
     "countryPhoneCode": 92,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PK.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PW",
     "countryName": "Palau",
     "countryPhoneCode": 680,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PW.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PS",
     "countryName": "Palestine",
     "countryPhoneCode": 970,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PS.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PA",
     "countryName": "Panama",
     "countryPhoneCode": 507,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PA.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PG",
     "countryName": "Papua New Guinea",
     "countryPhoneCode": 675,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PY",
     "countryName": "Paraguay",
     "countryPhoneCode": 595,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PY.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PE",
     "countryName": "Peru",
     "countryPhoneCode": 51,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PH",
     "countryName": "Philippines",
     "countryPhoneCode": 63,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PH.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PL",
     "countryName": "Poland",
     "countryPhoneCode": 48,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PL.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PT",
     "countryName": "Portugal",
     "countryPhoneCode": 351,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PT.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PR",
     "countryName": "Puerto Rico",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PR.png"
     },

     
     
     
     
     
     
     class Qatar: County {}

     Qatar(codeValue: 974, shortCodeValue: "QA", labelValue: "Qatar", flagURLString: "https://cdn.countryflags.com/thumbs/qatar/flag-800.png"),

     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "CG",
     "countryName": "Republic of the Congo",
     "countryPhoneCode": 242,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/CG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "RE",
     "countryName": "Réunion",
     "countryPhoneCode": 262,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/RE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "RO",
     "countryName": "Romania",
     "countryPhoneCode": 40,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/RO.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "RW",
     "countryName": "Rwanda",
     "countryPhoneCode": 250,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/RW.png"
     },

     
     
     
     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "BL",
     "countryName": "Saint Barthélemy",
     "countryPhoneCode": 590,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/BL.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SH",
     "countryName": "Saint Helena",
     "countryPhoneCode": 290,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SH.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "KN",
     "countryName": "Saint Kitts and Nevis",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/KN.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "MF",
     "countryName": "Saint Martin",
     "countryPhoneCode": 590,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/MF.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "PM",
     "countryName": "Saint Pierre and Miquelon",
     "countryPhoneCode": 508,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/PM.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VC",
     "countryName": "Saint Vincent and the Grenadines",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VC.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "WS",
     "countryName": "Samoa",
     "countryPhoneCode": 685,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/WS.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SM",
     "countryName": "San Marino",
     "countryPhoneCode": 378,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SM.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "ST",
     "countryName": "Sao Tome and Principe",
     "countryPhoneCode": 239,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/ST.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SA",
     "countryName": "Saudi Arabia",
     "countryPhoneCode": 966,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SA.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SN",
     "countryName": "Senegal",
     "countryPhoneCode": 221,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SN.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "RS",
     "countryName": "Serbia",
     "countryPhoneCode": 381,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/RS.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SC",
     "countryName": "Seychelles",
     "countryPhoneCode": 248,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SC.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SL",
     "countryName": "Sierra Leone",
     "countryPhoneCode": 232,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SL.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SG",
     "countryName": "Singapore",
     "countryPhoneCode": 65,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SX",
     "countryName": "Sint Maarten",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SX.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SK",
     "countryName": "Slovakia",
     "countryPhoneCode": 421,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SK.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SI",
     "countryName": "Slovenia",
     "countryPhoneCode": 386,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SI.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SB",
     "countryName": "Solomon Islands",
     "countryPhoneCode": 677,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SB.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SO",
     "countryName": "Somalia",
     "countryPhoneCode": 252,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SO.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "ZA",
     "countryName": "South Africa",
     "countryPhoneCode": 27,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/ZA.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "KR",
     "countryName": "South Korea",
     "countryPhoneCode": 82,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/KR.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SS",
     "countryName": "South Sudan",
     "countryPhoneCode": 211,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SS.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "ES",
     "countryName": "Spain",
     "countryPhoneCode": 34,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/ES.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "LK",
     "countryName": "Sri Lanka",
     "countryPhoneCode": 94,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/LK.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "LC",
     "countryName": "St. Lucia",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/LC.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SD",
     "countryName": "Sudan",
     "countryPhoneCode": 249,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SD.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SR",
     "countryName": "Suriname",
     "countryPhoneCode": 597,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SR.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SZ",
     "countryName": "Swaziland",
     "countryPhoneCode": 268,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SZ.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SE",
     "countryName": "Sweden",
     "countryPhoneCode": 46,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "CH",
     "countryName": "Switzerland",
     "countryPhoneCode": 41,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/CH.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "SY",
     "countryName": "Syria",
     "countryPhoneCode": 963,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/SY.png"
     },

     
     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TW",
     "countryName": "Taiwan",
     "countryPhoneCode": 886,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TW.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TJ",
     "countryName": "Tajikistan",
     "countryPhoneCode": 992,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TJ.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TZ",
     "countryName": "Tanzania",
     "countryPhoneCode": 255,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TZ.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TH",
     "countryName": "Thailand",
     "countryPhoneCode": 66,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TH.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "BS",
     "countryName": "The Bahamas",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/BS.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "GM",
     "countryName": "The Gambia",
     "countryPhoneCode": 220,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/GM.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TL",
     "countryName": "Timor-Leste",
     "countryPhoneCode": 670,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TL.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TG",
     "countryName": "Togo",
     "countryPhoneCode": 228,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TK",
     "countryName": "Tokelau",
     "countryPhoneCode": 690,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TK.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TO",
     "countryName": "Tonga",
     "countryPhoneCode": 676,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TO.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TT",
     "countryName": "Trinidad and Tobago",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TT.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TN",
     "countryName": "Tunisia",
     "countryPhoneCode": 216,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TN.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TR",
     "countryName": "Turkey",
     "countryPhoneCode": 90,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TR.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TM",
     "countryName": "Turkmenistan",
     "countryPhoneCode": 993,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TM.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TC",
     "countryName": "Turks and Caicos Islands",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TC.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "TV",
     "countryName": "Tuvalu",
     "countryPhoneCode": 688,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/TV.png"
     },

     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "UG",
     "countryName": "Uganda",
     "countryPhoneCode": 256,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/UG.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "AE",
     "countryName": "United Arab Emirates",
     "countryPhoneCode": 971,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/AE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "GB",
     "countryName": "United Kingdom",
     "countryPhoneCode": 44,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/GB.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "UY",
     "countryName": "Uruguay",
     "countryPhoneCode": 598,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/UY.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VI",
     "countryName": "US Virgin Islands",
     "countryPhoneCode": 1,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VI.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "UZ",
     "countryName": "Uzbekistan",
     "countryPhoneCode": 998,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/UZ.png"
     },

     
     
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VU",
     "countryName": "Vanuatu",
     "countryPhoneCode": 678,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VU.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VA",
     "countryName": "Vatican City",
     "countryPhoneCode": 39,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VA.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VE",
     "countryName": "Venezuela",
     "countryPhoneCode": 58,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VE.png"
     },
     {
     class : County {}
     (codeValue: , shortCodeValue: "", labelValue: "", flagURLString: ""),
     
     "countryCode": "VN",
     "countryName": "Vietnam",
     "countryPhoneCode": 84,
     "thumbNailUrl": "http://www.geognos.com/api/en/countries/flag/VN.png"
     },

     

     class WallisFutuna: County {}
     class WesternSahara: County {}
     class Yemen: County {}
     class Zambia: County {}
     class Zimbabwe: County {}
     
     WallisFutuna(codeValue: 681, shortCodeValue: "WF", labelValue: "Wallis and Futuna", flagURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png"),
     WesternSahara(codeValue: 212, shortCodeValue: "EH", labelValue: "Western Sahara", flagURLString: "http://www.geognos.com/api/en/countries/flag/EH.png "),
     Yemen(codeValue: 967, shortCodeValue: "YE", labelValue: "Yemen", flagURLString: "https://cdn.countryflags.com/thumbs/yemen/flag-800.png"),
     Zambia(codeValue: 260, shortCodeValue: "ZM", labelValue: "Zambia", flagURLString: "https://cdn.countryflags.com/thumbs/zambia/flag-800.png"),
     Zimbabwe(codeValue: 263, shortCodeValue: "ZW", labelValue: "Zimbabwe", flagURLString: "https://cdn.countryflags.com/thumbs/zimbabwe/flag-800.png"),
     
     */
    
}
