import SwiftUI

struct SummaryView: View {
    let image: UIImage?
    let predictionLabel: String
    let confidence: Double

    init(image: UIImage?, predictionLabel: String, confidence: Double) {
        self.image = image
        self.predictionLabel = predictionLabel
        self.confidence = confidence
        UINavigationBar.appearance().tintColor = UIColor.systemGreen
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy – HH.mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: Date())
    }

    private var resultInfo: (title: String, description: String, color: Color) {
        switch predictionLabel.lowercased() {
        case "unripe apple":
            return ("Belum Matang", "Apel masih keras dan belum manis", .orange)
        case "ripe apple":
            return ("Matang", "Siap dikonsumsi, rasa manis maksimal", .green)
        case "rotten apple":
            return ("Busuk", "Apel sudah tidak layak dikonsumsi", .red)
        default:
            return ("Tidak Dikenal", "Tidak bisa mendeteksi kondisi apel", .gray)
        }
    }

    private var isPredictionValid: Bool {
        predictionLabel != "No Frame or model" && confidence > 0.0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = image, isPredictionValid {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                        .clipped()
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                    Text(predictionLabel)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    resultSection
                    storageSection
                    buttonSection
                } else {
                    Text("Foto tidak terdeteksi")
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .font(.title3)
                    Text("Silakan coba scan ulang dengan pencahayaan yang lebih baik.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Hasil Scan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text("\(Int(confidence * 100))%")
                    .font(.title)
                    .bold()
                    .foregroundColor(resultInfo.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(resultInfo.title)
                        .font(.headline)
                        .foregroundColor(resultInfo.color)
                    Text(resultInfo.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(resultInfo.color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Lokasi Penyimpanan Ideal", systemImage: "thermometer")
                .font(.headline)

            Text("20–22°C")
                .font(.subheadline)
                .foregroundColor(.gray)

            infoSection(title: "Estimasi ketahanan",
                        content: "- Dalam Kulkas: tahan 7 hari\n- Suhu ruang: 2 hari lagi sebelum terlalu matang")

            infoSection(title: "Jika apel sudah dipotong",
                        content: "- Simpan potongan apel di wadah tertutup di kulkas.\n- Tambahkan air lemon atau air garam agar tidak cepat kecokelatan.")

            infoSection(title: "Tips lainnya",
                        content: "Jangan simpan apel di dekat pisang atau alpukat agar tidak cepat matang.\nGunakan kantong kertas untuk mempercepat kematangan jika ingin cepat dimakan.")
        }
        .padding(.horizontal)
    }

    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var buttonSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                // Back or rescan
            }) {
                Text("Scan Ulang")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }

            Button(action: {
                // Save action
            }) {
                Text("Simpan Apel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}
