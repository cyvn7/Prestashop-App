struct AddressModel: Identifiable, Equatable, Hashable {
    var id: Int
    var alias: String
    var name: String
    var phoneNumber: String
    var address: String
    var city: String
    var postcode: String
}

let testAddress : AddressModel = AddressModel(id: 0, alias: "test_alias", name: "test_name", phoneNumber: "123456789", address: "test_address", city: "test_city", postcode: "12-345")
