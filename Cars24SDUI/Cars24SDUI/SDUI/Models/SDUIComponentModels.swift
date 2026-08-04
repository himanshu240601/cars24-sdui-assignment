//
//  SDUIComponentModels.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

nonisolated enum SDUISectionType: String, Equatable, Sendable {
    case discoveryHeader
    case illustratedActionRail
    case productRail
    case serviceGrid
    case vehicleRail
    case highlightedServiceGrid
    case promoBanner
}

nonisolated enum SDUIPresentationType: String, Equatable, Sendable {
    case financeSheet
}

/// A deliberately small visual vocabulary. Raw colours, typography, and layout
/// values are not accepted from the payload.
nonisolated enum SDUIVisualVariant: String, Equatable, Sendable {
    case standard
    case featured
    case branded
}

nonisolated enum SDUIAccent: String, Decodable, Equatable, Sendable {
    case indigo
    case emerald
}

nonisolated enum SDUINodePlacement: String, Equatable, Sendable {
    case section
    case presentation
}

/// Common, validated component fields paired with strongly typed content.
nonisolated struct SDUIComponentInstance<Content: Equatable & Sendable>: Equatable, Sendable {
    let id: String
    let variant: SDUIVisualVariant?
    let actions: [SDUIAction]
    let content: Content
}

nonisolated struct SDUIScreenDefinition: Equatable, Sendable {
    let schemaVersion: Int
    let screenID: String
    let sections: [SDUISection]
    let presentations: [SDUIPresentation]
}

extension SDUIScreenDefinition {
    /// Finance presentations remain outside the scrollable section list, so
    /// renderers and the action reducer resolve them through this typed view.
    nonisolated var financeSheets: [SDUIComponentInstance<SDUIFinanceSheetProps>] {
        presentations.compactMap { presentation in
            guard case .financeSheet(let sheet) = presentation else {
                return nil
            }

            return sheet
        }
    }

    nonisolated func financeSheet(
        withID sheetID: String
    ) -> SDUIComponentInstance<SDUIFinanceSheetProps>? {
        financeSheets.first { $0.id == sheetID }
    }

    nonisolated func financeSheet(
        for selectionKey: SDUISelectionKey
    ) -> SDUIComponentInstance<SDUIFinanceSheetProps>? {
        financeSheets.first { $0.content.selectionKey == selectionKey }
    }
}

nonisolated enum SDUISection: Equatable, Sendable {
    case discoveryHeader(SDUIComponentInstance<SDUIDiscoveryHeaderProps>)
    case illustratedActionRail(SDUIComponentInstance<SDUIIllustratedActionRailProps>)
    case productRail(SDUIComponentInstance<SDUIProductRailProps>)
    case serviceGrid(SDUIComponentInstance<SDUIServiceGridProps>)
    case vehicleRail(SDUIComponentInstance<SDUIVehicleRailProps>)
    case highlightedServiceGrid(SDUIComponentInstance<SDUIHighlightedServiceGridProps>)
    case promoBanner(SDUIComponentInstance<SDUIPromoBannerProps>)
    case unsupported(SDUIUnsupportedNode)
    case invalid(SDUIInvalidNode)

    var id: String {
        switch self {
        case .discoveryHeader(let component): component.id
        case .illustratedActionRail(let component): component.id
        case .productRail(let component): component.id
        case .serviceGrid(let component): component.id
        case .vehicleRail(let component): component.id
        case .highlightedServiceGrid(let component): component.id
        case .promoBanner(let component): component.id
        case .unsupported(let node): node.id
        case .invalid(let node): node.id
        }
    }

    var type: String {
        switch self {
        case .discoveryHeader: SDUISectionType.discoveryHeader.rawValue
        case .illustratedActionRail: SDUISectionType.illustratedActionRail.rawValue
        case .productRail: SDUISectionType.productRail.rawValue
        case .serviceGrid: SDUISectionType.serviceGrid.rawValue
        case .vehicleRail: SDUISectionType.vehicleRail.rawValue
        case .highlightedServiceGrid: SDUISectionType.highlightedServiceGrid.rawValue
        case .promoBanner: SDUISectionType.promoBanner.rawValue
        case .unsupported(let node): node.type
        case .invalid(let node): node.type
        }
    }

    var declaredActions: [SDUIAction] {
        switch self {
        case .discoveryHeader(let component):
            component.actions
        case .illustratedActionRail(let component):
            component.actions + component.content.declaredActions
        case .productRail(let component):
            component.actions + component.content.declaredActions
        case .serviceGrid(let component):
            component.actions + component.content.declaredActions
        case .vehicleRail(let component):
            component.actions + component.content.declaredActions
        case .highlightedServiceGrid(let component):
            component.actions + component.content.declaredActions
        case .promoBanner(let component):
            component.actions + component.content.declaredActions
        case .unsupported, .invalid:
            []
        }
    }

    func invalidating(_ reason: String) -> SDUISection {
        .invalid(
            SDUIInvalidNode(
                id: id,
                type: type,
                placement: .section,
                reason: reason
            )
        )
    }
}

