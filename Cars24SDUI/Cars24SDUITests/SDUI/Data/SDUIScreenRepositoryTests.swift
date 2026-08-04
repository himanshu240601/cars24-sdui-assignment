//
//  SDUIScreenRepositoryTests.swift
//  Cars24SDUITests
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation
import Testing
@testable import Cars24SDUI

struct SDUIScreenRepositoryTests {
    @Test("The production repository loads the canonical bundled screen definition")
    func loadsBundledScreenDefinition() async {
        let outcome = await BundledSDUIScreenRepository().loadScreen()

        guard case .content(let definition) = outcome else {
            Issue.record("The canonical bundled fixture should produce compatible content.")
            return
        }

        #expect(definition.screenID == "cars24-home")
        #expect(definition.sections.count == 7)
    }

    @Test("A missing bundled resource stays distinct from a payload failure")
    func mapsMissingResource() async {
        let repository = BundledSDUIScreenRepository(
            documentURL: nil,
            resourceName: "missing.json"
        )
        let outcome = await repository.loadScreen()

        #expect(outcome == .sourceFailure(.resourceNotFound(name: "missing.json")))
    }

    @Test("An unsupported payload major remains a compatibility outcome")
    func mapsUnsupportedSchema() async throws {
        let url = try temporaryPayload(
            """
            {
              "schemaVersion": 2,
              "screenID": "future-screen",
              "sections": []
            }
            """
        )
        defer { removeTemporaryPayload(at: url) }

        let outcome = await repository(for: url).loadScreen()

        #expect(outcome == .unsupportedSchema(major: 2))
    }

    @Test("A malformed payload remains a retryable invalid-document outcome")
    func mapsInvalidDocument() async throws {
        let url = try temporaryPayload("{\"schemaVersion\":")
        defer { removeTemporaryPayload(at: url) }

        let outcome = await repository(for: url).loadScreen()

        #expect(outcome == .invalidDocument(.malformedPayload))
    }

    private func repository(for url: URL) -> BundledSDUIScreenRepository {
        BundledSDUIScreenRepository(documentURL: url, resourceName: "test.json")
    }

    private func temporaryPayload(_ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try Data(contents.utf8).write(to: url)
        return url
    }

    private func removeTemporaryPayload(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
