//
//  SDUILocalAssetImageView.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI
import UIKit

/// Renders a local asset token when available and a stable decorative symbol
/// while the assignment's original media assets are not bundled.
struct SDUILocalAssetImageView: View {
    let assetName: String?
    let fallbackSymbolName: String
    let fallbackColor: Color

    var body: some View {
        Group {
            if let image = localImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: fallbackSymbolName)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(fallbackColor)
            }
        }
        .accessibilityHidden(true)
    }

    private var localImage: UIImage? {
        guard let assetName else {
            return nil
        }

        return UIImage(named: assetName)
    }
}
