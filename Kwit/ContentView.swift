import SwiftUI

struct ContentView: View {
    @State private var urlText = ""
    @State private var qrImage: UIImage?
    @State private var svgURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("https://example.com", text: $urlText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button("Generate") { generate() }
                    .buttonStyle(.borderedProminent)
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let image = qrImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.image = image
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }

                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("QR Code", image: Image(uiImage: image))
                    ) {
                        Label("PNG", systemImage: "photo")
                    }

                    if let url = svgURL {
                        ShareLink(item: url, preview: SharePreview("QR Code SVG")) {
                            Label("SVG", systemImage: "doc.text")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .padding(.bottom)
            } else {
                ContentUnavailableView(
                    "No QR Code",
                    systemImage: "qrcode",
                    description: Text("Enter a URL and tap Generate")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .navigationTitle("QR Generator")
        .onSubmit { generate() }
    }

    private func generate() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        qrImage = QRCodeGenerator.generateImage(from: trimmed)
        svgURL = QRCodeGenerator.svgTempURL(from: trimmed)
        errorMessage = qrImage == nil ? "Failed to generate QR code" : nil
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
