//
//  SDUIHighlightedServiceGridSection.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// Renders a typed, visually prominent group of static vehicle services.
/// Actions remain intentionally out of scope for this component in V1.
struct SDUIHighlightedServiceGridSection: View {
    let component: SDUIComponentInstance<SDUIHighlightedServiceGridProps>

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(component.content.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: gridColumns,
                alignment: .leading,
                spacing: SDUIStyle.gridItemSpacing
            ) {
                ForEach(component.content.items, id: \.id) { item in
                    SDUIHighlightedServiceTile(
                        item: item,
                        accentColor: accentColor
                    )
                    .accessibilityIdentifier(
                        "sdui-item-\(component.id)-\(item.id)"
                    )
                }
            }
        }
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentColor)
    }

    private var accentColor: Color {
        switch component.content.accent {
        case .indigo:
            SDUIStyle.brandColor
        case .emerald:
            SDUIStyle.emeraldColor
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(
                .flexible(minimum: 0),
                spacing: SDUIStyle.gridItemSpacing,
                alignment: .top
            ),
            count: renderedColumnCount
        )
    }

    private var renderedColumnCount: Int {
        // This follows the standard grid's readable accessibility fallback
        // while retaining the payload's declared layout at normal text sizes.
        dynamicTypeSize.isAccessibilitySize ? min(component.content.columns, 2) : component.content.columns
    }
}

private struct SDUIHighlightedServiceTile: View {
    let item: SDUIContentItem
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            HStack {
                Spacer(minLength: 0)

                SDUILocalAssetImageView(
                    assetName: item.imageName,
                    fallbackSymbolName: "wrench.and.screwdriver.fill",
                    fallbackColor: accentColor
                )
                .frame(width: 52, height: 52)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            Color(uiColor: .systemBackground),
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}
