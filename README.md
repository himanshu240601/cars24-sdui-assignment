# Cars24 SDUI Assignment

A native iOS implementation of a **Server-Driven UI (SDUI)** system built with SwiftUI.

> **Context**
>
> This project was completed as a technical assignment during an interview process with **Cars24**.
>
> It is an independent implementation created for evaluation purposes and is **not an official Cars24 product or production codebase**.

The assignment focused on designing a flexible, type-safe UI system capable of rendering screens from JSON-defined components while maintaining predictable behavior, graceful fallbacks, and measurable performance.

## Overview

The project explores how a mobile application can move part of its UI definition from hardcoded client-side views to a server-driven schema.

Instead of defining every screen directly in SwiftUI, the application consumes structured JSON and maps it to supported native components.

The implementation focuses on:

- Type-safe SDUI models
- JSON-driven rendering
- Component validation
- Graceful fallback handling
- Action routing
- Dependency injection
- Swift Concurrency
- Performance comparison against static SwiftUI
- Deterministic fixtures for testing and benchmarking

## Key Features

### Server-Driven UI

- JSON-defined UI structure
- Typed component models
- Native SwiftUI rendering
- Component-based rendering pipeline
- Support for extensible UI definitions

### Validation & Fallbacks

The renderer validates incoming component data before attempting to display it.

Unsupported or invalid components fall back gracefully instead of breaking the entire screen.

This helps make the SDUI layer more resilient to:

- Unsupported component types
- Missing properties
- Invalid payloads
- Schema mismatches
- Unexpected server-side changes

### Action Handling

UI actions are represented through structured action models rather than being tightly coupled to individual views.

This makes it easier to support actions such as:

- Navigation
- External links
- Button interactions
- Future server-defined behavior

### Static UI Baseline

The project includes a traditional static SwiftUI implementation of the same experience.

This provides a baseline for comparing:

- Rendering behavior
- Complexity
- Maintainability
- Performance
- Flexibility

between static and server-driven approaches.

### Performance Instrumentation

The project includes instrumentation for comparing the SDUI and static implementations.

The goal is not only to make the SDUI approach work, but also to understand the runtime cost introduced by:

- JSON decoding
- Model validation
- Component mapping
- Dynamic rendering

## Architecture

The project separates responsibilities across distinct layers.

```text
cars24-sdui-assignment/
│
├── App/
│
├── Models/
│   ├── SDUI models
│   ├── Component models
│   └── Action models
│
├── Rendering/
│   ├── Component renderer
│   ├── Validation
│   └── Fallback handling
│
├── Networking/
│
├── Services/
│
├── DependencyInjection/
│
├── StaticUI/
│
├── Performance/
│
├── Resources/
│   └── JSON fixtures
│
├── Tests/
│
├── ARCHITECTURE.md
└── README.md
```

## SDUI Flow

At a high level, the application follows this flow:

```text
JSON Payload
     ↓
Decoding
     ↓
Typed SDUI Models
     ↓
Validation
     ↓
Component Renderer
     ↓
Native SwiftUI Views
     ↓
Action Handling
```

Invalid or unsupported components follow a fallback path:

```text
Component
     ↓
Validation
     ↓
Unsupported / Invalid
     ↓
Fallback UI
```

## Tech Stack

- Swift
- SwiftUI
- Swift Concurrency
- Codable
- URLSession
- Dependency Injection
- XCTest
- JSON-based SDUI schema
- Performance instrumentation

## Dependency Injection

The project uses manual dependency injection rather than introducing a third-party DI framework.

Dependencies are created and passed explicitly, helping keep the implementation:

- Easy to reason about
- Testable
- Lightweight
- Free from unnecessary framework coupling

## JSON Fixtures

Deterministic JSON fixtures are included in the project to make the behavior reproducible.

These fixtures are useful for:

- Testing supported components
- Testing invalid components
- Verifying fallback behavior
- Performance benchmarking
- Development without depending on a live backend

## Performance Comparison

One of the goals of the assignment was to compare the SDUI implementation with a traditional static SwiftUI screen.

The comparison focuses on areas such as:

- Initial rendering cost
- JSON decoding overhead
- Validation overhead
- Rendering complexity
- Maintainability trade-offs
- Flexibility of server-controlled layouts

The static implementation provides a useful baseline for evaluating the cost and benefits of introducing SDUI.

## Design Decisions

### Typed Models Over Dictionaries

The implementation favors strongly typed models instead of passing arbitrary dictionaries throughout the rendering layer.

This provides:

- Compile-time safety
- Easier debugging
- Clear component contracts
- Better maintainability
- More predictable rendering behavior

### Graceful Failure

A single unsupported component should not prevent an entire screen from rendering.

For this reason, unsupported or malformed components are handled through explicit fallback behavior.

### Native Rendering

Although the screen definition is server-driven, the rendered components remain native SwiftUI views.

This allows the application to retain:

- Native performance
- Accessibility
- Platform behavior
- SwiftUI composition
- Type-safe client-side implementation

## Running the Project

Clone the repository:

```bash
git clone https://github.com/himanshu240601/cars24-sdui-assignment.git
cd cars24-sdui-assignment
```

Open the Xcode project:

```bash
open *.xcodeproj
```

Select an iOS simulator or physical device and run the application.

The included JSON fixtures allow the project to be explored without requiring a live backend.

## Documentation

The repository also contains additional documentation covering the implementation in more detail.

### Architecture

See:

```text
ARCHITECTURE.md
```

for architectural decisions and component relationships.

### SDUI Schema

The project includes documentation and examples describing the JSON structure consumed by the renderer.

### Performance

Performance-related documentation and instrumentation explain how the static and SDUI implementations were compared.

## What I Focused On

While working on this assignment, I focused on:

- Designing a typed SDUI contract
- Keeping rendering logic extensible
- Handling malformed server data safely
- Separating rendering from action handling
- Using structured concurrency
- Keeping dependencies explicit
- Comparing dynamic and static rendering approaches
- Making the implementation easy to inspect and evaluate
- Documenting architectural decisions and trade-offs

## Out of Scope

The project intentionally focuses on the SDUI architecture rather than recreating a complete production application.

Areas such as the following were intentionally kept outside the core scope:

- Production backend infrastructure
- Complete Cars24 application functionality
- Production analytics
- Authentication
- Full design-system coverage
- Remote feature management
- Production monitoring

## Project Status

This repository represents the completed technical assignment and is not under active product development.

It is preserved as a portfolio project demonstrating my approach to iOS architecture, SwiftUI, Server-Driven UI, validation, performance, and engineering trade-offs.

## Disclaimer

This repository was created independently as part of a technical interview assignment.

Cars24 trademarks, branding, and referenced product concepts belong to their respective owners.

This repository is **not affiliated with, endorsed by, or maintained by Cars24**, and it should not be considered representative of Cars24's production architecture or internal systems.

## Author

**Himanshu Goyal**

GitHub: [@himanshu240601](https://github.com/himanshu240601)

## License

No open-source license is currently specified for this repository.
