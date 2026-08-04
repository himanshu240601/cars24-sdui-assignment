//
//  SDUISectionFallbackView.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

enum SDUISectionFallbackKind: String {
    case unsupported
    case invalid

    var title: String {
        switch self {
        case .unsupported:
            "Some content is unavailable"
        case .invalid:
            "This content could not be displayed"
        }
    }

    var message: String {
        switch self {
        case .unsupported:
            "This part of the screen is not supported by this app version."
        case .invalid:
            "This section is temporarily unavailable."
        }
    }

    var symbolName: String {
        switch self {
        case .unsupported:
            "rectangle.slash"
        case .invalid:
            "exclamationmark.triangle"
        }
    }
}

/// A compact in-feed fallback for one failed or future payload node.
struct SDUISectionFallbackView: View {
    let id: String
    let kind: SDUISectionFallbackKind

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: kind.symbolName)
                .font(.title3)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                    .font(.headline)
                Text(kind.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(SDUIStyle.mutedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title). \(kind.message)")
        .accessibilityIdentifier("sdui-fallback-\(kind.rawValue)-\(id)")
    }
}
