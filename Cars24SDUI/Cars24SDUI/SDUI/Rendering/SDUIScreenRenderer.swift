//
//  SDUIScreenRenderer.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// Renders an already validated, immutable screen definition. Loading,
/// decoding, and action dispatch intentionally remain outside this view.
struct SDUIScreenRenderer: View {
    let definition: SDUIScreenDefinition
    let interactionState: SDUIScreenInteractionState
    let onAction: (SDUIAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SDUIStyle.sectionSpacing) {
                ForEach(definition.sections, id: \.id) { section in
                    SDUISectionRenderer(
                        section: section,
                        financeSheets: definition.financeSheets,
                        selectedTenureOptionID: interactionState.selectedTenureOptionID,
                        onAction: onAction
                    )
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sdui-section-\(section.id)")
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemBackground))
        .accessibilityIdentifier("sdui-screen-\(definition.screenID)")
        .sheet(isPresented: isFinanceSheetPresented) {
            if let activeFinanceSheet {
                SDUIFinanceSheet(
                    component: activeFinanceSheet,
                    selectedOptionID: interactionState.selectedTenureOptionID,
                    onAction: onAction
                )
                .presentationDetents(financeSheetDetents)
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var activeFinanceSheet: SDUIComponentInstance<SDUIFinanceSheetProps>? {
        guard let activeSheetID = interactionState.activeSheetID else {
            return nil
        }

        return definition.financeSheet(withID: activeSheetID)
    }

    private var isFinanceSheetPresented: Binding<Bool> {
        Binding(
            get: {
                activeFinanceSheet != nil
            },
            set: { isPresented in
                if !isPresented {
                    onAction(.dismissSheet)
                }
            }
        )
    }

    private var financeSheetDetents: Set<PresentationDetent> {
        dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large]
    }
}

private struct SDUISectionRenderer: View {
    let section: SDUISection
    let financeSheets: [SDUIComponentInstance<SDUIFinanceSheetProps>]
    let selectedTenureOptionID: String?
    let onAction: (SDUIAction) -> Void

    @ViewBuilder
    var body: some View {
        switch section {
        case .discoveryHeader(let component):
            SDUIDiscoveryHeaderSection(component: component)
        case .illustratedActionRail(let component):
            SDUIIllustratedActionRailSection(component: component)
        case .productRail(let component):
            SDUIProductRailSection(component: component)
        case .serviceGrid(let component):
            SDUIServiceGridSection(component: component)
        case .vehicleRail(let component):
            SDUIVehicleRailSection(
                component: component,
                financeSheets: financeSheets,
                selectedTenureOptionID: selectedTenureOptionID,
                onAction: onAction
            )
        case .highlightedServiceGrid(let component):
            SDUIHighlightedServiceGridSection(component: component)
        case .promoBanner(let component):
            SDUIPromoBannerSection(component: component)
        case .unsupported(let node):
            SDUISectionFallbackView(id: node.id, kind: .unsupported)
        case .invalid(let node):
            SDUISectionFallbackView(id: node.id, kind: .invalid)
        }
    }
}
