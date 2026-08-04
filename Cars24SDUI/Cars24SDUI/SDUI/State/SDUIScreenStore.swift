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

/// Owns one screen-load lifecycle and its finite interaction state. It applies
/// resolved actions but never mutates the immutable decoded screen definition.
@MainActor
@Observable
final class SDUIScreenStore {
    private let repository: any SDUIScreenRepository

    private(set) var state: SDUIScreenLoadState = .idle
    private(set) var interactionState = SDUIScreenInteractionState()

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

    /// Applies a known V1 action only while a validated definition is loaded.
    /// Unsupported, unavailable, or unresolved targets are safe no-ops.
    func dispatch(_ action: SDUIAction) {
        guard case .content(let definition) = state else {
            return
        }

        SDUIActionDispatcher.apply(
            action,
            to: &interactionState,
            in: definition
        )
    }

    private func load() async {
        state = .loading
        interactionState = SDUIScreenInteractionState()
        let outcome = await repository.loadScreen()

        guard !Task.isCancelled else {
            state = .idle
            return
        }

        let loadedState = SDUIScreenLoadState(outcome: outcome)
        state = loadedState

        if case .content(let definition) = loadedState {
            interactionState = SDUIActionDispatcher.initialState(for: definition)
        }
    }
}
