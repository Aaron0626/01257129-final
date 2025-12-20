import SwiftUI
import FoundationModels
import PhotosUI
import TipKit
import Vision
import ConfettiSwiftUI

// 取得圖示名稱
func getSlotIconName(slot: String) -> String {
    switch slot {
    case "生之花": return "flower"
    case "死之羽": return "plume"
    case "時之沙": return "sands"
    case "空之杯": return "goblet"
    case "理之冠": return "circlet"
    default: return "questionmark.circle"
    }
}

// TipKit 提示
struct AppraisalTip: Tip {
    var title: Text { Text("自動辨識啟動") }
    var message: Text? { Text("上傳聖遺物截圖後，系統會自動辨識雙爆數值。") }
    var image: Image? { Image(systemName: "text.viewfinder") }
}

struct ArtifactScannerView: View {
    @EnvironmentObject var sharedData: SharedDataModel
    @State private var selectedIndex = 0
    @State private var judgeCharacter = "智慧"
    let judges = ["智慧", "嚴厲", "鼓勵", "冷淡"]
    let appraisalTip = AppraisalTip()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.back)
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame(.horizontal)
                    .ignoresSafeArea()
                    .overlay(.yellow.opacity(0.3))
                
                VStack(spacing: 10) {
                    VStack {
                        TipView(appraisalTip).tipBackground(.ultraThinMaterial).padding(.horizontal)
                        HStack {
                            HStack {
                                Text("當前鑑定：")
                                    .foregroundStyle(.black)
                                Image(getSlotIconName(slot: sharedData.artifacts[selectedIndex].slotName))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                                Text(sharedData.artifacts[selectedIndex].slotName)
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                            }
                            .padding(4)
                            .background(.white.opacity(0.4), in: Capsule())
                            Spacer()
                            Picker("評審", selection: $judgeCharacter) {
                                ForEach(judges, id: \.self) { Text($0) }
                            }
                            .tint(.cyan)
                            .padding(4)
                            .background(.white.opacity(0.3), in: Capsule())
                        }.padding(.horizontal).padding(.top, 5)
                    }
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(sharedData.artifacts.indices, id: \.self) { index in
                            ArtifactSlotCard(data: $sharedData.artifacts[index], judgeCharacter: judgeCharacter)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .orange
                        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
                    }
                }
            }
        }
        .onAppear { try? Tips.configure() }
    }
}

