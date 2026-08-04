//
//  SDUIWireDocument.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

/// The tolerant, non-renderable representation of an SDUI payload.
///
/// `props` intentionally remains raw at this boundary so a new component type
/// can degrade locally instead of invalidating the complete document.
nonisolated struct SDUIWireDocument: Decodable, Sendable {
    let schemaVersion: Int
    let screenID: String
    let sections: [SDUIRawComponent]
    let presentations: [SDUIRawComponent]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case screenID
        case sections
        case presentations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        screenID = try container.decode(String.self, forKey: .screenID)
        sections = try container.decode([SDUIRawComponent].self, forKey: .sections)
        presentations = try container.decodeIfPresent([SDUIRawComponent].self, forKey: .presentations) ?? []
    }
}

/// Common fields retained before a component is matched to a native type.
nonisolated struct SDUIRawComponent: Decodable, Sendable {
    let id: String
    let type: String
    let variant: String?
    let props: JSONValue?
    let actions: [SDUIAction]

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case variant
        case props
        case actions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        variant = try container.decodeIfPresent(String.self, forKey: .variant)
        props = try container.decodeIfPresent(JSONValue.self, forKey: .props)
        if container.contains(.actions) {
            if (try? container.decodeNil(forKey: .actions)) == true {
                actions = []
            } else if let decodedActions = try? container.decode([SDUIAction].self, forKey: .actions) {
                actions = decodedActions
            } else {
                actions = [
                    .unavailable(
                        type: "<malformed>",
                        reason: "Actions must be a JSON array."
                    )
                ]
            }
        } else {
            actions = []
        }
    }
}
