//
//  File.swift
//  
//
//  Created by Oleg Koptev on 08.11.2021.
//

import Foundation
import PostgresKit

// MARK: - Database manipulations
class ConnectorAndGenerator {
    var hostname = "localhost"
    var username = "postgres"
    var password = "mysecretpassword"
    var database = "postgres"
    
    var countriesAmount = 8
    var olympisAmount = 4
    var eventsAmount = 16
    var playersAmount = 64
    var resultsAmount = 192
    
    func recreateTables(of db: SQLDatabase) {
        let tablesDrop = ["results", "players", "events", "olympics", "countries"]
        let tablesInit = [
            "create table countries (name char(40), country_id char(3) unique, area_sqkm integer, population integer)",
            "create table olympics (olympic_id char(7) unique, country_id char(3), city char(50), year integer, startdate date, enddate date, foreign key (country_id) references Countries(country_id))",
            "create table players (name char(40), player_id char(10) unique, country_id char(3), birthdate date, foreign key (country_id) references Countries(country_id))",
            "create table events (event_id char(7) unique, name char(40), eventtype char(20), olympic_id char(7), is_team_event integer check (is_team_event in (0, 1)), num_players_in_team integer, result_noted_in char(100), foreign key (olympic_id) references Olympics(olympic_id))",
            "create table results (event_id char(7), player_id char(10), medal char(7), result float, foreign key (event_id) references Events(event_id), foreign key (player_id) references players(player_id))",
        ]
        
        for tableName in tablesDrop {
            try? db.drop(table: tableName).run().wait()
        }
        
        for tableInit in tablesInit {
            try! db.raw(.init(tableInit)).run().wait()
        }
    }

    func fillCountries(_ db: SQLDatabase, amount: Int = 156) {
        var countries = Country.randomCountries(amount: amount)
        countries.sort(by: { $0.name < $1.name })
        for country in countries {
            try! db.insert(into: "countries")
                .columns([
                    "name",
                    "country_id",
                    "area_sqkm",
                    "population",
                ])
                .values([
                    country.name,
                    country.alpha,
                    country.area,
                    country.population,
                ]).run().wait()
        }
    }

    func fillOlympics(_ db: SQLDatabase, amount: Int) {
        let countries = try! db.select()
            .columns("name")
            .from("countries")
            .all().wait()
            .map { try! $0.decode(column: "name", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines) }
        var olympics = Olympic.randomOlympics(amount: amount, countries: countries)
        olympics.sort(by: { $0.year < $1.year })
        for olympic in olympics {
            try! db.insert(into: "olympics")
                .columns([
                    "olympic_id",
                    "country_id",
                    "city",
                    "year",
                    "startdate",
                    "enddate"
                ])
                .values([
                    olympic.olympicId,
                    olympic.countryId,
                    olympic.city,
                    olympic.year,
                    olympic.startDate,
                    olympic.endDate
                ]).run().wait()
        }
    }

    func fillEvents(_ db: SQLDatabase, amount: Int = 100) {
        let olympics = try! db.select()
            .columns("olympic_id")
            .from("olympics")
            .all().wait()
            .map { try! $0.decode(column: "olympic_id", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines) }
        let events = Event.randomEvents(amount: amount)
        
        var counter = 1
        for event in events {
            for olympic in olympics {
                let eventId = "E\(counter)"
                try! db.insert(into: "events")
                    .columns([
                        "event_id",
                        "name",
                        "eventtype",
                        "olympic_id",
                        "is_team_event",
                        "num_players_in_team",
                        "result_noted_in",
                    ])
                    .values([
                        eventId,
                        event.name,
                        event.type,
                        olympic,
                        event.isTeamEvent,
                        event.playersNumber,
                        event.resultNotedIn
                    ]).run().wait()
                
                counter += 1
            }
        }
    }

    func fillPlayers(_ db: SQLDatabase, amount: Int = 64) {
        let countries = try! db.select()
            .columns("country_id")
            .from("countries")
            .all().wait()
            .map { try! $0.decode(column: "country_id", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let names = Person.randomUniqueNames(amount: amount)
        
        for name in names {
            let nameComponents = name.split(separator: " ")
            var lastNameAlpha = nameComponents[1].uppercased()
            while lastNameAlpha.count > 5 { _ = lastNameAlpha.popLast() }
            var firstNameAlpha = nameComponents[0].uppercased()
            while firstNameAlpha.count > 3 { _ = firstNameAlpha.popLast() }
            let playerId = "\(lastNameAlpha)\(firstNameAlpha)01"
            try! db.insert(into: "players")
                .columns([
                    "name",
                    "player_id",
                    "country_id",
                    "birthdate",
                ])
                .values([
                    name,
                    playerId,
                    countries.randomElement()!,
                    Date.randomBetween(start: "01-01-1000", end: "01-01-2020")
                ]).run().wait()
        }
        
    }

    func fillResults(_ db: SQLDatabase, amount: Int) {
        let players = try! db.select()
            .columns("player_id")
            .from("players")
            .all().wait()
            .map {
                try! $0.decode(column: "player_id", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        
        let events = try! db.select()
            .columns(["event_id", "name"])
            .from("events")
            .all().wait()
            .map {
                (try! $0.decode(column: "event_id", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines),
                 try! $0.decode(column: "name", as: String.self).trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        
        var counter = 1
        for event in events {
            if (counter == amount) { break }
            
            let eventId = event.0
            let eventName = event.1
            
            let results = Result.randomPrizeResults(eventName: eventName)
            
            for result in results {
                var tempPlayers = players
                let chosenPlayer = tempPlayers.randomElement()!
                tempPlayers.removeAll(where: { $0 == chosenPlayer })
                try! db.insert(into: "results")
                    .columns([
                        "event_id",
                        "player_id",
                        "medal",
                        "result",
                    ])
                    .values([
                        eventId,
                        chosenPlayer,
                        result.medal,
                        result.result
                    ]).run().wait()
                counter += 1
            }
        }
    }

    func fillDatabase(_ db: SQLDatabase) {
        recreateTables(of: db)
        fillCountries(db, amount: countriesAmount)
        fillOlympics(db, amount: olympisAmount)
        fillEvents(db, amount: eventsAmount)
        fillPlayers(db, amount: playersAmount)
        fillResults(db, amount: resultsAmount)
    }

    func connectToDbAndDoStuff() {
        let configuration = PostgresConfiguration(
            hostname: hostname,
            username: username,
            password: password,
            database: database
        )
        
        let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try! eventLoopGroup.syncShutdownGracefully() }

        let pools = EventLoopGroupConnectionPool(
            source: PostgresConnectionSource(configuration: configuration),
            on: eventLoopGroup
        )
        defer { pools.shutdown() }
        let logger = Logger(label: "DEF")
        let eventLoop: EventLoop = eventLoopGroup.next()
        let pool = pools.pool(for: eventLoop)
        let db = pool.database(logger: logger)

        fillDatabase(db.sql())
    }
}