struct ArtifactSlotCard: View {
    @Binding var data: ArtifactData
    let judgeCharacter: String
    @State private var confettiCounter: Int = 0
    @State private var isScanning: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image(getSlotIconName(slot: data.slotName))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text(data.slotName)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                .padding(.top)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                
                VStack {
                    if let artifactImage = data.image {
                        artifactImage.resizable().scaledToFill()
                            .frame(width: 220, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                                    if isScanning {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.green, lineWidth: 4)
                                            .overlay {
                                                ZStack {
                                                    Color.black.opacity(0.3)
                                                    VStack {
                                                        ProgressView().tint(.white).scaleEffect(1.5)
                                                        Text("深度掃描中...").font(.caption).foregroundStyle(.white).bold()
                                                    }
                                                }
                                            }
                                    }
                                }
                            )
                            .shadow(color: .orange.opacity(0.4), radius: 8)
                    } else {
                        RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.1))
                            .frame(width: 220, height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "siri")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.gray)
                                    Text("上傳\(data.slotName)")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            )
                    }
                    PhotosPicker(selection: $data.selectedItem, matching: .images) {
                        Label("上傳並掃描", systemImage: "text.viewfinder")
                            .font(.subheadline.bold())
                            .padding()
                            .background(.orange.opacity(0.8))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                }
                
                VStack(spacing: 15) {
                    HStack {
                        Text("暴擊率").foregroundStyle(.white)
                        Spacer()
                        Text("\(data.critRate, specifier: "%.1f")%")
                            .foregroundStyle(.yellow)
                            .bold()
                        Stepper("", value: $data.critRate, in: 0...100, step: 0.1)
                            .labelsHidden()
                            .background(.white.opacity(0.8), in: Capsule())
                    }
                    HStack {
                        Text("暴擊傷害").foregroundStyle(.white)
                        Spacer()
                        Text("\(data.critDmg, specifier: "%.1f")%").foregroundStyle(.yellow).bold()
                        Stepper("", value: $data.critDmg, in: 0...300, step: 0.1)
                            .labelsHidden()
                            .background(.white.opacity(0.8), in: Capsule())
                    }
                }
                .padding().background(.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                
                Button { Task { await analyzeArtifact() } } label: {
                    HStack {
                        if data.isAnalyzing { ProgressView().tint(.white) } else { Image(systemName: "sparkles") }
                        Text(data.isAnalyzing ? "運算中..." : "鑑定此部位")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .disabled(data.isAnalyzing).padding(.horizontal)
                .confettiCannon(trigger: $confettiCounter, num: 50, confettis: [.sfSymbol(symbolName: "star.fill"), .shape(.circle)], colors: [.yellow, .orange, .purple])
                
                if data.score > 0 {
                    VStack(spacing: 5) {
                        Text("評分 (CV)").font(.caption).foregroundStyle(.gray)
                        Text("\(data.score, specifier: "%.1f")").font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundStyle(data.score >= 40 ? .orange : (data.score >= 30 ? .purple : .gray))
                        if data.score >= 40 {
                            Text("SS 極品神器")
                                .font(.headline)
                                .foregroundStyle(.yellow)
                                .padding(6)
                                .background(.red.opacity(0.8), in: Capsule())
                        }
                    }
                }
                Text(data.aiComment)
                    .font(.callout)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onChange(of: data.selectedItem) { oldvalue, newItem in
            Task {
                if let dataContent = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: dataContent) {
                    data.image = Image(uiImage: uiImage)
                    recognizeText(from: uiImage)
                }
            }
        }
    }
    
    func recognizeText(from uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return }
        isScanning = true
        data.aiComment = "正在掃描圖片數據..."
        let request = VNRecognizeTextRequest { request, error in
            defer { isScanning = false }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var foundCritRate: Double = 0.0
            var foundCritDmg: Double = 0.0
            var mainStatFound = false
            let sortedObservations = observations.sorted { $0.boundingBox.minY > $1.boundingBox.minY }
            
            for observation in sortedObservations {
                let cleanText = (observation.topCandidates(1).first?.string ?? "").replacingOccurrences(of: " ", with: "")
                guard let value = extractValue(from: cleanText) else { continue }
                
                if cleanText.contains("爆擊率") || cleanText.contains("暴擊率") || cleanText.contains("CritRate") {
                    if value > 20 && observation.boundingBox.minY > 0.6 { mainStatFound = true }
                    else if value < 25 { foundCritRate = max(foundCritRate, value) }
                }
                if cleanText.contains("爆擊傷害") || cleanText.contains("暴擊傷害") || cleanText.contains("CritDMG") {
                    if value > 40 && observation.boundingBox.minY > 0.6 { mainStatFound = true }
                    else { foundCritDmg = max(foundCritDmg, value) }
                }
            }
            DispatchQueue.main.async {
                data.critRate = foundCritRate
                data.critDmg = foundCritDmg
                var msg = "讀取成功！\n爆率: \(data.critRate)% | 爆傷: \(data.critDmg)%"
                if mainStatFound { msg += "\n(偵測到雙爆主詞條，已排除)" }
                data.aiComment = msg
            }
        }
        request.recognitionLanguages = ["zh-Hant", "en-US"]
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async { try? handler.perform([request]) }
    }
    
    func extractValue(from text: String) -> Double? {
        let pattern = "[0-9]+\\.?[0-9]*"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return Double(String(text[range]))
        }
        return nil
    }
    
    func analyzeArtifact() async {
        data.isAnalyzing = true
        data.score = 0
        let finalScore = (data.critRate * 2) + data.critDmg
        withAnimation(.easeOut(duration: 1.0)) { data.score = finalScore }
        if finalScore >= 40 { confettiCounter += 1 }
        
        let session = LanguageModelSession()
        let prompt = "請用\(judgeCharacter)語氣評鑑\(data.slotName)，數值：爆率\(data.critRate)%，爆傷\(data.critDmg)%，CV\(finalScore)。請給80字內短評。"
        do {
            data.aiComment = ""
            let response = try await session.respond(to: prompt)
            for char in response.content {
                data.aiComment.append(char)
                try? await Task.sleep(nanoseconds: 30_000_000)
            }
        } catch { data.aiComment = "連線失敗" }
        data.isAnalyzing = false
    }
}

#Preview {
    ArtifactScannerView().environmentObject(SharedDataModel())
}
