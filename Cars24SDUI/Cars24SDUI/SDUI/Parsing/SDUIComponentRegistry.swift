//
//  SDUIComponentRegistry.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation

/// Converts a tolerant wire component into a concrete, immutable native model.
/// This is a model registry, not a view-factory registry: SwiftUI rendering is
/// deliberately introduced in a later milestone.
nonisolated struct SDUIComponentRegistry: Sendable {
    func makeSection(from raw: SDUIRawComponent) -> SDUISection {
        guard let type = SDUISectionType(rawValue: raw.type) else {
            if raw.type == SDUIPresentationType.financeSheet.rawValue {
                return invalidSection(
                    raw,
                    reason: "financeSheet is a presentation and cannot appear in scrollable sections."
                )
            }

            return .unsupported(
                SDUIUnsupportedNode(id: raw.id, type: raw.type, placement: .section)
            )
        }

        switch type {
        case .discoveryHeader:
            return section(
                from: raw,
                props: SDUIDiscoveryHeaderProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.discoveryHeader
            )
        case .illustratedActionRail:
            return section(
                from: raw,
                props: SDUIIllustratedActionRailProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.illustratedActionRail
            )
        case .productRail:
            return section(
                from: raw,
                props: SDUIProductRailProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.productRail
            )
        case .serviceGrid:
            return section(
                from: raw,
                props: SDUIServiceGridProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.serviceGrid
            )
        case .vehicleRail:
            return section(
                from: raw,
                props: SDUIVehicleRailProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.vehicleRail
            )
        case .highlightedServiceGrid:
            return section(
                from: raw,
                props: SDUIHighlightedServiceGridProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.highlightedServiceGrid
            )
        case .promoBanner:
            return section(
                from: raw,
                props: SDUIPromoBannerProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUISection.promoBanner
            )
        }
    }

    func makePresentation(from raw: SDUIRawComponent) -> SDUIPresentation {
        guard let type = SDUIPresentationType(rawValue: raw.type) else {
            if SDUISectionType(rawValue: raw.type) != nil {
                return invalidPresentation(
                    raw,
                    reason: "\(raw.type) is a scrollable section and cannot appear in presentations."
                )
            }

            return .unsupported(
                SDUIUnsupportedNode(id: raw.id, type: raw.type, placement: .presentation)
            )
        }

        switch type {
        case .financeSheet:
            return presentation(
                from: raw,
                props: SDUIFinanceSheetProps.self,
                validate: { SDUIComponentValidation.validate($0) },
                make: SDUIPresentation.financeSheet
            )
        }
    }

    private func section<Props: Decodable & Equatable & Sendable>(
        from raw: SDUIRawComponent,
        props: Props.Type,
        validate: (Props) -> String?,
        make: (SDUIComponentInstance<Props>) -> SDUISection
    ) -> SDUISection {
        switch instance(from: raw, props: props, validate: validate) {
        case .success(let instance):
            make(instance)
        case .failure(let failure):
            invalidSection(raw, reason: failure.message)
        }
    }

    private func presentation<Props: Decodable & Equatable & Sendable>(
        from raw: SDUIRawComponent,
        props: Props.Type,
        validate: (Props) -> String?,
        make: (SDUIComponentInstance<Props>) -> SDUIPresentation
    ) -> SDUIPresentation {
        switch instance(from: raw, props: props, validate: validate) {
        case .success(let instance):
            make(instance)
        case .failure(let failure):
            invalidPresentation(raw, reason: failure.message)
        }
    }

    private func instance<Props: Decodable & Equatable & Sendable>(
        from raw: SDUIRawComponent,
        props: Props.Type,
        validate: (Props) -> String?
    ) -> Result<SDUIComponentInstance<Props>, SDUIComponentMappingFailure> {
        let variant: SDUIVisualVariant?
        if let rawVariant = raw.variant {
            guard let resolvedVariant = SDUIVisualVariant(rawValue: rawVariant) else {
                return .failure(.unsupportedVariant(rawVariant))
            }

            variant = resolvedVariant
        } else {
            variant = nil
        }

        guard let rawProps = raw.props else {
            return .failure(.missingProps)
        }

        do {
            let decodedProps = try rawProps.decoded(as: props)
            if let reason = validate(decodedProps) {
                return .failure(.invalidContent(reason))
            }

            return .success(
                SDUIComponentInstance(
                    id: raw.id,
                    variant: variant,
                    actions: raw.actions,
                    content: decodedProps
                )
            )
        } catch {
            return .failure(.invalidPropertyShape)
        }
    }

    private func invalidSection(_ raw: SDUIRawComponent, reason: String) -> SDUISection {
        .invalid(
            SDUIInvalidNode(
                id: raw.id,
                type: raw.type,
                placement: .section,
                reason: reason
            )
        )
    }

    private func invalidPresentation(_ raw: SDUIRawComponent, reason: String) -> SDUIPresentation {
        .invalid(
            SDUIInvalidNode(
                id: raw.id,
                type: raw.type,
                placement: .presentation,
                reason: reason
            )
        )
    }
}

nonisolated enum SDUIComponentMappingFailure: Error, Equatable, Sendable {
    case missingProps
    case unsupportedVariant(String)
    case invalidPropertyShape
    case invalidContent(String)

    var message: String {
        switch self {
        case .missingProps:
            "Known components require props."
        case .unsupportedVariant(let variant):
            "Unsupported visual variant: \(variant)."
        case .invalidPropertyShape:
            "Component props do not match the declared V1 contract."
        case .invalidContent(let reason):
            reason
        }
    }
}
