//
//  SDUIPromoBannerSection.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// Renders a static, client-styled promotion from the typed banner contract.
/// It deliberately does not fabricate a CTA when the payload declares none.
struct SDUIPromoBannerSection: View {
    let component: SDUIComponentInstance<SDUIPromoBannerProps>

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(component.content.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                if let subtitle = component.content.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.16))

                SDUILocalAssetImageView(
                    assetName: component.content.imageName,
                    fallbackSymbolName: "music.note",
                    fallbackColor: .white
                )
                .frame(width: 50, height: 50)
            }
            .frame(width: 88, height: 88)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 144, alignment: .leading)
        .background(
            SDUIStyle.promoColor,
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(component.content.accessibilityLabel)
        .accessibilityIdentifier("sdui-promo-\(component.id)")
    }
}
