import Foundation

// MARK: - Service Status

enum DeploymentStatus: String, Codable {
    case starting = "STARTING"
    case running = "RUNNING"
    case stopping = "STOPPING"
    case suspended = "SUSPENDED"
    case unknown = "UNKNOWN"
    case crashed = "CRASHED"
    case pullFailed = "PULL_FAILED"
    case pending = "PENDING"
    case building = "BUILDING"
}

// MARK: - Project Models

struct ZeaburProject: Codable, Identifiable {
    let _id: String
    let name: String
    let services: [ZeaburServiceItem]

    var id: String { _id }
}

struct ZeaburServiceItem: Codable, Identifiable {
    let _id: String
    let name: String
    let status: DeploymentStatus?

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