nonisolated enum SDUIPresentation: Equatable, Sendable {
    case financeSheet(SDUIComponentInstance<SDUIFinanceSheetProps>)
    case unsupported(SDUIUnsupportedNode)
    case invalid(SDUIInvalidNode)

    var id: String {
        switch self {
        case .financeSheet(let component): component.id
        case .unsupported(let node): node.id
        case .invalid(let node): node.id
        }
    }

    var type: String {
        switch self {
        case .financeSheet: SDUIPresentationType.financeSheet.rawValue
        case .unsupported(let node): node.type
        case .invalid(let node): node.type
        }
    }

    var declaredActions: [SDUIAction] {
        switch self {
        case .financeSheet(let component):
            component.actions + component.content.declaredActions
        case .unsupported, .invalid:
            []
        }
    }

    func invalidating(_ reason: String) -> SDUIPresentation {
        .invalid(
            SDUIInvalidNode(
                id: id,
                type: type,
                placement: .presentation,
                reason: reason
            )
        )
    }
}

nonisolated struct SDUIUnsupportedNode: Equatable, Sendable {
    let id: String
    let type: String
    let placement: SDUINodePlacement
}

nonisolated struct SDUIInvalidNode: Equatable, Sendable {
    let id: String
    let type: String
    let placement: SDUINodePlacement
    let reason: String
}

nonisolated struct SDUIDiscoveryHeaderProps: Decodable, Equatable, Sendable {
    let title: String
    let subtitle: String?
    let symbolName: String?
}

nonisolated struct SDUIContentItem: Decodable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let imageName: String?
    let action: SDUIAction?
}

nonisolated struct SDUIIllustratedActionRailProps: Decodable, Equatable, Sendable {
    let title: String
    let badgeText: String?
    let items: [SDUIContentItem]

    var declaredActions: [SDUIAction] {
        items.compactMap(\.action)
    }
}

nonisolated struct SDUIProductRailProps: Decodable, Equatable, Sendable {
    let title: String
    let items: [SDUIContentItem]

    var declaredActions: [SDUIAction] {
        items.compactMap(\.action)
    }
}

nonisolated struct SDUIServiceGridProps: Decodable, Equatable, Sendable {
    let title: String
    let columns: Int
    let items: [SDUIContentItem]

    var declaredActions: [SDUIAction] {
        items.compactMap(\.action)
    }
}

nonisolated struct SDUIHighlightedServiceGridProps: Decodable, Equatable, Sendable {
    let title: String
    let accent: SDUIAccent
    let columns: Int
    let items: [SDUIContentItem]

    var declaredActions: [SDUIAction] {
        items.compactMap(\.action)
    }
}

nonisolated struct SDUIPromoBannerProps: Decodable, Equatable, Sendable {
    let title: String
    let subtitle: String?
    let imageName: String
    let accessibilityLabel: String
    let action: SDUIAction?

    var declaredActions: [SDUIAction] {
        action.map { [$0] } ?? []
    }
}

nonisolated struct SDUILabelAction: Decodable, Equatable, Sendable {
    let label: String
    let action: SDUIAction
}

nonisolated struct SDUIVehicleRailProps: Decodable, Equatable, Sendable {
    let title: String
    let trailingAction: SDUILabelAction?
    let vehicles: [SDUIVehicleCard]

    var declaredActions: [SDUIAction] {
        let trailingActions = trailingAction.map { [$0.action] } ?? []
        return trailingActions + vehicles.compactMap(\.finance?.action)
    }
}

nonisolated struct SDUIVehicleCard: Decodable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let priceText: String
    let metadata: [String]
    let finance: SDUIVehicleFinance?
}

nonisolated struct SDUIVehicleFinance: Decodable, Equatable, Sendable {
    let sheetID: String
    let action: SDUIAction
}

nonisolated struct SDUIFinanceSheetProps: Decodable, Equatable, Sendable {
    let title: String
    let selectionKey: SDUISelectionKey
    let initialOptionID: String
    let options: [SDUIFinanceOption]

    var declaredActions: [SDUIAction] {
        options.map(\.action)
    }

    /// Chooses a declared display value without calculating or storing finance
    /// data locally. Validation guarantees the initial option is declared.
    nonisolated func displayedOption(selectedID: String?) -> SDUIFinanceOption? {
        if let selectedID,
           let selectedOption = options.first(where: { $0.id == selectedID }) {
            return selectedOption
        }

        return options.first { $0.id == initialOptionID }
    }
}

nonisolated struct SDUIFinanceOption: Decodable, Equatable, Sendable {
    let id: String
    let label: String
    let emiText: String
    let action: SDUIAction
}

