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

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SDUIStyle.sectionSpacing) {
                ForEach(definition.sections, id: \.id) { section in
                    SDUISectionRenderer(section: section)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("sdui-section-\(section.id)")
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemBackground))
        .accessibilityIdentifier("sdui-screen-\(definition.screenID)")
    }
}

private struct SDUISectionRenderer: View {
    let section: SDUISection

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
        case .unsupported(let node):
            SDUISectionFallbackView(id: node.id, kind: .unsupported)
        case .invalid(let node):
            SDUISectionFallbackView(id: node.id, kind: .invalid)
        case .vehicleRail, .highlightedServiceGrid, .promoBanner:
            // These are known V1 types whose native renderers are deliberately
            // deferred to later approved milestones. They are not unsupported
            // payload nodes and must not be labelled as such.
            EmptyView()
        }
    }
}
