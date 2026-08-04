//
//  SDUIScreenRepository.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

/// The screen-loading boundary consumed by presentation state.
nonisolated protocol SDUIScreenRepository: Sendable {
    func loadScreen() async -> SDUIScreenLoadOutcome
}

/// The result of obtaining and decoding one complete screen definition.
nonisolated enum SDUIScreenLoadOutcome: Equatable, Sendable {
    case content(SDUIScreenDefinition)
    case unsupportedSchema(major: Int)
    case invalidDocument(SDUIDocumentError)
    case sourceFailure(SDUIResourceLoadError)
}

/// A typed local-resource failure that is safe to present and test.
nonisolated enum SDUIResourceLoadError: Equatable, Sendable {
    case resourceNotFound(name: String)
    case unreadableResource(name: String)
}

/// Loads the bundled V1 fixture and maps it through the typed SDUI decoder.
///
/// The bundle itself is deliberately not retained. Resolving its URL during
/// construction keeps the non-UI repository value Sendable and testable.
nonisolated struct BundledSDUIScreenRepository: SDUIScreenRepository {
    private let documentURL: URL?
    private let resourceName: String
    private let decoder: SDUIDocumentDecoder

    init(
        bundle: Bundle = .main,
        resourceName: String = "home-v1",
        fileExtension: String = "json",
        decoder: SDUIDocumentDecoder = SDUIDocumentDecoder()
    ) {
        self.documentURL = bundle.url(forResource: resourceName, withExtension: fileExtension)
        self.resourceName = "\(resourceName).\(fileExtension)"
        self.decoder = decoder
    }

    init(
        documentURL: URL?,
        resourceName: String,
        decoder: SDUIDocumentDecoder = SDUIDocumentDecoder()
    ) {
        self.documentURL = documentURL
        self.resourceName = resourceName
        self.decoder = decoder
    }

    func loadScreen() async -> SDUIScreenLoadOutcome {
        guard let documentURL else {
            return .sourceFailure(.resourceNotFound(name: resourceName))
        }

        do {
            let data = try Data(contentsOf: documentURL)

            switch decoder.decode(data) {
            case .compatible(let definition):
                return .content(definition)
            case .unsupportedSchema(let major):
                return .unsupportedSchema(major: major)
            case .invalidDocument(let error):
                return .invalidDocument(error)
            }
        } catch {
            return .sourceFailure(.unreadableResource(name: resourceName))
        }
    }
}