nonisolated enum SDUIComponentValidation {
    static func validate(_ props: SDUIDiscoveryHeaderProps) -> String? {
        requiredText(props.title, named: "Header title")
    }

    static func validate(_ props: SDUIIllustratedActionRailProps) -> String? {
        if let error = requiredText(props.title, named: "Rail title") {
            return error
        }

        return validateItems(props.items, requireImages: true)
    }

    static func validate(_ props: SDUIProductRailProps) -> String? {
        if let error = requiredText(props.title, named: "Rail title") {
            return error
        }

        return validateItems(props.items, requireImages: true)
    }

    static func validate(_ props: SDUIServiceGridProps) -> String? {
        if let error = requiredText(props.title, named: "Grid title") {
            return error
        }

        if let error = validateColumns(props.columns) {
            return error
        }

        return validateItems(props.items, requireImages: false)
    }

    static func validate(_ props: SDUIHighlightedServiceGridProps) -> String? {
        if let error = requiredText(props.title, named: "Grid title") {
            return error
        }

        if let error = validateColumns(props.columns) {
            return error
        }

        return validateItems(props.items, requireImages: false)
    }

    static func validate(_ props: SDUIPromoBannerProps) -> String? {
        requiredText(props.title, named: "Banner title")
            ?? requiredText(props.imageName, named: "Banner image name")
            ?? requiredText(props.accessibilityLabel, named: "Banner accessibility label")
            ?? invalidMediaReference(props.imageName)
    }

    static func validate(_ props: SDUIVehicleRailProps) -> String? {
        if let error = requiredText(props.title, named: "Vehicle rail title") {
            return error
        }

        guard !props.vehicles.isEmpty else {
            return "Vehicle rail requires at least one vehicle."
        }

        var seenIDs = Set<String>()
        for vehicle in props.vehicles {
            if let error = requiredText(vehicle.id, named: "Vehicle ID")
                ?? requiredText(vehicle.title, named: "Vehicle title")
                ?? requiredText(vehicle.subtitle, named: "Vehicle subtitle")
                ?? requiredText(vehicle.imageName, named: "Vehicle image name")
                ?? requiredText(vehicle.priceText, named: "Vehicle price")
                ?? invalidMediaReference(vehicle.imageName) {
                return error
            }

            guard seenIDs.insert(vehicle.id).inserted else {
                return "Vehicle IDs must be unique within a vehicle rail."
            }

            guard !vehicle.metadata.isEmpty else {
                return "Vehicle metadata must not be empty."
            }

            if vehicle.metadata.contains(where: { requiredText($0, named: "Vehicle metadata") != nil }) {
                return "Vehicle metadata must not contain blank values."
            }

            if let finance = vehicle.finance {
                guard requiredText(finance.sheetID, named: "Finance sheet ID") == nil else {
                    return "Finance sheet ID must not be blank."
                }

                guard case .presentSheet(let actionSheetID) = finance.action, actionSheetID == finance.sheetID else {
                    return "Vehicle finance must present its declared finance sheet."
                }
            }
        }

        if let trailingAction = props.trailingAction,
           let error = requiredText(trailingAction.label, named: "Trailing action label") {
            return error
        }

        return nil
    }

    static func validate(_ props: SDUIFinanceSheetProps) -> String? {
        if let error = requiredText(props.title, named: "Finance sheet title")
            ?? requiredText(props.initialOptionID, named: "Initial finance option ID") {
            return error
        }

        guard !props.options.isEmpty else {
            return "Finance sheet requires at least one tenure option."
        }

        var optionIDs = Set<String>()
        for option in props.options {
            if let error = requiredText(option.id, named: "Finance option ID")
                ?? requiredText(option.label, named: "Finance option label")
                ?? requiredText(option.emiText, named: "Finance option EMI") {
                return error
            }

            guard optionIDs.insert(option.id).inserted else {
                return "Finance option IDs must be unique within a sheet."
            }

            guard case .setSelection(let key, let optionID) = option.action,
                  key == props.selectionKey,
                  optionID == option.id
            else {
                return "Each finance option must set its own declared selection value."
            }
        }

        guard optionIDs.contains(props.initialOptionID) else {
            return "Initial finance option must be declared by the sheet."
        }

        return nil
    }

    private static func validateItems(
        _ items: [SDUIContentItem],
        requireImages: Bool
    ) -> String? {
        guard !items.isEmpty else {
            return "A collection component requires at least one item."
        }

        var seenIDs = Set<String>()
        for item in items {
            if let error = requiredText(item.id, named: "Item ID")
                ?? requiredText(item.title, named: "Item title") {
                return error
            }

            guard seenIDs.insert(item.id).inserted else {
                return "Item IDs must be unique within a component."
            }

            if requireImages, item.imageName == nil {
                return "This component requires an image name for every item."
            }

            if let imageName = item.imageName,
               let error = requiredText(imageName, named: "Item image name")
                ?? invalidMediaReference(imageName) {
                return error
            }
        }

        return nil
    }

    private static func validateColumns(_ columns: Int) -> String? {
        (2...3).contains(columns) ? nil : "Grid columns must be either 2 or 3."
    }

    private static func requiredText(_ value: String, named name: String) -> String? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "\(name) must not be blank."
            : nil
    }

    private static func invalidMediaReference(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.contains("://"), !trimmed.hasPrefix("/") else {
            return "Media references must be local asset tokens, not URLs or file paths."
        }

        return nil
    }
}
