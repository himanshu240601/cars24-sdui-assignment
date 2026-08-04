//
//  SDUIServiceGridSection.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// Renders the standard, neutral utility grid defined by `serviceGrid`.
struct SDUIServiceGridSection: View {
    let component: SDUIComponentInstance<SDUIServiceGridProps>

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: component.content.title)

            LazyVGrid(
                columns: gridColumns,
                alignment: .leading,
                spacing: SDUIStyle.gridItemSpacing
            ) {
                ForEach(component.content.items, id: \.id) { item in
                    SDUIGridItemTile(item: item)
                        .accessibilityIdentifier(
                            "sdui-item-\(component.id)-\(item.id)"
                        )
                }
            }
            .padding(.horizontal, SDUIStyle.horizontalInset)
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
        // The schema already restricts the configured value to two or three.
        // At accessibility text sizes, a three-column layout leaves too little
        // room for readable service labels, so the client narrows it to two.
        dynamicTypeSize.isAccessibilitySize ? min(component.content.columns, 2) : component.content.columns
    }
}

/// A small visual primitive for static service-grid content. It deliberately
/// has no action handling until the JSON action dispatcher is introduced.
private struct SDUIGridItemTile: View {
    let item: SDUIContentItem

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
                    fallbackColor: SDUIStyle.brandColor
                )
                .frame(width: 52, height: 52)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            SDUIStyle.contentSurface,
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
                .stroke(SDUIStyle.borderColor, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}
