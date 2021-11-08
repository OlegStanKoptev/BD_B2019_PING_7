//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation

// MARK: - Person
class Person {
    public static let instance = Person()
    private init() { parseNames() }
    
    var firstNameMale: [String] = []
    var firstNameFemale: [String] = []
    var lastName: [String] = []
    let sex = Sex.allCases
    
    enum Sex: String, CaseIterable {
        case Male
        case Female
    }
}

// MARK: Person parser
extension Person {
    func parseNames() {
        let data = try! String(contentsOfFile: "Resources/names.json", encoding: .utf8).data(using: .utf8)!
        let decodedData = try! JSONDecoder().decode([String: [String]].self, from: data)
        firstNameMale = decodedData["maleFirstName"]!
        firstNameFemale = decodedData["femaleFirstName"]!
        lastName = decodedData["lastName"]!
    }
}

// MARK: Person generators
extension Person {
    public static var randomMaleFirstName: String {
        instance.firstNameMale.randomElement()!
    }
    
    public static var randomFemaleFirstName: String {
        instance.firstNameFemale.randomElement()!
    }
    
    public static var randomLastName: String {
        instance.lastName.randomElement()!
    }
    
    public static var randomSex: String {
        instance.sex.randomElement()!.rawValue
    }
    
    public static var randomFullName: String {
        randomFullName(sex: Sex(rawValue: randomSex)!)
    }
    
    public static func randomFullName(sex: Sex) -> String {
        switch sex {
        case .Female: return "\(randomFemaleFirstName) \(randomLastName)"
        case .Male: return "\(randomMaleFirstName) \(randomLastName)"
        }
    }
    
    public static func randomNames(amount: Int, sex: Sex = .Male) -> [String] {
        var result = Array<String>(repeating: "", count: amount)
        for i in 0..<amount {
            result[i] = randomFullName(sex: sex)
        }
        return result
    }
    
    public static func randomUniqueNames(amount: Int, sex: Sex = .Male) -> [String] {
        var result = Set<String>()
        while (result.count < amount) {
            result.insert(randomFullName(sex: sex))
        }
        return Array(result)
    }
}
