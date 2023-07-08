/// Class to manage hotel reservations
public class HotelReservationManager {
    
    /// Counter for generating reservation IDs.
    static private var idCounter: Int = 0

    private var reservations: Array<Reservation>
    private var hotelName: String
    private var pricePerClient: Double
    
    /// Initializes a new instance of the `HotelReservationManager` class with default values.
    public init() {
        self.reservations = []
        self.hotelName = "Hotel Luchadores"
        self.pricePerClient = 20.0
    }
    
    /// Initializes a new instance of the `HotelReservationManager` class with specified values.
    ///
    /// - Parameters:
    ///   - hotelName: The name of the hotel.
    ///   - pricePerClient: The price per client.
    public init(hotelName: String, pricePerClient: Double) {
        self.reservations = []
        self.hotelName = hotelName
        self.pricePerClient = pricePerClient
    }
    
    /// Gets the list of reservations.
    ///
    /// - Returns: An array of `Reservation` objects representing the reservations.
    public func getReservations() -> Array<Reservation> {
        return self.reservations
    }
    
    /// Adds a new reservation to the hotel.
    ///
    /// - Parameters:
    ///   - clientsList: The list of clients for the reservation.
    ///   - durationInDays: The duration of the reservation in days.
    ///   - breakfastIncluded: A flag indicating whether breakfast is included in the reservation.
    /// - Returns: The created `Reservation` object.
    /// - Throws: A `ReservationError` if the reservation cannot be added becaouse of duplicated id or client.
    public func addReservation(clientsList clients: Array<Client>, durationInDays duration: Int, breakfastIncluded: Bool) throws -> Reservation {
        let id = HotelReservationManager.idCounter + 1

        guard !getReservationIds().contains(id) else {
            throw ReservationError.duplicateId(id: id)
        }
        
        guard !getClients().contains(where: { clients.contains($0) }) else {
            throw ReservationError.duplicateClient(clients: clients)
        }
        
        let reservation = Reservation(
            reservationId: id,
            hotelName: self.hotelName,
            clientsList: clients,
            durationInDays: duration,
            price: calculatePrice(totalClients: clients.count, days: duration, breakfastIncluded: breakfastIncluded),
            breakfastIncluded: breakfastIncluded
        )

        self.reservations.append(reservation)
        HotelReservationManager.idCounter += 1
        print("Added reservation with id \(id)")
        return reservation
    }
    
    /// Cancels a reservation.
    ///
    /// - Parameters:
    ///   - id: The ID of the reservation to cancel.
    /// - Throws: A `ReservationError` if the reservation cannot be canceled.
    public func cancelReservation(id: Int) throws {
        guard let reservationIndex = self.reservations.firstIndex(where: { $0.id == id }) else {
            throw ReservationError.reservationNotFound(id: id)
        }
        
        self.reservations.remove(at: reservationIndex)
        print("Cancelled reservation with id \(id)")
    }
    
    /// Gets the list of reservation IDs.
    ///
    /// - Returns: An array of integers representing the reservation IDs.
    private func getReservationIds() -> Array<Int> {
        return self.reservations.map({ $0.id })
    }
    
    /// Gets the list of clients with a reservation.
    ///
    /// - Returns: An array of `Client` objects representing the clients.
    private func getClients() -> Array<Client> {
        return self.reservations.flatMap({ $0.clients })
    }
    
    /// Calculates the price for a reservation.
    ///
    /// - Parameters:
    ///   - totalClients: The total number of clients.
    ///   - days: The duration of the reservation in days.
    ///   - breakfastIncluded: A flag indicating whether breakfast is included in the reservation.
    /// - Returns: The calculated price for the reservation.
    private func calculatePrice(totalClients quantity: Int, days duration: Int, breakfastIncluded extraIncluded: Bool) -> Double {
        let coeficient: Double = extraIncluded ? 1.25 : 1
        return Double(quantity) * self.pricePerClient * Double(duration) * coeficient
    }
    
}
