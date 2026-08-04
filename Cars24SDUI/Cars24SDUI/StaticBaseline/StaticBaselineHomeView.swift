//
//  StaticBaselineHomeView.swift
//  Cars24SDUI
//
//  Created for the CARS24 SDUI assignment.
//

import SwiftUI

/// A direct SwiftUI rendering of the canonical V1 screen used only as the
/// assignment's SDUI performance control. Its source-code content snapshot is
/// intentional: this view must not load, decode, validate, or dynamically
/// route the bundled JSON document.
struct StaticBaselineHomeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: SDUIStyle.sectionSpacing) {
                    StaticBaselineHeader()
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-discovery-header")

                    StaticBaselineIllustratedActionRail()
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-buy-actions")

                    StaticBaselineProductRail()
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-loan-products")

                    StaticBaselineServiceGrid(columns: gridColumns)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-car-check-services")

                    StaticBaselineVehicleRail()
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-used-cars-youll-love")

                    StaticBaselineHighlightedServiceGrid(columns: gridColumns)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-manage-your-vehicle")

                    StaticBaselinePromoBanner()
                        .id(finalSectionID)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("static-baseline-section-spotify-promo")
                        .onAppear {
                            SDUIPerformanceSignposts.end(.bootstrapToFullContent)
                        }
                }
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemBackground))
            .accessibilityIdentifier("static-baseline-home")
            .onAppear {
                SDUIPerformanceSignposts.markInitialScreenReady()

                if SDUIPerformanceSignposts.shouldScrollToEnd {
                    DispatchQueue.main.async {
                        scrollProxy.scrollTo(finalSectionID, anchor: .bottom)
                    }
                }
            }
        }
    }

    private let finalSectionID = "static-baseline-final-section"

    private var gridColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 2 : 3

        return Array(
            repeating: GridItem(
                .flexible(minimum: 0),
                spacing: SDUIStyle.gridItemSpacing,
                alignment: .top
            ),
            count: count
        )
    }
}

private struct StaticBaselineHeader: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "car.fill")
                .font(.title2.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.16), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Find your next car")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                Text("Cars24 discovery")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SDUIStyle.brandColor)
    }
}

private struct StaticBaselineIllustratedActionRail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(
                title: "Buy car",
                badgeText: "Up to ₹80,000 off"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: SDUIStyle.railItemSpacing) {
                    ForEach(StaticBaselineContent.buyActions) { item in
                        StaticBaselineIllustratedActionCard(item: item)
                            .accessibilityIdentifier(
                                "static-baseline-item-buy-actions-\(item.id)"
                            )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }
}

private struct StaticBaselineProductRail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: "Get loans")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: SDUIStyle.railItemSpacing) {
                    ForEach(StaticBaselineContent.loanProducts) { item in
                        StaticBaselineProductRailItem(item: item)
                            .accessibilityIdentifier(
                                "static-baseline-item-loan-products-\(item.id)"
                            )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }
}

private struct StaticBaselineServiceGrid: View {
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: "Car check services")

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: SDUIStyle.gridItemSpacing
            ) {
                ForEach(StaticBaselineContent.carCheckServices) { item in
                    StaticBaselineServiceTile(
                        item: item,
                        surfaceColor: SDUIStyle.contentSurface,
                        borderColor: SDUIStyle.borderColor,
                        symbolColor: SDUIStyle.brandColor
                    )
                    .accessibilityIdentifier(
                        "static-baseline-item-car-check-services-\(item.id)"
                    )
                }
            }
            .padding(.horizontal, SDUIStyle.horizontalInset)
        }
    }
}

private struct StaticBaselineVehicleRail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SDUISectionTitleView(title: "Used cars you'll love")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: SDUIStyle.railItemSpacing) {
                    ForEach(StaticBaselineContent.vehicles) { vehicle in
                        StaticBaselineVehicleCard(vehicle: vehicle)
                            .accessibilityIdentifier(
                                "static-baseline-item-used-cars-youll-love-\(vehicle.id)"
                            )
                    }
                }
                .padding(.horizontal, SDUIStyle.horizontalInset)
            }
        }
    }
}

private struct StaticBaselineHighlightedServiceGrid: View {
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Manage your vehicle")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: SDUIStyle.gridItemSpacing
            ) {
                ForEach(StaticBaselineContent.vehicleServices) { item in
                    StaticBaselineServiceTile(
                        item: item,
                        surfaceColor: Color(uiColor: .systemBackground),
                        borderColor: nil,
                        symbolColor: SDUIStyle.brandColor
                    )
                    .accessibilityIdentifier(
                        "static-baseline-item-manage-your-vehicle-\(item.id)"
                    )
                }
            }
        }
        .padding(.horizontal, SDUIStyle.horizontalInset)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SDUIStyle.brandColor)
    }
}

private struct StaticBaselinePromoBanner: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cars24 × Spotify Premium")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("A membership benefit for your next drive")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.16))

                SDUILocalAssetImageView(
                    assetName: "promo-spotify-premium",
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
        .accessibilityLabel("Cars24 and Spotify Premium offer")
        .accessibilityIdentifier("static-baseline-promo-spotify-promo")
    }
}

