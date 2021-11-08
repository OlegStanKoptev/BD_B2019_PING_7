//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation

// MARK: - Result
class Result {
    struct ResultObj {
        var medal: String
        var result: Double
    }
    
    public static let instance = Result()
    private init() {}
    var events: [ResultObj] = []
    
    private let medals = ["GOLD", "SILVER", "BRONZE"]
}

// MARK: Result generators
extension Result {
    
    static var randomResult: ResultObj {
        randomResult(event: Event.randomEvent)
    }
    
    private static func randomResultValue(event: Event.EventObj) -> Double {
        round(Double.random(in: event.resultMin...event.resultMax) * 100) / 100
    }
    
    static func randomResult(event: Event.EventObj) -> ResultObj {
        ResultObj(
            medal: instance.medals.randomElement()!,
            result: randomResultValue(event: event)
        )
    }
    
    static func randomPrizeResults(eventName: String) -> [ResultObj] {
        let event = Event.instance.events.first(where: { $0.name == eventName })!
        
        var results = [ResultObj]()
        var values = [Double]()
        for _ in 0..<3 {
            values.append(randomResultValue(event: event))
        }
        values.sort()
        values.reverse()
        
        let playersNumber = max(1, event.playersNumber)
        
        for i in 0..<3 {
            for _ in 0..<playersNumber {
                results.append(ResultObj(medal: instance.medals[i], result: values[i]))
            }
        }
        
        return results
    }
}
