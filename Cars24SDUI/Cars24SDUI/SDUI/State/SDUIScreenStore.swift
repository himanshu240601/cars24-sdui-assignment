//
//  SDUIScreenStore.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Observation

/// The renderer-facing state for obtaining a screen definition.
nonisolated enum SDUIScreenLoadState: Equatable, Sendable {
    case idle
    case loading
    case content(SDUIScreenDefinition)
    case unsupportedSchema(major: Int)
    case invalidDocument(SDUIDocumentError)
    case sourceFailure(SDUIResourceLoadError)

    fileprivate init(outcome: SDUIScreenLoadOutcome) {
        switch outcome {
        case .content(let definition):
            self = .content(definition)
        case .unsupportedSchema(let major):
            self = .unsupportedSchema(major: major)
        case .invalidDocument(let error):
            self = .invalidDocument(error)
        case .sourceFailure(let error):
            self = .sourceFailure(error)
        }
    }

    fileprivate var canRetry: Bool {
        switch self {
        case .invalidDocument, .sourceFailure:
            true
        case .idle, .loading, .content, .unsupportedSchema:
            false
        }
    }
}

/// Owns one screen-load lifecycle. It never interprets actions or mutates the
/// immutable decoded screen definition.
@MainActor
@Observable
final class SDUIScreenStore {
    private let repository: any SDUIScreenRepository

    private(set) var state: SDUIScreenLoadState = .idle

    init(repository: any SDUIScreenRepository) {
        self.repository = repository
    }

    /// Starts the initial load once. Calls made after any terminal state are ignored.
    func loadIfNeeded() async {
        guard case .idle = state else {
            return
        }

        await load()
    }

    /// Re-attempts a user-recoverable load failure. No automatic retry is used.
    func retry() async {
        guard state.canRetry else {
            return
        }

        await load()
    }

    private func load() async {
        state = .loading
        let outcome = await repository.loadScreen()

        guard !Task.isCancelled else {
            state = .idle
            return
        }

        state = SDUIScreenLoadState(outcome: outcome)
    }
}
