import Foundation

public enum ReservationError: LocalizedError, Equatable {
    
    case duplicateId(id: Int)
    case duplicateClient(clients: Array<Client>)
    case reservationNotFound(id: Int)
    
    public var errorDescription: String? {
        switch self {
        case .duplicateId(let id):
            return "ReservationError.duplicateId: Reservation with id \(id) already exists"
        case .duplicateClient(let clients):
            return "ReservationError.duplicateClient: There is already a reservation for a client you want to add from list: \(clients)"
        case .reservationNotFound(let id):
            return "ReservationError.reservationNotFound: Cannot cancel a reservation with id \(id) because it does not exist"
        }
    }
}
