//
//  SDUIDiscoveryHeaderSection.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// The assignment-scoped discovery header. It intentionally excludes the
/// screenshot's search, location, profile, and navigation controls.
struct SDUIDiscoveryHeaderSection: View {
    let component: SDUIComponentInstance<SDUIDiscoveryHeaderProps>

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let symbolName = component.content.symbolName {
                Image(systemName: symbolName)
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.16), in: Circle())
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(component.content.title)
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                if let subtitle = component.content.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
    }

    private var backgroundColor: Color {
        switch component.variant {
        case .branded:
            SDUIStyle.brandColor
        case .featured:
            .purple
        case .standard, nil:
            .blue
        }
    }
}