private struct StaticBaselineIllustratedActionCard: View {
    let item: StaticBaselineItem

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
        .background(
            SDUIStyle.brandColor,
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}

private struct StaticBaselineProductRailItem: View {
    let item: StaticBaselineItem

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
            .overlay(
                Circle().stroke(SDUIStyle.brandColor.opacity(0.28), lineWidth: 1)
            )

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

private struct StaticBaselineServiceTile: View {
    let item: StaticBaselineItem
    let surfaceColor: Color
    let borderColor: Color?
    let symbolColor: Color

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
                    fallbackColor: symbolColor
                )
                .frame(width: 52, height: 52)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            surfaceColor,
            in: RoundedRectangle(cornerRadius: SDUIStyle.cardCornerRadius, style: .continuous)
        )
        .overlay {
            if let borderColor {
                RoundedRectangle(
                    cornerRadius: SDUIStyle.cardCornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
    }
}

private struct StaticBaselineVehicleCard: View {
    let vehicle: StaticBaselineVehicle

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

            if let emiText = vehicle.emiText {
                VStack(alignment: .leading, spacing: 4) {
                    Text(emiText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()

                    Text("Choose your loan tenure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    SDUIStyle.mutedSurface,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
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
        ForEach(vehicle.metadata, id: \.self) { value in
            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(SDUIStyle.mutedSurface, in: Capsule())
        }
    }

    private var accessibilityLabel: String {
        guard let emiText = vehicle.emiText else {
            return "\(vehicle.title), \(vehicle.priceText)"
        }

        return "\(vehicle.title), \(vehicle.priceText), \(emiText)"
    }
}

private struct StaticBaselineItem: Identifiable {
    let id: String
    let title: String
    let imageName: String
}

private struct StaticBaselineVehicle: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let priceText: String
    let metadata: [String]
    let emiText: String?
}

/// Canonical V1 values intentionally live in source here instead of using the
/// SDUI fixture. Keep this snapshot in sync with `home-v1.json` when that
/// benchmark control changes.
private enum StaticBaselineContent {
    static let buyActions = [
        StaticBaselineItem(
            id: "all-used-cars",
            title: "All used cars",
            imageName: "illustration-all-used-cars"
        ),
        StaticBaselineItem(
            id: "budget-used-cars",
            title: "Budget used cars",
            imageName: "illustration-budget-used-cars"
        ),
        StaticBaselineItem(
            id: "premium-used-cars",
            title: "Premium used cars",
            imageName: "illustration-premium-used-cars"
        )
    ]

    static let loanProducts = [
        StaticBaselineItem(
            id: "used-car-loan",
            title: "Used car loan",
            imageName: "product-used-car-loan"
        ),
        StaticBaselineItem(
            id: "loan-against-car",
            title: "Loan against car",
            imageName: "product-loan-against-car"
        ),
        StaticBaselineItem(
            id: "personal-loan",
            title: "Personal loan",
            imageName: "product-personal-loan"
        )
    ]

    static let carCheckServices = [
        StaticBaselineItem(id: "new-car-pdi", title: "New car PDI", imageName: "service-new-car-pdi"),
        StaticBaselineItem(id: "used-car-check", title: "Used car check", imageName: "service-used-car-check"),
        StaticBaselineItem(id: "vehicle-history", title: "Vehicle history", imageName: "service-vehicle-history"),
        StaticBaselineItem(id: "check-challan", title: "Check challan", imageName: "service-check-challan"),
        StaticBaselineItem(id: "car-insurance", title: "Check car insurance", imageName: "service-car-insurance"),
        StaticBaselineItem(id: "odometer-tampering", title: "Odometer tampering", imageName: "service-odometer-tampering")
    ]

    static let vehicles = [
        StaticBaselineVehicle(
            id: "2020-tata-nexon",
            title: "2020 Tata NEXON",
            subtitle: "XZ Plus LUXS Jet",
            imageName: "vehicle-tata-nexon",
            priceText: "₹6.25 lakh",
            metadata: ["55,986 km", "Petrol", "Manual", "HR01"],
            emiText: "EMI ₹16,008/month"
        ),
        StaticBaselineVehicle(
            id: "2015-maruti-wagonr",
            title: "2015 Maruti WagonR",
            subtitle: "VXI",
            imageName: "vehicle-maruti-wagonr",
            priceText: "₹1.90 lakh",
            metadata: ["49,284 km", "Petrol", "Manual", "HR26"],
            emiText: nil
        )
    ]

    static let vehicleServices = [
        StaticBaselineItem(id: "pay-challan", title: "Pay challan", imageName: "manage-pay-challan"),
        StaticBaselineItem(id: "recharge-fastag", title: "Recharge FASTag", imageName: "manage-recharge-fastag"),
        StaticBaselineItem(id: "get-insurance", title: "Get insurance", imageName: "manage-get-insurance"),
        StaticBaselineItem(id: "cash-against-car", title: "Cash against car", imageName: "manage-cash-against-car"),
        StaticBaselineItem(id: "roadside-assistance", title: "Roadside assistance", imageName: "manage-roadside-assistance"),
        StaticBaselineItem(id: "get-warranty", title: "Get warranty", imageName: "manage-get-warranty")
    ]
}
