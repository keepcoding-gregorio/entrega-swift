import Foundation

/// Test class for `HotelReservationManager`. It has only one instance of the class to simulate a database where ids are incremented by the corresponding action and are independent of the order in which the tests run (tests of adding/cancelling reservations begin and end with adding new reservations in order to retreive the last id and total count to make tests dynamic)
class HotelReservationManagerTests {
    
    let manager = HotelReservationManager()
    
    /// Test case for adding reservations.
    func testAddReservation() {
        let initialReservationsCount: Int = getCurrentReservationsCount()
        let lastAddedId = manager.getReservations().last?.id
        
        let goku = Client(name: "Goku", age: 28, heightInCm: 175)
        let krillin = Client(name: "Krillin", age: 29, heightInCm: 155)
        let piccolo = Client(name: "Piccolo", age: 10, heightInCm: 190)
        let vegeta = Client(name: "Vegeta", age: 32, heightInCm: 180)
        
        // Test case: Adding reservations with different parameters success
        do {
            let reservation1 = try manager.addReservation(clientsList: [goku, krillin], durationInDays: 3, breakfastIncluded: true)
            assert(manager.getReservations().count == initialReservationsCount + 1, "Total reservations should be \(initialReservationsCount + 1)")
            assert(reservation1.id == (lastAddedId ?? 0) + 1, "Reservation id should be \((lastAddedId ?? 0) + 1)")
            
            let reservation2 = try manager.addReservation(clientsList: [piccolo], durationInDays: 1, breakfastIncluded: false)
            assert(manager.getReservations().count == initialReservationsCount + 2, "Total reservations should be \(initialReservationsCount + 2)")
            assert(reservation2.id == (lastAddedId ?? 0) + 2, "Reservation id should be \((lastAddedId ?? 0) + 2)")
        } catch {
            print(error.localizedDescription)
            
            assertionFailure("Reservations with correct information shouldn't throw errors")
        }
        
        // Test case: Trying to add a duplicate reservation with an existing client should throw an error
        do {
            try manager.addReservation(clientsList: [krillin], durationInDays: 5, breakfastIncluded: true)
            assertionFailure("Failed to throw duplicate client error")
        } catch {
            print(error.localizedDescription)
            
            assert(manager.getReservations().count == initialReservationsCount + 2, "The amount of reservations should still be \(initialReservationsCount + 2) because last one failed")
            let reservationError = error as? ReservationError
            assert(reservationError != nil, "The error thrown should be of type ReservationError")
            assert(reservationError == ReservationError.duplicateClient(clients: [krillin]), "The error does not match the .duplicateClient or the clients \([krillin])")
        }
        
        // Test case: Adding more reservations after a failed one should work and only increase the id by 1
        do {
            let reservation4 = try manager.addReservation(clientsList: [vegeta], durationInDays: 2, breakfastIncluded: false)
            assert(manager.getReservations().count == initialReservationsCount + 3, "Total reservations should be \(initialReservationsCount + 3)")
            assert(reservation4.id == (lastAddedId ?? 0) + 3, "Reservation matches id \((lastAddedId ?? 0) + 3) because last  reservation failed, so the id was not incremented")
            
        } catch {
            print(error.localizedDescription)
            
            assertionFailure("Reservations with correct information shouldn't throw errors")
        }
    }
    
