# PartyTime

PartyTime is a iOS application built with SwiftUI focused on event discovery and ticket management. It provides a platform where users can find local events, and hosts can manage their guest lists and event logistics.

---

<div align="center">
  <video src="https://github.com/user-attachments/assets/be5df594-c936-416b-a13a-28527b0edf9e" width="100%" controls>
    Your browser does not support the video tag.
  </video>
</div>

---

## Architecture & Core Logic

The project is built using the **MVVM (Model-View-ViewModel)** pattern to ensure a clean separation of concerns and a reactive UI.

- **Generic Networking Layer**: I implemented a centralized `api` class that utilizes a single generic `request<T: Decodable>` method. This method handles URL construction, header injection, JSON encoding/decoding, and error handling for the entire application.
    
- **Type Safety**: Every data model in the app (e.g., `partyDetails`, `userProfile`, `hostParty`) is designed as a `Codable` struct that matches the backend's JSON schema 1:1. This eliminates the need for manual data parsing and ensures high reliability across network calls.
    
- **Protocol-Oriented Auth**: Authentication logic is abstracted behind an `authServiceProtocol`, allowing for cleaner dependency injection and easier testing.
    

## Tech Stack

- **Language**: Swift 5.10+
    
- **UI Framework**: SwiftUI
    
- **Backend Services**: Firebase Authentication
    
- **Networking**: Swift Concurrency (`async/await`) with `URLSession`
    
- **Location Services**: CoreLocation for proximity-based event filtering
    

## Key Technical Features

### Secure Authentication & JWT Flow

The app uses Firebase Auth for user management but communicates with a custom backend. I implemented a secure flow where the app retrieves a Firebase ID Token (JWT) and automatically injects it into the `Authorization` header for all protected API calls. This ensures that user sessions are handled securely without storing sensitive credentials locally.

### Dynamic Stateful UI

The application state is managed using `@StateObject` and `@Published` properties. The interface responds dynamically to user permissions; for example, the main navigation updates in real-time to reveal hosting tools only after a user successfully upgrades their account status.

### Guest-Host Lifecycle Management

The app manages the full event lifecycle:

- **Guests**: Can filter parties by distance or hashtags, save events, and request to join.
    
- **Hosts**: Access a specialized dashboard to manage "The Line" (pending requests), view guest lists, and track attendee counts in real-time.
    

## Future Improvements

- **Stripe Integration**: Moving from the current payment placeholder to the Stripe iOS SDK to facilitate real transactions and host payouts.
    
- **Secure QR Tickets**: Replacing the current placeholder ticket view with a system that generates dynamic QR codes for secure door entry.
    
- **MapKit Integration**: Adding an interactive map view to visualize event locations relative to the user's current position.

