//
//  SDUIAction.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

/// The only mutable selection supported by the V1 assignment screen.
nonisolated enum SDUISelectionKey: String, Decodable, Equatable, Sendable {
    case selectedTenure
}

/// A finite, client-controlled action vocabulary. The server supplies intent;
/// the app decides whether a declared intent has an in-scope implementation.
nonisolated enum SDUIAction: Decodable, Equatable, Sendable {
    case setSelection(selectionKey: SDUISelectionKey, optionID: String)
    case presentSheet(sheetID: String)
    case dismissSheet
    case unsupported(type: String)
    case unavailable(type: String, reason: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case selectionKey
        case optionID
        case sheetID
    }

    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = .unavailable(type: "<malformed>", reason: "Action must be a JSON object.")
            return
        }

        guard let type = Self.trimmed(try? container.decode(String.self, forKey: .type)) else {
            self = .unavailable(type: "<missing>", reason: "Action type is required.")
            return
        }

        switch type {
        case "setSelection":
            guard
                let rawSelectionKey = Self.trimmed(
                    try? container.decode(String.self, forKey: .selectionKey)
                ),
                let selectionKey = SDUISelectionKey(rawValue: rawSelectionKey),
                let optionID = Self.trimmed(try? container.decode(String.self, forKey: .optionID))
            else {
                self = .unavailable(
                    type: type,
                    reason: "setSelection requires a supported selectionKey and optionID."
                )
                return
            }

            self = .setSelection(selectionKey: selectionKey, optionID: optionID)

        case "presentSheet":
            guard let sheetID = Self.trimmed(try? container.decode(String.self, forKey: .sheetID)) else {
                self = .unavailable(type: type, reason: "presentSheet requires sheetID.")
                return
            }

            self = .presentSheet(sheetID: sheetID)

        case "dismissSheet":
            self = .dismissSheet

        default:
            self = .unsupported(type: type)
        }
    }

    var diagnostic: String? {
        switch self {
        case .unsupported(let type):
            "Unsupported action type: \(type)."
        case .unavailable(let type, let reason):
            "Unavailable \(type) action: \(reason)"
        default:
            nil
        }
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