    /// Test case for canceling reservations.
    func testCancelReservation() {
        var initialReservationsCount: Int = getCurrentReservationsCount()
        
        let bulma = Client(name: "Bulma", age: 30, heightInCm: 165)
        let mrPopo = Client(name: "Mr Popo", age: 40, heightInCm: 135)
        
        // Check if there is an existing reservation and add one in order to test a cancellation
        if initialReservationsCount == 0 {
            do {
                let reservation = try manager.addReservation(clientsList: [bulma], durationInDays: 5, breakfastIncluded: true)
                assertEquals(1, manager.getReservations().count)
                initialReservationsCount += 1
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let lastAddedId = manager.getReservations().last?.id
        
        // Test case: cancel last reservation success
        do {
            try manager.cancelReservation(id: lastAddedId!)
            assert(manager.getReservations().count == initialReservationsCount - 1, "After cancelling a reservation, total quantity of reservations should be \(initialReservationsCount - 1)")
        } catch {
            print(error.localizedDescription)
            
            assertionFailure("Existing reservation should be able to cancel")
        }
        
        // Test case: Id of a new reservation after a cancellation is different from last successful reservation success
        do {
            let newReservation = try manager.addReservation(clientsList: [mrPopo], durationInDays: 10, breakfastIncluded: false)
            assert(newReservation.id != lastAddedId!, "New reservation id should't match a cancelled reservation id")
            assert(manager.getReservations().count == initialReservationsCount, "After adding back a reservation, total reservations should match the initial quantity: \(initialReservationsCount)")
        } catch {
            print(error.localizedDescription)
            
            assertionFailure("Failed to add a new reservation after a cancellation")
        }
        
        // Test case: Cancel a non-existent reservation should throw an error
        let nonExistingReservationId = (lastAddedId ?? 0) + 100
        
        do {
            try manager.cancelReservation(id: nonExistingReservationId)
            assertionFailure("Cancelling a non existing reservation should throw an error")
        } catch {
            print(error.localizedDescription)
            
            let reservationError = error as? ReservationError
            assert(reservationError != nil, "The error thrown should be of type ReservationError")
            assert(reservationError == ReservationError.reservationNotFound(id: nonExistingReservationId), "The error does not match the .reservationNotFound or the id \(nonExistingReservationId)")
        }
    }
    
    /// Test case to compare reservation price calculation.
    func testReservationPrice() {
        
        let trunks = Client(name: "Trunks", age: 20, heightInCm: 172)
        let gohan = Client(name: "Gohan", age: 4, heightInCm: 155)
        let mrSatan = Client(name: "Mr Satan", age: 33, heightInCm: 185)
        let yamcha = Client(name: "Yamcha", age: 7, heightInCm: 153)
        let kami = Client(name: "Kami", age: 20, heightInCm: 163)
        
        do {
            let reservation = try manager.addReservation(clientsList: [trunks, gohan], durationInDays: 3, breakfastIncluded: true)
            let similarReservation = try manager.addReservation(clientsList: [yamcha, mrSatan], durationInDays: 3, breakfastIncluded: true)
            
            // Test case: similar reservations -> same price
            let expectedPrice: Double = 150.0
            assertEquals(expectedPrice, reservation.price)
            assertEquals(reservation.price, similarReservation.price)
            
            // Test case: different reservations -> different price
            let differentReservation = try manager.addReservation(clientsList: [kami], durationInDays: 16, breakfastIncluded: false)
            assert(differentReservation.price != similarReservation.price, "Price \(differentReservation.price) should be different from  \(similarReservation.price)")
            
        } catch {
            print(error.localizedDescription)
            
            assertionFailure("Price comparison failure")
        }
    }
    
    private func getCurrentReservationsCount() -> Int {
        let reservations: Array<Reservation> = manager.getReservations()
        let reservationsCount: Int = reservations.count
        print("Quantity of reservations: \(reservationsCount)")
        return reservationsCount
    }
    
    private func assertEquals<T: Equatable> (_ value1: T, _ value2: T) {
        if value1 != value2 {
            fatalError("\(value1) != \(value2)")
        }
    }
}

let hotelReservationManagerTests = HotelReservationManagerTests()
hotelReservationManagerTests.testAddReservation()
hotelReservationManagerTests.testCancelReservation()
hotelReservationManagerTests.testReservationPrice()

// Test other order configuration

//hotelReservationManagerTests.testCancelReservation()
//hotelReservationManagerTests.testReservationPrice()
//hotelReservationManagerTests.testAddReservation()

// Test other order configuration

//hotelReservationManagerTests.testReservationPrice()
//hotelReservationManagerTests.testCancelReservation()
//hotelReservationManagerTests.testAddReservation()
