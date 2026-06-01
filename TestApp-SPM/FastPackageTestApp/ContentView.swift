import SwiftUI
import FastPackage

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("FastPackage TestApp (SPM)")
                .font(.headline)
            Text("FastPackage v\(FastPackage.version)")
                .font(.subheadline)
            Text(Optional<String>.none.nullSafe("Hello from FastPackage"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
