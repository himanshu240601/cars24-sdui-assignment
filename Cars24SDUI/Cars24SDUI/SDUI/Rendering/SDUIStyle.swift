//
//  SDUIStyle.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI
import UIKit

/// Client-owned visual tokens for the small V1 renderer vocabulary.
enum SDUIStyle {
    static let horizontalInset: CGFloat = 20
    static let sectionSpacing: CGFloat = 28
    static let railItemSpacing: CGFloat = 12
    static let gridItemSpacing: CGFloat = 12
    static let cardCornerRadius: CGFloat = 20

    static let brandColor = Color.indigo
    static let contentSurface = Color(uiColor: .secondarySystemBackground)
    static let mutedSurface = Color(uiColor: .tertiarySystemBackground)
    static let borderColor = Color(uiColor: .separator)
}
