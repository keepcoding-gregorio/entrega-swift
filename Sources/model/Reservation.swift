/// A struct representing a hotel reservation
public struct Reservation {

    public var id: Int
    public var hotelName: String
    public var clients: Array<Client>
    public var duration: Int
    public var price: Double
    public var breakfastIncluded: Bool
    
    /**
     Initializes a new instance of the hotel `Reservation

     - Parameters:
       - reservationId: The unique ID of the reservation
       - hotelName: The name of the hotel
       - clientsList: The list of clients associated with the reservation
       - durationInDays: The duration of the reservation in days
       - price: The price of the reservation
       - breakfastIncluded: A flag indicating whether breakfast is included in the reservation
     */
    public init(reservationId id: Int, hotelName name: String, clientsList clients: Array<Client>, durationInDays duration: Int, price: Double, breakfastIncluded: Bool) {
        self.id = id
        self.hotelName = name
        self.clients = clients
        self.duration = duration
        self.price = price
        self.breakfastIncluded = breakfastIncluded
    }
}
