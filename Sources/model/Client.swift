/// A struct representing a client.
public struct Client: Equatable {
    
    public var name: String
    public var age: Int
    public var height: Int
    
    /**
     Initializes a new instance of the `Client` struct with the specified values.
     
     - Parameters:
         - name: The name of the client.
         - age: The age of the client.
         - height: The height of the client in centimeters.
     */
    public init(name: String, age: Int, heightInCm height: Int) {
        self.name = name
        self.age = age
        self.height = height
    }
}

