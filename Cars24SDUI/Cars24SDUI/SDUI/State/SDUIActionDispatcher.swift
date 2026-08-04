//
//  SDUIActionDispatcher.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

/// The complete mutable interaction state supported by the V1 assignment
/// screen. The decoded screen definition remains immutable.
nonisolated struct SDUIScreenInteractionState: Equatable, Sendable {
    fileprivate(set) var selectedTenureOptionID: String?
    fileprivate(set) var activeSheetID: String?

    init(
        selectedTenureOptionID: String? = nil,
        activeSheetID: String? = nil
    ) {
        self.selectedTenureOptionID = selectedTenureOptionID
        self.activeSheetID = activeSheetID
    }
}

/// Resolves the finite V1 action vocabulary against a validated, immutable
/// screen definition. It is deliberately a small reducer rather than a
/// generic command or event system.
nonisolated enum SDUIActionDispatcher {
    static func initialState(for definition: SDUIScreenDefinition) -> SDUIScreenInteractionState {
        guard let sheet = financeSheet(for: .selectedTenure, in: definition) else {
            return SDUIScreenInteractionState()
        }

        return SDUIScreenInteractionState(
            selectedTenureOptionID: sheet.content.initialOptionID
        )
    }

    static func apply(
        _ action: SDUIAction,
        to state: inout SDUIScreenInteractionState,
        in definition: SDUIScreenDefinition
    ) {
        switch action {
        case .presentSheet(let sheetID):
            guard let sheet = financeSheet(withID: sheetID, in: definition) else {
                return
            }

            if sheet.content.options.contains(where: { $0.id == state.selectedTenureOptionID }) == false {
                state.selectedTenureOptionID = sheet.content.initialOptionID
            }
            state.activeSheetID = sheet.id

        case .setSelection(let selectionKey, let optionID):
            guard
                let sheet = financeSheet(for: selectionKey, in: definition),
                sheet.content.options.contains(where: { $0.id == optionID })
            else {
                return
            }

            state.selectedTenureOptionID = optionID

        case .dismissSheet:
            state.activeSheetID = nil

        case .unsupported, .unavailable:
            return
        }
    }

    private static func financeSheet(
        withID sheetID: String,
        in definition: SDUIScreenDefinition
    ) -> SDUIComponentInstance<SDUIFinanceSheetProps>? {
        for presentation in definition.presentations {
            guard case .financeSheet(let sheet) = presentation else {
                continue
            }

            if sheet.id == sheetID {
                return sheet
            }
        }

        return nil
    }

    private static func financeSheet(
        for selectionKey: SDUISelectionKey,
        in definition: SDUIScreenDefinition
    ) -> SDUIComponentInstance<SDUIFinanceSheetProps>? {
        for presentation in definition.presentations {
            guard case .financeSheet(let sheet) = presentation else {
                continue
            }

            if sheet.content.selectionKey == selectionKey {
                return sheet
            }
        }

        return nil
    }
}
