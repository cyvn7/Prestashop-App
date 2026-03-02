# PrestaShop iOS App

A native iOS shopping application built entirely with **SwiftUI** that connects to a [PrestaShop](https://www.prestashop.com) back-end through its REST Web Services API. The app lets customers browse products by category, manage a persistent shopping cart, save favourites, place orders, and manage their account — all from a polished mobile interface.

![App screenshot](https://github.com/cyvn7/Prestashop-App/assets/42326412/b8be865f-6870-40a6-a486-210d84e0ef70)

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Module / Layer Breakdown](#module--layer-breakdown)
5. [Networking & API Integration](#networking--api-integration)
6. [Authentication & Session Handling](#authentication--session-handling)
7. [Persistence & Caching](#persistence--caching)
8. [UI Approach & Navigation](#ui-approach--navigation)
9. [Dependency Management](#dependency-management)
10. [Configuration](#configuration)
11. [Build & Run Instructions](#build--run-instructions)
12. [Testing](#testing)
13. [Roadmap](#roadmap)

---

## Overview

The app (internally codenamed **dynashop**) acts as a fully-functional mobile storefront for any PrestaShop-powered e-commerce site. It communicates with the store's built-in Web Services API, which returns data in JSON format and accepts create/update payloads as XML. The entire UI is written in SwiftUI (iOS 14+), with no UIKit view controllers in the critical path.

---

## Features

| Area | Capabilities |
|---|---|
| **Product Catalogue** | Browse a nested category tree; view paginated product lists in grid or list layout |
| **Product Details** | Full product page with image gallery, short/long description, manufacturer, reference code, product variants (option values), accessories, and bundle product support |
| **Sale Prices** | Real-time specific-price (discount) detection — supports both percentage and fixed-amount reductions with expiry dates |
| **Search** | Full-text product search filtered via the PrestaShop API |
| **Filtering** | Filter products by price range; filter panel driven by product features/attributes |
| **Shopping Cart** | Add, update, and remove items; cart badge counter with animated popup feedback; multi-step checkout flow |
| **Checkout Flow** | Address selection → Carrier selection → Payment selection → Order confirmation |
| **Order History** | View past orders with line-item detail and order-status labels |
| **Favourites / Wishlist** | Locally saved list of favourite products with quick add-to-cart |
| **User Accounts** | Registration, email/password login, logout, and account deletion |
| **Address Book** | List and delete saved delivery addresses linked to the logged-in customer |
| **Facebook Login** | Optional Sign-in with Facebook via the Facebook SDK |
| **Haptic Feedback** | Contextual light and medium haptics on key interactions |
| **In-app Web View** | WKWebView wrapper for external payment or support pages |

---

## Architecture

The app follows a **feature-module structure** with a pragmatic MVVM-lite approach native to SwiftUI:

```
PrestashopApp (App entry point)
└── RootView  (TabView — root coordinator)
    ├── ProfileView        (account / auth)
    ├── CategoriesView     (product catalogue)
    ├── CartView           (cart & checkout)
    └── FavouriteView      (wishlist)
```

- **Views** own their local `@State` and call service helpers directly via Alamofire.
- **Shared state** is propagated with `@EnvironmentObject` (`GlobalVars`) for cart-level signals (total-price refresh, add-to-cart popup visibility).
- **Session state** is stored in `UserDefaults` and accessed through `@AppStorage` property wrappers so that any view can react to login/logout without an explicit session manager object.
- Service logic that does not need to trigger UI updates (cart mutation, product fetching) lives in plain `class` helpers (`ModyfingCart`, etc.) rather than `ObservableObject` ViewModels, keeping the view layer thin.

---

## Module / Layer Breakdown

```
Prestashop/
├── PrestashopApp.swift        # @main entry point; initialises Facebook SDK URL handling
├── RootView.swift             # TabView host; custom cart-badge overlay
│
├── ProductsView/
│   ├── CategoriesView.swift   # Recursive category tree navigation
│   ├── ProductsView.swift     # Product list with sorting, search, and filter state
│   ├── ProductList.swift      # List-layout product row component
│   ├── ProductGridView.swift  # Grid-layout product card component
│   ├── ProductDetailsView.swift # Full product page (images, variants, add-to-cart)
│   ├── ProductPageView.swift  # Paged image gallery
│   ├── BundlesProductsView.swift # Bundle / pack product display
│   ├── FilterView.swift       # Price-range and feature filter sheet
│   └── ProductStructs.swift   # Data models: ProductModel, Category, SpecificPrice, CartItem
│
├── CartView/Views/
│   ├── CartView.swift         # Cart item list, quantity stepper, total price
│   ├── AddressSelectionView.swift  # Delivery address picker
│   ├── CarrierSelectionView.swift  # Shipping carrier picker
│   ├── PaymentSelectionView.swift  # Payment method selection
│   ├── ConfirmationView.swift # Order summary and place-order action
│   └── GreetingsView.swift    # Post-order success screen
│
├── ProfileView/
│   ├── StartScreen.swift      # Unauthenticated landing (Log In / Sign Up)
│   ├── LoginView.swift        # Email + password login form
│   ├── SignUpView.swift       # New-account registration form
│   ├── ProfileView.swift      # Authenticated user hub (addresses, orders, logout)
│   ├── Addresses/
│   │   └── AddressesView.swift # Address list with swipe-to-delete
│   └── Orders/
│       └── OrdersView.swift   # Order history list with status
│
├── FavouriteView/
│   └── FavouriteView.swift    # Saved products; add to cart from wishlist
│
├── SearchView/
│   └── SearchView.swift       # Search bar entry point
│
└── Extras/
    ├── Extentions.swift       # Global constants (apiKey, globalURL), Color extensions,
    │                          #   SwiftUI/UIKit bridging helpers, GlobalVars ObservableObject
    ├── ModifyingCart.swift    # Cart CRUD logic (create, update, delete cart via API)
    ├── GetProducts.swift      # Product-fetching service (sale prices, filters)
    ├── GettingProducts.swift  # Lightweight product-load protocol stub
    ├── CStepper.swift         # Custom quantity stepper component
    ├── CustomTextField.swift  # Styled text-field component
    ├── Popup.swift            # Add-to-cart success popup overlay
    └── SwiftUIWebView.swift   # WKWebView wrapped as a SwiftUI View
```

---

## Networking & API Integration

All network communication is handled by **Alamofire** (HTTP client) with **SwiftyJSON** for JSON traversal.

### Base URL & Authentication
The PrestaShop Web Services API uses **HTTP Basic Authentication** where the username is the API key and the password is empty. The app inlines the key as a query-string parameter (`ws_key`) for simplicity:

```
GET {globalURL}/products/?ws_key={apiKey}&io_format=JSON&display=full
```

> ⚠️  For security reasons, `apiKey` and `globalURL` are replaced with placeholder strings in this public repository. See [Configuration](#configuration).

### Request Format
- **Reads** (GET): JSON (`io_format=JSON`)
- **Writes** (POST/PUT/DELETE): XML body with `Content-Type: application/xml`

### Key API Endpoints Used

| Resource | Operations |
|---|---|
| `/products` | GET (list with filters, search, sort) |
| `/categories` | GET (category tree) |
| `/images/products/{id}/{imgId}` | GET (product images via Kingfisher) |
| `/specific_prices` | GET (active sale prices) |
| `/carts` | POST (create), PUT (update) |
| `/orders` | GET (order history), POST (place order) |
| `/order_states` | GET (status labels) |
| `/customers` | POST (register), DELETE (remove account) |
| `/addresses` | GET (list), DELETE (remove) |
| `/carriers` | GET (shipping options) |

### Concurrency
Concurrent API calls that must all complete before updating UI use `DispatchGroup` (enter/leave/notify pattern), e.g. fetching orders and order statuses in parallel.

---

## Authentication & Session Handling

Authentication is **form-based** against the PrestaShop customer API:

1. **Login** — The app POSTs the customer's email and password to the PrestaShop `/customers` endpoint filtered by email; the returned customer object provides the `id`, first name, and last name.
2. **Sign Up** — An XML payload is POSTed to `/customers` to create a new account; the returned `id` is stored immediately.
3. **Session persistence** — After a successful login or registration, the following keys are written to `UserDefaults`:

| Key | Type | Purpose |
|---|---|---|
| `userID` | Int | PrestaShop customer ID |
| `userFirstname` | String | Display name |
| `userLastname` | String | Display name |
| `email` | String | Cached email |
| `logged` | Bool | Auth flag read by `@AppStorage` |
| `cartID` | Int | Active cart ID on the server |
| `cartDict` | Dictionary | Local mirror of cart contents |
| `totalPrice` | Double | Cart total for badge display |
| `itemsBadge` | Int | Number of items in cart (tab badge) |

4. **Logout** — All session keys are removed from `UserDefaults` and the UI reverts to `StartScreen`.
5. **Account deletion** — Issues a DELETE request to `/customers/{id}` then calls logout.
6. **Facebook Login** — Integrated via `FBSDKLoginKit`; the app handles the deep-link callback in `onOpenURL`.

---

## Persistence & Caching

| Concern | Mechanism |
|---|---|
| Session / auth state | `UserDefaults` + `@AppStorage` |
| Cart contents | `UserDefaults` dictionary (`cartDict`) |
| Product images | **Kingfisher** in-memory and disk cache |
| Favourites | `UserDefaults` (encoded product list) |

There is no Core Data or SQLite layer; the server is the source of truth for products, orders, and addresses. Local state is limited to session tokens and transient UI state.

---

## UI Approach & Navigation

- **100% SwiftUI** — no UIKit view controllers; UIKit is only bridged for `WKWebView` (`UIViewRepresentable`) and haptic feedback generators.
- **Navigation model**: `TabView` (4 tabs) at the root; each tab uses `NavigationView` / `NavigationLink` for drill-down navigation.
- **Design tokens**: A custom `CColor` namespace provides a consistent colour palette (accent purple `fPurple`, accent yellow `fYellow`, dark).
- **Reusable components**: `CStepper` (quantity control), `CustomTextField` (styled input), `Popup` (add-to-cart toast), `SwiftUIWebView`.
- **Responsive layout**: `GeometryReader` is used to position the cart badge overlay relative to the tab bar width.
- **Haptics**: `UIImpactFeedbackGenerator` (`.light` and `.medium`) triggered on cart actions.

---

## Dependency Management

Dependencies are managed with **CocoaPods**.

| Pod | Version | Purpose |
|---|---|---|
| [Alamofire](https://github.com/Alamofire/Alamofire) | 5.x | HTTP networking |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | 5.x | JSON parsing |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | 7.x | Async image downloading and caching |
| [FBSDKLoginKit](https://github.com/facebook/facebook-ios-sdk) | 14.x | Facebook Sign-In |

---

## Configuration

Before building the app you must supply your own PrestaShop API credentials. Open `Prestashop/Extras/Extentions.swift` and replace the placeholder values:

```swift
// Prestashop/Extras/Extentions.swift

let apiKey   = "YOUR_WEBSERVICE_KEY"   // PrestaShop Web Services key
let globalURL = "https://your-shop.example.com/api"  // Base API URL (no trailing slash)
```

**How to obtain a Web Services key:**
1. In your PrestaShop back-office, go to **Advanced Parameters → Webservice**.
2. Enable the Web Service feature.
3. Create a new key, granting at minimum: `GET` on customers, products, categories, images, carts, orders, order_states, addresses, carriers, specific_prices; `POST`/`PUT`/`DELETE` on carts, orders, customers, addresses.

**Facebook App ID (optional):** If you intend to use Facebook Login, update `FacebookAppID` and `FacebookClientToken` in `Prestashop/Info.plist`.

---

## Build & Run Instructions

### Requirements

| Tool | Version |
|---|---|
| Xcode | 14.0 or later |
| iOS Deployment Target | iOS 14.0+ |
| CocoaPods | 1.12.0 or later |

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/cyvn7/Prestashop-App.git
cd Prestashop-App

# 2. Install CocoaPods dependencies
pod install

# 3. Open the generated workspace (not the .xcodeproj)
open Prestashop.xcworkspace

# 4. Set your API credentials in Prestashop/Extras/Extentions.swift
#    (see Configuration above)

# 5. Select a simulator or connected device and press ▶ Run
```

> **Note:** The repository omits the `Podfile.lock` and `Pods/` directory. Running `pod install` will fetch the latest compatible versions of all dependencies.

---

## Testing

The project does not currently include automated unit or UI tests. All verification has been performed manually using the iOS Simulator and physical devices.

Planned areas for future test coverage:
- Cart mutation logic (`ModyfingCart`) — unit tests with mocked `URLSession`
- Product model parsing — unit tests against sample JSON fixtures
- Authentication flow — UI tests with XCTest

---

## Roadmap

- [ ] Add unit tests for networking and cart logic
- [ ] Introduce a proper ViewModel layer (ObservableObject per screen) to decouple business logic from SwiftUI views
- [ ] Migrate API key storage to the iOS Keychain
- [ ] Add push notification support for order-status updates
- [ ] Implement pull-to-refresh on product and order lists
- [ ] Add accessibility labels (VoiceOver support)
- [ ] Support Dark Mode colour scheme
- [ ] Add localisation (i18n) support
- [ ] Explore Swift Package Manager (SPM) migration from CocoaPods
