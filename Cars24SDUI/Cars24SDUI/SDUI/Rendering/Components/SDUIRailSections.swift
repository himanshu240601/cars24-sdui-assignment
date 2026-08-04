//
//  SDUIRailSections.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

struct SDUIIllustratedActionRailSection: View {
    let component: SDUIComponentInstance<SDUIIllustratedActionRailProps>

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(
                title: component.content.title,
                badgeText: component.content.badgeText
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: SDUIStyle.railItemSpacing) {
                    ForEach(component.content.items, id: \.id) { item in
                        SDUIIllustratedActionCard(item: item)
                            .accessibilityIdentifier(
                                "sdui-item-\(component.id)-\(item.id)"
                            )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }
}

struct SDUIProductRailSection: View {
    let component: SDUIComponentInstance<SDUIProductRailProps>

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: component.content.title)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: SDUIStyle.railItemSpacing) {
                    ForEach(component.content.items, id: \.id) { item in
                        SDUIProductRailItem(item: item)
                            .accessibilityIdentifier(
                                "sdui-item-\(component.id)-\(item.id)"
                            )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }
}

struct SDUISectionTitleView: View {
    let title: String
    var badgeText: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            if let badgeText {
                Text(badgeText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.red, in: Capsule())
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, SDUIStyle.horizontalInset)
    }
}

private struct SDUIIllustratedActionCard: View {
    let item: SDUIContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            HStack {
                Spacer(minLength: 0)

                SDUILocalAssetImageView(
                    assetName: item.imageName,
                    fallbackSymbolName: "car.fill",
                    fallbackColor: .white
                )
                .frame(width: 72, height: 64)
            }
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(width: 176, alignment: .leading)
        .frame(minHeight: 156, alignment: .leading)
        .background(SDUIStyle.brandColor, in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}

private struct SDUIProductRailItem: View {
    let item: SDUIContentItem

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(SDUIStyle.contentSurface)

                SDUILocalAssetImageView(
                    assetName: item.imageName,
                    fallbackSymbolName: "indianrupeesign.circle.fill",
                    fallbackColor: SDUIStyle.brandColor
                )
                .frame(width: 64, height: 64)
            }
            .frame(width: 108, height: 108)
            .overlay(Circle().stroke(SDUIStyle.brandColor.opacity(0.28), lineWidth: 1))

            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 128, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}
