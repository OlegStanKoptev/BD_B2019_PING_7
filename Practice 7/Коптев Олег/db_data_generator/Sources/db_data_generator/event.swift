//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation

// MARK: - Event
class Event {
    struct EventObj: Codable {
        var name: String
        var type: String
        var isTeamEvent: Int
        var playersNumber: Int
        var resultNotedIn: String
        var resultMin: Double
        var resultMax: Double
    }
    
    public static let instance = Event()
    private init() { parseEvents() }
    var events: [EventObj] = []
}

// MARK: Event parser
extension Event {
    func parseEvents() {
        let data = try! String(contentsOfFile: "Resources/events.json", encoding: .utf8).data(using: .utf8)!
        events = try! JSONDecoder().decode([EventObj].self, from: data)
    }
}

// MARK: Event generators
extension Event {
    static var randomEvent: EventObj {
        instance.events.randomElement()!
    }
    
    static func randomEvents(amount: Int) -> [EventObj] {
        let limit = min(amount, instance.events.count)
        return instance.events.dropLast(instance.events.count - limit)
    }
}
