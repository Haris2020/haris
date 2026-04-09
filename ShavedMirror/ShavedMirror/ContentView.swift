import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var brightness: Double = UIScreen.main.brightness
    @State private var showControls = true
    @State private var controlsTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
                .scaleEffect(x: -1) // Mirror horizontally like a real mirror
                .onTapGesture {
                    toggleControls()
                }

            if showControls {
                VStack {
                    // Top bar
                    HStack {
                        Text("Mirror")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.leading)
                        Spacer()
                        Button(action: { cameraManager.toggleZoom() }) {
                            Image(systemName: cameraManager.isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Bottom controls
                    VStack(spacing: 16) {
                        // Brightness control
                        HStack(spacing: 12) {
                            Image(systemName: "sun.min.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.body)
                            Slider(value: $brightness, in: 0.1...1.0)
                                .accentColor(.white)
                                .onChange(of: brightness) { newValue in
                                    UIScreen.main.brightness = newValue
                                }
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.white)
                                .font(.body)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)

                        Text("Tap screen to hide controls")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.bottom, 8)
                    }
                    .padding(.bottom, 30)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showControls)
            }
        }
        .onAppear {
            cameraManager.start()
            UIApplication.shared.isIdleTimerDisabled = true
            scheduleHideControls()
        }
        .onDisappear {
            cameraManager.stop()
            UIApplication.shared.isIdleTimerDisabled = false
            UIScreen.main.brightness = brightness
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    private func toggleControls() {
        withAnimation {
            showControls.toggle()
        }
        if showControls {
            scheduleHideControls()
        }
    }

    private func scheduleHideControls() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
}
