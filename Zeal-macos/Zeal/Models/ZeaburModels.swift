import Foundation

struct ZeaburProject: Codable, Identifiable {
    let _id: String
    let name: String
    let services: [ZeaburServiceItem]
    
    var id: String { _id }
}

struct ZeaburServiceItem: Codable, Identifiable {
    let _id: String
    let name: String
    
    var id: String { _id }
}

struct ProjectsResponse: Codable {
    let data: ProjectsData
}

struct ProjectsData: Codable {
    let projects: ProjectConnection
}

struct ProjectConnection: Codable {
    let edges: [ProjectEdge]
}

struct ProjectEdge: Codable {
    let node: ZeaburProject
}
