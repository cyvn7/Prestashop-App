# Prestashop iOS Application

This project is an iOS application developed with SwiftUI that serves as a mobile storefront, communicating with a Prestashop backend through its REST API. The primary objective of the application is to provide a functional e-commerce experience, covering the full user journey from product discovery to order completion.

![shop](https://github.com/cyvn7/Prestashop-App/assets/42326412/b8be865f-6870-40a6-a486-210d84e0ef70)

## Technical Architecture

The application follows a modular design, separating concerns into distinct functional areas. This approach aims to facilitate maintenance and testing by isolating features such as catalog management, user accounts, and checkout logic. All external libraries were added using Swift Package Manager. 

### Core Technologies

* **SwiftUI**: Utilized as the primary framework for building the user interface, implementing a declarative approach to view management and data binding.
* **Alamofire**: Employed for handling network communications, including the execution of asynchronous HTTP requests (GET, POST, PUT, DELETE) and the management of API authentication.
* **SwiftyJSON**: Used to process JSON data returned by the Prestashop API, allowing for direct mapping to internal data models.
* **Kingfisher**: Integrated to manage remote image downloading and caching, which helps maintain smooth scrolling performance in product lists and grids.
* **Facebook SDK**: Included to support social authentication workflows within the application.
* **WebKit**: Used via `UIViewRepresentable` to render HTML-formatted product descriptions and documentation from external sources.

## Project Organization

The codebase is organized into several key directories based on functionality:

* **CartView**: Contains the views and logic associated with the shopping cart and checkout process.
* `CartView.swift`: Manages the local cart state and provides the interface for reviewing items before purchase.
* `CarrierSelectionView.swift`: Implements the interface for selecting available shipping methods.
* `ConfirmationView.swift`: Handles the final review of the order and constructs the XML payload required to submit the transaction to the server.


* **ProductsView**: Houses the product catalog and discovery features.
* `ProductsView.swift`: Provides the main entry point for browsing, including search and sorting capabilities.
* `CategoriesView.swift`: Implements a recursive navigation system for exploring the shop's category hierarchy.
* `FilterView.swift`: Offers an interface for narrowing down product lists based on price ranges and specific attributes.
* `ProductDetailsView.swift`: Orchestrates multiple data requests to present comprehensive product information, including galleries and suggested items.


* **ProfileView**: Manages user-specific data and account settings.
* `LoginView.swift` and `SignUpView.swift`: Provide the necessary interfaces for user authentication and registration.
* `OrdersView.swift`: Retrieves and displays the user's order history, mapping status codes to human-readable information.
* `Addresses/`: A sub-module dedicated to the management of user delivery and billing addresses.


* **Extras**: Includes utility components and shared services used throughout the app.
* `ModifyingCart.swift`: A service class responsible for synchronizing local cart changes with the Prestashop server.
* `Extentions.swift`: Contains various extensions for color management, HTML parsing, and global configuration constants.



## Implementation Details

The application implements several patterns to handle the specific requirements of the Prestashop API:

* **Data Coordination**: The `ProductDetailsView` utilizes `DispatchGroup` to synchronize independent network requests for product features and images, ensuring all data is available before the final view is rendered.
* **Server-Side Synchronization**: Cart operations are performed by generating specific XML payloads that are sent to the API via PUT and POST requests, ensuring that the user's cart remains consistent across sessions.
* **Persistent State**: User preferences, authentication tokens, and basic cart information are managed using `@AppStorage` and `UserDefaults` to maintain continuity between app launches.
* **Responsive Feedback**: Integration of `UIImpactFeedbackGenerator` provides subtle haptic feedback for significant user actions, such as adding an item to favorites or updating cart quantities.
