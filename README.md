# PartyTime Client

This is the iOS front-end client for my PartyTime app. It is **stateless** and talks to my custom built FastAPI backend. It manages users with Firebase Auth. This app will allow hosts to easily monetize, manage, and market their parties. Attendees will see personalized parties and refer other people. This is a work in progress!!


## Architecture & Core Logic

The project is organized using the **MVVM (Model-View-ViewModel)** pattern.

- **Generic Networking Layer**: I implemented a centralized `api` class that utilizes a single generic `request<T: Decodable>` method. This method handles URL construction, header injection, JSON encoding/decoding, and error handling for the entire application.
    
- **Type Safety**: Every data model in the app (e.g., `partyDetails`, `userProfile`, `hostParty`) is designed as a `Codable` struct that matches the backend's JSON schema 1:1. This eliminates the need for manual data parsing and ensures high reliability across network calls.
    
- **Protocol-Oriented Auth**: Authentication logic is abstracted behind an `authServiceProtocol`, allowing for clean dependency injection later on.
    
---

<div align="center">
  <video src="https://github.com/user-attachments/assets/be5df594-c936-416b-a13a-28527b0edf9e" width="100%" controls>
    Your browser does not support the video tag.
  </video>
</div>

*this demo doesnt use any mock data - it's all from the server and database!!*
---

## Tech Stack

- **Language**: Swift
    
- **UI Framework**: SwiftUI
    
- **Backend Services**: Firebase Authentication, my backend API
    
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

- **Advanced Features**: I want to eventually move to advanced features like a party groupchat for attendees and a for-you-page of personalized parties.

