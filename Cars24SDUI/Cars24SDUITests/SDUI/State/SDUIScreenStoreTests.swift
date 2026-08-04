//
//  SDUIScreenStoreTests.swift
//  Cars24SDUITests
//
//  Created for the CARS24 SDUI assignment.
//

import Testing
@testable import Cars24SDUI

@MainActor
struct SDUIScreenStoreTests {
    @Test("The store exposes loading before a repository result arrives")
    func exposesLoadingAndIgnoresDuplicateInitialLoads() async {
        let repository = GatedScreenRepository()
        let store = SDUIScreenStore(repository: repository)
        let definition = makeDefinition()

        #expect(store.state == .idle)

        let loadTask = Task { @MainActor in
            await store.loadIfNeeded()
        }

        await repository.waitUntilLoadStarts()
        #expect(store.state == .loading)

        await store.loadIfNeeded()
        let initialLoadCount = await repository.loadCount()
        #expect(initialLoadCount == 1)

        await repository.finish(with: .content(definition))
        await loadTask.value

        #expect(store.state == .content(definition))
    }

    @Test("A successful initial load is not repeated")
    func doesNotReloadAfterContent() async {
        let definition = makeDefinition()
        let repository = ScriptedScreenRepository(outcomes: [.content(definition)])
        let store = SDUIScreenStore(repository: repository)

        await store.loadIfNeeded()
        await store.loadIfNeeded()

        #expect(store.state == .content(definition))
        let loadCount = await repository.loadCount()
        #expect(loadCount == 1)
    }

    @Test("A recoverable failure can retry and reach content")
    func retriesRecoverableFailure() async {
        let definition = makeDefinition()
        let repository = ScriptedScreenRepository(outcomes: [
            .sourceFailure(.resourceNotFound(name: "home-v1.json")),
            .content(definition)
        ])
        let store = SDUIScreenStore(repository: repository)

        await store.loadIfNeeded()
        #expect(store.state == .sourceFailure(.resourceNotFound(name: "home-v1.json")))

        await store.retry()

        #expect(store.state == .content(definition))
        let loadCount = await repository.loadCount()
        #expect(loadCount == 2)
    }

    @Test("Compatibility and invalid-document outcomes remain distinct")
    func preservesTerminalFailureKinds() async {
        let unsupportedRepository = ScriptedScreenRepository(
            outcomes: [.unsupportedSchema(major: 2)]
        )
        let unsupportedStore = SDUIScreenStore(repository: unsupportedRepository)

        await unsupportedStore.loadIfNeeded()
        #expect(unsupportedStore.state == .unsupportedSchema(major: 2))

        let invalidRepository = ScriptedScreenRepository(
            outcomes: [.invalidDocument(.duplicateComponentID("duplicate"))]
        )
        let invalidStore = SDUIScreenStore(repository: invalidRepository)

        await invalidStore.loadIfNeeded()
        #expect(invalidStore.state == .invalidDocument(.duplicateComponentID("duplicate")))
    }

    private func makeDefinition() -> SDUIScreenDefinition {
        SDUIScreenDefinition(
            schemaVersion: 1,
            screenID: "test-screen",
            sections: [],
            presentations: []
        )
    }
}

private actor ScriptedScreenRepository: SDUIScreenRepository {
    private var outcomes: [SDUIScreenLoadOutcome]
    private var numberOfLoads = 0

    init(outcomes: [SDUIScreenLoadOutcome]) {
        self.outcomes = outcomes
    }

    func loadScreen() async -> SDUIScreenLoadOutcome {
        numberOfLoads += 1

        guard !outcomes.isEmpty else {
            return .sourceFailure(.resourceNotFound(name: "unexpected-load.json"))
        }

        return outcomes.removeFirst()
    }

    func loadCount() -> Int {
        numberOfLoads
    }
}

private actor GatedScreenRepository: SDUIScreenRepository {
    private var resultContinuation: CheckedContinuation<SDUIScreenLoadOutcome, Never>?
    private var startContinuations: [CheckedContinuation<Void, Never>] = []
    private var numberOfLoads = 0

    func loadScreen() async -> SDUIScreenLoadOutcome {
        numberOfLoads += 1
        let continuations = startContinuations
        startContinuations.removeAll()
        continuations.forEach { $0.resume() }

        return await withCheckedContinuation { continuation in
            resultContinuation = continuation
        }
    }

    func waitUntilLoadStarts() async {
        guard numberOfLoads == 0 else {
            return
        }

        await withCheckedContinuation { continuation in
            startContinuations.append(continuation)
        }
    }

    func finish(with outcome: SDUIScreenLoadOutcome) {
        let continuation = resultContinuation
        resultContinuation = nil
        continuation?.resume(returning: outcome)
    }

    func loadCount() -> Int {
        numberOfLoads
    }
}
