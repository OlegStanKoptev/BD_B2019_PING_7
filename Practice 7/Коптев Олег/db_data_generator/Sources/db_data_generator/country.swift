//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation

// MARK: - Country
class Country {
    struct CountryObj: Decodable, Hashable {
        var name: String
        var alpha: String
        var capital: String
        var population: Int
        var area: Int
    }
    
    public static let instance = Country()
    private init() { parseCountries() }
    var countries: [CountryObj] = []
}

// MARK: Country parser
extension Country {
    func parseCountries() {
        var fileContent = ""
        do {
            fileContent = try String(contentsOfFile: "Resources/countries.json", encoding: .utf8)
        } catch {
            fatalError("didn't detect 'countries.json' file")
        }
        let data = fileContent.data(using: .utf8)!
        countries = try! JSONDecoder().decode([CountryObj].self, from: data)
    }
}

// MARK: Country generators
extension Country {
    public static var randomCountry: CountryObj {
        instance.countries.randomElement()!
    }
    
    public static func randomCountries(amount: Int) -> [CountryObj] {
        let actualAmount = min(amount, instance.countries.count)
        var result = Set<CountryObj>()
        
        while (result.count < actualAmount) {
            result.insert(instance.countries.randomElement()!)
        }
        
        return Array(result)
    }
}
