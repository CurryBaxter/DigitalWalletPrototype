import SwiftUI
import MapKit

// A simple model for dummy locations.
struct DummyLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let annotationType: AnnotationType

    enum AnnotationType {
        case card, user
    }
}

struct TrackingView: View {
    // Set a region that approximately fits both dummy locations.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.345299, longitude: 12.391359),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    // Dummy locations for the user and the physical card in Germany.
    private let dummyLocations = [
        DummyLocation(
            coordinate: CLLocationCoordinate2D(latitude: 51.345042, longitude: 12.391421),
            annotationType: .user
        ),
        DummyLocation(
            coordinate: CLLocationCoordinate2D(latitude: 51.345556, longitude: 12.391296),
            annotationType: .card
        )
    ]
    
    var body: some View {
        VStack {
            mapContainer
                .frame(height: 300)
                .padding()
            Spacer() // Pushes the container to the top.
        }
        .navigationTitle("Where is?")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // The map container view that adds a rounded rectangle background.
    private var mapContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 5)
            
            // Our custom MapView that uses the new initializer.
            MapView(region: $region, dummyLocations: dummyLocations)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    let dummyLocations: [DummyLocation]
    
    var body: some View {
        // Use the iOS 17 Map initializer with annotationItems.
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: .constant(.none),
            annotationItems: dummyLocations,
            annotationContent: { location in
                // If you're still using MapAnnotation (deprecated in iOS 17), update to Annotation as needed.
                MapAnnotation( coordinate: location.coordinate) {
                    annotationView(for: location)
                }
            }
        )
    }
    
    // A helper function that returns the appropriate annotation view.
    @ViewBuilder
    private func annotationView(for location: DummyLocation) -> some View {
        if location.annotationType == .card {
            VStack(spacing: 2) {
                Image(systemName: "creditcard.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Card")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        } else {
            VStack(spacing: 2) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.green)
                Text("You")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // For preview purposes only.
            TrackingView()
        }
    }
}
