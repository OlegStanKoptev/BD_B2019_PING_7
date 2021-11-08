//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation

// MARK: - Olympic
class Olympic {
    public static let instance = Olympic()
    private init() {}
    
    struct OlympicObj {
        //  olympic_id,country_id, city,     year, startdate,                           enddate
        // 'SYD2000',  'AUS',      'Sydney', 2000, to_date('15-09-2000', 'dd-mm-yyyy'), to_date('01-10-2000', 'dd-mm-yyyy')
        var olympicId: String
        var countryId: String
        var city: String
        var year: Int
        var startDate: Date
        var endDate: Date
    }
}

// MARK: Olympic generators
extension Olympic {
    private static func date(day: Int, month: Int, year: Int) -> String {
        "\(String(format: "%02d-%02d-%d", day, month, year))"
    }
    
    public static var randomOlympic: OlympicObj {
        let country = Country.randomCountry
        let city = country.capital
        let year = (1980..<2021).randomElement()!
        let day = (1..<30).randomElement()!
        let month = (5..<10).randomElement()!
        let obj = OlympicObj(
            olympicId: "\(city[city.startIndex..<city.index(city.startIndex, offsetBy: 3)].uppercased())\(year)",
            countryId: country.alpha,
            city: city,
            year: year,
            startDate: Date.parse(date(day: day, month: month, year: year)),
            endDate: Date.parse(date(day: day + (0..<5).randomElement()!, month: month + (0..<2).randomElement()!, year: year)))
        return obj
    }
    
    public static func randomOlympics(amount: Int, countries: [String]) -> [OlympicObj] {
        var result = [OlympicObj]()
        var existingCountries = Country.instance.countries.filter { countries.contains($0.name) }
        let leftYearLimit = 1000
        let rightYearLimit = 2020
        let actualAmount = min((rightYearLimit - leftYearLimit) / 4, amount)
        let rightYear = (1940/4...2020/4).randomElement()!*4
        for i in (0..<actualAmount) {
            if (existingCountries.count < 1) { break }
            let countryIndex = (0..<existingCountries.count).randomElement()!
            let country = existingCountries[countryIndex]
            existingCountries.remove(at: countryIndex)
            let city = country.capital
            let year = rightYear - i * 4
            let cleanCity = city.components(separatedBy: .alphanumerics.inverted).joined(separator: "")
            let olympicId = String(cleanCity.uppercased().dropLast(cleanCity.count - 3)) + String(year)
            let day = (1..<30).randomElement()!
            let month = (3..<10).randomElement()!
            
            let startDateStr = date(day: day, month: month, year: year)
            let endDateStr = Date.parseDate(start: startDateStr, plusDays: (14..<30).randomElement()!)
            
            let obj = OlympicObj(
                olympicId: olympicId,
                countryId: country.alpha,
                city: city,
                year: year,
                startDate: Date.parse(startDateStr),
                endDate: Date.parse(endDateStr)
            )
            
            result.append(obj)
        }
        
        return result
    }
}
