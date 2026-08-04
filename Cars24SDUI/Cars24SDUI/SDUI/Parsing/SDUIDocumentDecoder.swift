//
//  SDUIDocumentDecoder.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

/// The non-UI result consumed by the future repository and screen state.
nonisolated enum SDUIDocumentParseOutcome: Equatable, Sendable {
    case compatible(SDUIScreenDefinition)
    case unsupportedSchema(major: Int)
    case invalidDocument(SDUIDocumentError)
}

nonisolated enum SDUIDocumentError: Equatable, Sendable {
    case malformedPayload
    case blankScreenID
    case emptySections
    case blankComponentID
    case blankComponentType(id: String)
    case duplicateComponentID(String)
}

/// Decodes and validates an SDUI payload without creating UI state or views.
nonisolated struct SDUIDocumentDecoder: Sendable {
    private let registry: SDUIComponentRegistry
    private let semanticValidator: SDUIDocumentSemanticValidator

    init(
        registry: SDUIComponentRegistry = SDUIComponentRegistry(),
        semanticValidator: SDUIDocumentSemanticValidator = SDUIDocumentSemanticValidator()
    ) {
        self.registry = registry
        self.semanticValidator = semanticValidator
    }

    func decode(_ data: Data) -> SDUIDocumentParseOutcome {
        do {
            let wireDocument = try JSONDecoder().decode(SDUIWireDocument.self, from: data)
            return decode(wireDocument)
        } catch {
            return .invalidDocument(.malformedPayload)
        }
    }

    func decode(_ wireDocument: SDUIWireDocument) -> SDUIDocumentParseOutcome {
        guard wireDocument.schemaVersion == 1 else {
            return .unsupportedSchema(major: wireDocument.schemaVersion)
        }

        guard !wireDocument.screenID.isBlank else {
            return .invalidDocument(.blankScreenID)
        }

        guard !wireDocument.sections.isEmpty else {
            return .invalidDocument(.emptySections)
        }

        let allComponents = wireDocument.sections + wireDocument.presentations
        var componentIDs = Set<String>()

        for component in allComponents {
            guard !component.id.isBlank else {
                return .invalidDocument(.blankComponentID)
            }

            guard !component.type.isBlank else {
                return .invalidDocument(.blankComponentType(id: component.id))
            }

            guard componentIDs.insert(component.id).inserted else {
                return .invalidDocument(.duplicateComponentID(component.id))
            }
        }

        let definition = SDUIScreenDefinition(
            schemaVersion: wireDocument.schemaVersion,
            screenID: wireDocument.screenID,
            sections: wireDocument.sections.map(registry.makeSection),
            presentations: wireDocument.presentations.map(registry.makePresentation)
        )

        return .compatible(semanticValidator.validate(definition))
    }
}

nonisolated struct SDUIDocumentSemanticValidator: Sendable {
    func validate(_ definition: SDUIScreenDefinition) -> SDUIScreenDefinition {
        let presentations = validateSelectionDeclarations(in: definition.presentations)
        let financeContext = financeContext(from: presentations)

        return SDUIScreenDefinition(
            schemaVersion: definition.schemaVersion,
            screenID: definition.screenID,
            sections: definition.sections.map { section in
                guard let reason = invalidReference(
                    in: section.declaredActions,
                    using: financeContext
                ) else {
                    return section
                }

                return section.invalidating(reason)
            },
            presentations: presentations.map { presentation in
                guard let reason = invalidReference(
                    in: presentation.declaredActions,
                    using: financeContext
                ) else {
                    return presentation
                }

                return presentation.invalidating(reason)
            }
        )
    }

    private func validateSelectionDeclarations(
        in presentations: [SDUIPresentation]
    ) -> [SDUIPresentation] {
        var declaredKeys = Set<SDUISelectionKey>()

        return presentations.map { presentation in
            guard case .financeSheet(let sheet) = presentation else {
                return presentation
            }

            guard declaredKeys.insert(sheet.content.selectionKey).inserted else {
                return presentation.invalidating(
                    "A selection key may be declared by only one finance sheet."
                )
            }

            return presentation
        }
    }

    private func financeContext(
        from presentations: [SDUIPresentation]
    ) -> SDUIFinanceReferenceContext {
        var sheetIDs = Set<String>()
        var optionIDsBySelection = [SDUISelectionKey: Set<String>]()

        for presentation in presentations {
            guard case .financeSheet(let sheet) = presentation else {
                continue
            }

            sheetIDs.insert(sheet.id)
            optionIDsBySelection[sheet.content.selectionKey] = Set(sheet.content.options.map(\.id))
        }

        return SDUIFinanceReferenceContext(
            sheetIDs: sheetIDs,
            optionIDsBySelection: optionIDsBySelection
        )
    }

    private func invalidReference(
        in actions: [SDUIAction],
        using context: SDUIFinanceReferenceContext
    ) -> String? {
        for action in actions {
            switch action {
            case .presentSheet(let sheetID):
                guard context.sheetIDs.contains(sheetID) else {
                    return "presentSheet must target a declared finance sheet."
                }
            case .setSelection(let selectionKey, let optionID):
                guard context.optionIDsBySelection[selectionKey]?.contains(optionID) == true else {
                    return "setSelection must target a declared option."
                }
            case .dismissSheet, .unsupported, .unavailable:
                continue
            }
        }

        return nil
    }
}

nonisolated struct SDUIFinanceReferenceContext: Sendable {
    let sheetIDs: Set<String>
    let optionIDsBySelection: [SDUISelectionKey: Set<String>]
}

private extension String {
    nonisolated var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
