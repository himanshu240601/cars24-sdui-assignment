//
//  SDUIDocumentDecoderTests.swift
//  Cars24SDUITests
//
//  Created for the CARS24 SDUI assignment.
//

import Foundation
import Testing
@testable import Cars24SDUI

struct SDUIDocumentDecoderTests {
    private let decoder = SDUIDocumentDecoder()

    @Test("The primary V1 fixture maps into a complete typed screen definition")
    func decodesPrimaryFixture() throws {
        let outcome = decoder.decode(try fixtureData(named: "home-v1"))
        let document = try #require(compatibleDocument(from: outcome))

        #expect(document.schemaVersion == 1)
        #expect(document.screenID == "cars24-home")
        #expect(document.sections.map(\.type) == [
            "discoveryHeader",
            "illustratedActionRail",
            "productRail",
            "serviceGrid",
            "vehicleRail",
            "highlightedServiceGrid",
            "promoBanner"
        ])
        #expect(document.presentations.count == 1)

        guard case .serviceGrid(let grid) = document.sections[3] else {
            Issue.record("The fixture must contain a service grid at the planned index.")
            return
        }

        #expect(grid.content.title == "Car check services")
        #expect(grid.content.columns == 3)
        #expect(grid.content.items.map(\.id) == [
            "new-car-pdi",
            "used-car-check",
            "vehicle-history",
            "check-challan",
            "car-insurance",
            "odometer-tampering"
        ])

        guard case .vehicleRail(let rail) = document.sections[4] else {
            Issue.record("The fixture must contain a vehicle rail at the planned index.")
            return
        }

        let financedVehicle = try #require(rail.content.vehicles.first)
        #expect(financedVehicle.id == "2020-tata-nexon")
        #expect(financedVehicle.title == "2020 Tata NEXON")
        #expect(financedVehicle.priceText == "₹6.25 lakh")
        #expect(financedVehicle.metadata == ["55,986 km", "Petrol", "Manual", "HR01"])
        #expect(financedVehicle.finance?.sheetID == "finance-options")
        #expect(financedVehicle.finance?.action == .presentSheet(sheetID: "finance-options"))

        guard case .financeSheet(let sheet) = document.presentations[0] else {
            Issue.record("The fixture must contain a finance sheet presentation.")
            return
        }

        #expect(sheet.content.initialOptionID == "48-months")
        #expect(sheet.content.options.map(\.id) == ["36-months", "48-months", "60-months"])
        #expect(sheet.content.options.map(\.label) == ["36 months", "48 months", "60 months"])
        #expect(sheet.content.options.map(\.emiText) == [
            "EMI ₹20,598/month",
            "EMI ₹16,008/month",
            "EMI ₹13,313/month"
        ])
        #expect(sheet.content.options.map(\.action) == [
            .setSelection(selectionKey: .selectedTenure, optionID: "36-months"),
            .setSelection(selectionKey: .selectedTenure, optionID: "48-months"),
            .setSelection(selectionKey: .selectedTenure, optionID: "60-months")
        ])
    }

    @Test("An unknown component remains local and known siblings stay valid")
    func preservesUnknownComponent() throws {
        let outcome = decoder.decode(try fixtureData(named: "home-v1-unknown-component"))
        let document = try #require(compatibleDocument(from: outcome))

        #expect(document.sections[0].type == "discoveryHeader")
        #expect(document.sections[2].type == "productRail")

        guard case .unsupported(let node) = document.sections[1] else {
            Issue.record("The unknown component must map to an unsupported node.")
            return
        }

        #expect(node.id == "seasonal-offer")
        #expect(node.type == "seasonalOfferCarousel")
        #expect(node.placement == .section)
    }

    @Test("Invalid known props become a local invalid node")
    func isolatesInvalidComponent() throws {
        let outcome = decoder.decode(try fixtureData(named: "home-v1-invalid-component"))
        let document = try #require(compatibleDocument(from: outcome))

        guard case .invalid(let node) = document.sections[1] else {
            Issue.record("Invalid known props must not fail the entire document.")
            return
        }

        #expect(node.id == "invalid-service-grid")
        #expect(node.type == "serviceGrid")
        #expect(node.reason == "Grid columns must be either 2 or 3.")
        #expect(document.sections[2].type == "productRail")
    }

    @Test("An unsupported schema major returns a screen-level compatibility outcome")
    func rejectsUnsupportedSchemaMajor() throws {
        let outcome = decoder.decode(try fixtureData(named: "home-v2-unsupported-major"))

        #expect(outcome == .unsupportedSchema(major: 2))
    }

    @Test("Duplicate component IDs invalidate the root document")
    func rejectsDuplicateComponentIdentifiers() throws {
        let outcome = decoder.decode(try fixtureData(named: "home-v1-invalid-root"))

        #expect(outcome == .invalidDocument(.duplicateComponentID("duplicate-section")))
    }

    @Test("Malformed JSON returns the document-level error outcome")
    func rejectsMalformedJSON() {
        let outcome = decoder.decode(Data("{\"schemaVersion\":".utf8))

        #expect(outcome == .invalidDocument(.malformedPayload))
    }

    @Test("Unknown optional fields and actions do not prevent valid content from decoding")
    func ignoresUnknownOptionalFieldsAndActions() throws {
        let data = Data(
            """
            {
              "schemaVersion": 1,
              "screenID": "tolerant-document",
              "unknownRootField": true,
              "sections": [
                {
                  "id": "header",
                  "type": "discoveryHeader",
                  "unknownComponentField": "ignored",
                  "actions": [
                    { "type": "futureAction", "payload": "ignored" }
                  ],
                  "props": {
                    "title": "Hello",
                    "unknownProp": "ignored"
                  }
                }
              ]
            }
            """.utf8
        )

        let outcome = decoder.decode(data)
        let document = try #require(compatibleDocument(from: outcome))

        guard case .discoveryHeader(let header) = document.sections[0] else {
            Issue.record("The known header should remain valid.")
            return
        }

        #expect(header.actions == [.unsupported(type: "futureAction")])
    }

    @Test("The action vocabulary is typed and malformed actions are safe no-ops")
    func decodesActionsSafely() throws {
        let actions = try JSONDecoder().decode(
            [SDUIAction].self,
            from: Data(
                """
                [
                  {
                    "type": "setSelection",
                    "selectionKey": "selectedTenure",
                    "optionID": "48-months"
                  },
                  {
                    "type": "presentSheet",
                    "sheetID": "finance-options"
                  },
                  {
                    "type": "dismissSheet"
                  },
                  {
                    "type": "futureAction"
                  },
                  {
                    "type": "presentSheet"
                  }
                ]
                """.utf8
            )
        )

        #expect(actions == [
            .setSelection(selectionKey: .selectedTenure, optionID: "48-months"),
            .presentSheet(sheetID: "finance-options"),
            .dismissSheet,
            .unsupported(type: "futureAction"),
            .unavailable(type: "presentSheet", reason: "presentSheet requires sheetID.")
        ])
    }

    @Test("Malformed action values degrade locally instead of invalidating the document")
    func toleratesMalformedActionShapes() throws {
        let data = Data(
            """
            {
              "schemaVersion": 1,
              "screenID": "malformed-actions",
              "sections": [
                {
                  "id": "header-with-malformed-values",
                  "type": "discoveryHeader",
                  "actions": [null, "not-an-object"],
                  "props": {
                    "title": "Still valid"
                  }
                },
                {
                  "id": "header-with-malformed-container",
                  "type": "discoveryHeader",
                  "actions": {
                    "type": "presentSheet"
                  },
                  "props": {
                    "title": "Also still valid"
                  }
                },
                {
                  "id": "valid-sibling",
                  "type": "productRail",
                  "props": {
                    "title": "Get loans",
                    "items": [
                      {
                        "id": "loan",
                        "title": "Used car loan",
                        "imageName": "product-used-car-loan"
                      }
                    ]
                  }
                }
              ]
            }
            """.utf8
        )

        let outcome = decoder.decode(data)
        let document = try #require(compatibleDocument(from: outcome))

        guard case .discoveryHeader(let malformedValuesHeader) = document.sections[0],
              case .discoveryHeader(let malformedContainerHeader) = document.sections[1]
        else {
            Issue.record("Malformed actions must not invalidate their known components.")
            return
        }

        #expect(malformedValuesHeader.actions == [
            .unavailable(type: "<malformed>", reason: "Action must be a JSON object."),
            .unavailable(type: "<malformed>", reason: "Action must be a JSON object.")
        ])
        #expect(malformedContainerHeader.actions == [
            .unavailable(type: "<malformed>", reason: "Actions must be a JSON array.")
        ])
        #expect(document.sections[2].type == "productRail")
    }

    @Test("A finance action with no declared sheet invalidates only its vehicle rail")
    func isolatesMissingFinanceReference() throws {
        let data = Data(
            """
            {
              "schemaVersion": 1,
              "screenID": "missing-finance-sheet",
              "sections": [
                {
                  "id": "vehicle-rail",
                  "type": "vehicleRail",
                  "props": {
                    "title": "Used cars",
                    "vehicles": [
                      {
                        "id": "vehicle-1",
                        "title": "Example vehicle",
                        "subtitle": "Example trim",
                        "imageName": "vehicle-example",
                        "priceText": "₹1 lakh",
                        "metadata": ["Petrol"],
                        "finance": {
                          "sheetID": "missing-sheet",
                          "action": {
                            "type": "presentSheet",
                            "sheetID": "missing-sheet"
                          }
                        }
                      }
                    ]
                  }
                },
                {
                  "id": "header",
                  "type": "discoveryHeader",
                  "props": {
                    "title": "Still valid"
                  }
                }
              ]
            }
            """.utf8
        )

        let outcome = decoder.decode(data)
        let document = try #require(compatibleDocument(from: outcome))

        guard case .invalid(let node) = document.sections[0] else {
            Issue.record("A missing finance target should invalidate only the affected rail.")
            return
        }

        #expect(node.reason == "presentSheet must target a declared finance sheet.")
        #expect(document.sections[1].type == "discoveryHeader")
    }

    private func compatibleDocument(
        from outcome: SDUIDocumentParseOutcome
    ) -> SDUIScreenDefinition? {
        guard case .compatible(let document) = outcome else {
            return nil
        }

        return document
    }

    private func fixtureData(named name: String) throws -> Data {
        let testDirectory = URL(filePath: #filePath)
            .deletingLastPathComponent()
        let projectDirectory = testDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let fixtureURL = projectDirectory
            .appendingPathComponent("Cars24SDUI/Resources/SDUI")
            .appendingPathComponent(name)
            .appendingPathExtension("json")

        return try Data(contentsOf: fixtureURL)
    }
}
