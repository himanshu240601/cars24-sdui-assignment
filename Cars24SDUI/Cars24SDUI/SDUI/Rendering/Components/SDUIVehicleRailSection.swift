//
//  SDUIVehicleRailSection.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// Renders typed vehicle information and emits only the declared finance
/// action. Vehicle-detail navigation is intentionally outside the assignment.
struct SDUIVehicleRailSection: View {
    let component: SDUIComponentInstance<SDUIVehicleRailProps>
    let financeSheets: [SDUIComponentInstance<SDUIFinanceSheetProps>]
    let selectedTenureOptionID: String?
    let onAction: (SDUIAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: component.content.title)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: SDUIStyle.railItemSpacing) {
                    ForEach(component.content.vehicles, id: \.id) { vehicle in
                        SDUIVehicleCardView(
                            railID: component.id,
                            vehicle: vehicle,
                            financeSheet: financeSheet(for: vehicle),
                            selectedTenureOptionID: selectedTenureOptionID,
                            onAction: onAction
                        )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }

    private func financeSheet(
        for vehicle: SDUIVehicleCard
    ) -> SDUIComponentInstance<SDUIFinanceSheetProps>? {
        guard let finance = vehicle.finance else {
            return nil
        }

        return financeSheets.first { $0.id == finance.sheetID }
    }
}

private struct SDUIVehicleCardView: View {
    let railID: String
    let vehicle: SDUIVehicleCard
    let financeSheet: SDUIComponentInstance<SDUIFinanceSheetProps>?
    let selectedTenureOptionID: String?
    let onAction: (SDUIAction) -> Void

    private var displayedFinanceOption: SDUIFinanceOption? {
        financeSheet?.content.displayedOption(selectedID: selectedTenureOptionID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            vehicleArtwork

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(vehicle.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            metadata

            Text(vehicle.priceText)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .monospacedDigit()

            if let finance = vehicle.finance,
               let financeSheet,
               let displayedFinanceOption {
                financeAction(
                    finance: finance,
                    sheet: financeSheet,
                    displayedOption: displayedFinanceOption
                )
            }
        }
        .padding(16)
        .frame(width: 300, alignment: .topLeading)
        .background(
            Color(uiColor: .systemBackground),
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
                .stroke(SDUIStyle.borderColor.opacity(0.55), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sdui-item-\(railID)-\(vehicle.id)")
    }

    private var vehicleArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SDUIStyle.mutedSurface)

            SDUILocalAssetImageView(
                assetName: vehicle.imageName,
                fallbackSymbolName: "car.fill",
                fallbackColor: SDUIStyle.brandColor
            )
            .frame(width: 132, height: 92)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 132)
    }

    private var metadata: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                metadataChips
            }

            VStack(alignment: .leading, spacing: 6) {
                metadataChips
            }
        }
    }

    @ViewBuilder
    private var metadataChips: some View {
        ForEach(vehicle.metadata.indices, id: \.self) { index in
            Text(vehicle.metadata[index])
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(SDUIStyle.mutedSurface, in: Capsule())
        }
    }

    private func financeAction(
        finance: SDUIVehicleFinance,
        sheet: SDUIComponentInstance<SDUIFinanceSheetProps>,
        displayedOption: SDUIFinanceOption
    ) -> some View {
        Button {
            onAction(finance.action)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayedOption.emiText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                        .accessibilityIdentifier("sdui-vehicle-emi-\(vehicle.id)")

                    Text(sheet.content.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SDUIStyle.brandColor)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(SDUIStyle.mutedSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("sdui-action-finance-\(vehicle.id)")
        .accessibilityLabel("\(vehicle.title), \(displayedOption.emiText), \(sheet.content.title)")
        .accessibilityHint("Opens finance options.")
    }
}
