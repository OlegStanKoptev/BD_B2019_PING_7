import ArgumentParser

struct db_data_generator: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to generate data for olympics postgres database")
    
    @Option(name: .long, help: "Database Hostname")
    var dbhostname: String = "localhost"
    
    @Option(name: .long, help: "Database Username")
    var dbusername: String = "postgres"
    
    @Option(name: .long, help: "Database Password")
    var dbpassword: String = "mysecretpassword"
    
    @Option(name: .long, help: "Database Name")
    var dbname: String = "postgres"
    
    @Option(name: .long, help: "Countries Quantity")
    var countriesQty: Int = 8
    
    @Option(name: .long, help: "Olympics Quantity")
    var olympicsQty: Int = 4
    
    @Option(name: .long, help: "Events Quantity")
    var eventsQty: Int = 16
    
    @Option(name: .long, help: "Players Quantity")
    var playersQty: Int = 64
    
    @Option(name: .long, help: "Results Quantity")
    var resultsQty: Int = 192

    func run() throws {
        let manipulator = ConnectorAndGenerator()
        
        manipulator.hostname = dbhostname
        manipulator.username = dbusername
        manipulator.password = dbpassword
        manipulator.database = dbname
        
        manipulator.countriesAmount = countriesQty
        manipulator.olympisAmount = olympicsQty
        manipulator.eventsAmount = eventsQty
        manipulator.playersAmount = playersQty
        manipulator.resultsAmount = resultsQty
            
        manipulator.connectToDbAndDoStuff()
    }

    init() {}
}

db_data_generator.main()
