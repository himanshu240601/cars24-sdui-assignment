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

    @Test("A loaded finance definition seeds the bounded interaction state")
    func seedsInteractionStateFromTheDeclaredFinanceSheet() async {
        let definition = makeInteractiveDefinition()
        let repository = ScriptedScreenRepository(outcomes: [.content(definition)])
        let store = SDUIScreenStore(repository: repository)

        await store.loadIfNeeded()

        #expect(store.interactionState == SDUIScreenInteractionState(
            selectedTenureOptionID: "48-months"
        ))
        #expect(store.state == .content(definition))
    }

    @Test("Known finance actions update only the bounded interaction state")
    func dispatchesKnownFinanceActions() async {
        let definition = makeInteractiveDefinition()
        let repository = ScriptedScreenRepository(outcomes: [.content(definition)])
        let store = SDUIScreenStore(repository: repository)

        await store.loadIfNeeded()

        store.dispatch(.presentSheet(sheetID: "finance-options"))
        #expect(store.interactionState.selectedTenureOptionID == "48-months")
        #expect(store.interactionState.activeSheetID == "finance-options")

        store.dispatch(.setSelection(selectionKey: .selectedTenure, optionID: "36-months"))
        #expect(store.interactionState.selectedTenureOptionID == "36-months")
        #expect(store.interactionState.activeSheetID == "finance-options")

        store.dispatch(.dismissSheet)
        #expect(store.interactionState.selectedTenureOptionID == "36-months")
        #expect(store.interactionState.activeSheetID == nil)
        #expect(store.state == .content(definition))
    }

    @Test("Unresolved and nonexecutable actions do not mutate interaction state")
    func ignoresUnresolvedAndNonexecutableActions() async {
        let definition = makeInteractiveDefinition()
        let repository = ScriptedScreenRepository(outcomes: [.content(definition)])
        let store = SDUIScreenStore(repository: repository)

        store.dispatch(.presentSheet(sheetID: "finance-options"))
        #expect(store.interactionState == SDUIScreenInteractionState())

        await store.loadIfNeeded()
        let initialInteractionState = store.interactionState

        store.dispatch(.presentSheet(sheetID: "missing-sheet"))
        store.dispatch(.setSelection(selectionKey: .selectedTenure, optionID: "missing-option"))
        store.dispatch(.unsupported(type: "futureAction"))
        store.dispatch(.unavailable(type: "presentSheet", reason: "Missing sheet ID."))

        #expect(store.interactionState == initialInteractionState)
    }

    private func makeDefinition() -> SDUIScreenDefinition {
        SDUIScreenDefinition(
            schemaVersion: 1,
            screenID: "test-screen",
            sections: [],
            presentations: []
        )
    }

    private func makeInteractiveDefinition() -> SDUIScreenDefinition {
        let financeSheet = SDUIComponentInstance(
            id: "finance-options",
            variant: nil,
            actions: [],
            content: SDUIFinanceSheetProps(
                title: "Choose your loan tenure",
                selectionKey: .selectedTenure,
                initialOptionID: "48-months",
                options: [
                    SDUIFinanceOption(
                        id: "36-months",
                        label: "36 months",
                        emiText: "EMI ₹20,598/month",
                        action: .setSelection(
                            selectionKey: .selectedTenure,
                            optionID: "36-months"
                        )
                    ),
                    SDUIFinanceOption(
                        id: "48-months",
                        label: "48 months",
                        emiText: "EMI ₹16,008/month",
                        action: .setSelection(
                            selectionKey: .selectedTenure,
                            optionID: "48-months"
                        )
                    )
                ]
            )
        )

        return SDUIScreenDefinition(
            schemaVersion: 1,
            screenID: "interactive-test-screen",
            sections: [
                .discoveryHeader(
                    SDUIComponentInstance(
                        id: "header",
                        variant: nil,
                        actions: [],
                        content: SDUIDiscoveryHeaderProps(
                            title: "Test screen",
                            subtitle: nil,
                            symbolName: nil
                        )
                    )
                )
            ],
            presentations: [.financeSheet(financeSheet)]
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
