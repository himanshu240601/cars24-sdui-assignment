//
//  SDUIFinanceSheet.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// A native sheet for the validated finance presentation. It has no local
/// selection state: each option emits its JSON-defined action to the store.
struct SDUIFinanceSheet: View {
    let component: SDUIComponentInstance<SDUIFinanceSheetProps>
    let selectedOptionID: String?
    let onAction: (SDUIAction) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(component.content.title)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 12) {
                    ForEach(component.content.options, id: \.id) { option in
                        SDUIFinanceOptionButton(
                            option: option,
                            isSelected: option.id == selectedOptionID,
                            onAction: onAction
                        )
                        .accessibilityIdentifier(
                            "sdui-finance-option-\(component.id)-\(option.id)"
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, SDUIStyle.horizontalInset)
            .padding(.vertical, 24)
        }
        .accessibilityIdentifier("sdui-sheet-\(component.id)")
    }
}

private struct SDUIFinanceOptionButton: View {
    let option: SDUIFinanceOption
    let isSelected: Bool
    let onAction: (SDUIAction) -> Void

    var body: some View {
        Button {
            onAction(option.action)
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.label)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(option.emiText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(SDUIStyle.brandColor)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(optionBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(optionBorder, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.label), \(option.emiText)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var optionBackground: Color {
        isSelected ? SDUIStyle.brandColor.opacity(0.12) : SDUIStyle.contentSurface
    }

    private var optionBorder: Color {
        isSelected ? SDUIStyle.brandColor : SDUIStyle.borderColor.opacity(0.55)
    }
}
