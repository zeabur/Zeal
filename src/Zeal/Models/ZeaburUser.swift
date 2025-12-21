import Foundation

struct ZeaburUser: Codable {
    let _id: String
    let username: String
    let name: String
}

struct MeResponse: Codable {
    let data: MeData
}

struct MeData: Codable {
    let me: ZeaburUser
}
