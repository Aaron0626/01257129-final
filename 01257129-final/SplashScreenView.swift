import SwiftUI
import FoundationModels

struct SplashScreenView: View {
    @Binding var isActive: Bool
    
    // --- 動畫狀態變數 ---
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var scanLineY: CGFloat = -200
    @State private var loadingPercent: Int = 0
    @State private var showAccessGranted = false
    
    // 系統日誌
    @State private var logs: [String] = []
    let fullLogs = [
        "BOOT_SEQUENCE_INIT...",
        "CONNECTING_TO_IRMINSUL_NODE_304...",
        "VERIFYING_DENDRO_SIG...",
        "DOWNLOADING_WISDOM_PACKETS...",
        "DECRYPTING_AKASHA_ARCHIVE...",
        "SYNC_COMPLETE."
    ]
    
    var body: some View {
        ZStack {
            // 1. 深淵黑背景
            Color.black.ignoresSafeArea()
            
            // 2. 背景：科技網格 + 掃描線
            ZStack {
                // 網格底圖
                GridBackground()
                    .opacity(0.2)
                
                // 掃描光線 (上下移動)
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.clear, .green.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 100)
                    .offset(y: scanLineY)
            }
            
            VStack(spacing: 40) {
                
                // 3. 核心視覺：旋轉光環 + Logo
                ZStack {
                    // 外層大環 (逆時針慢轉)
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 10]))
                        .foregroundStyle(.green.opacity(0.3))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-rotation))
                    
                    // 中層環 (順時針快轉)
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .foregroundStyle(.green)
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(rotation * 1.5))
                        .shadow(color: .green, radius: 10) // 螢光效果
                    
                    // 內層細環
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 5]))
                        .foregroundStyle(.green.opacity(0.6))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(rotation * 2))
                    
                    // 你的 Logo (核心)
                    Image(systemName: "leaf.fill") // 確保 Assets 裡有這張圖
                        .resizable()
                        .renderingMode(.template) // 允許染色
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.green)
                        .shadow(color: .green, radius: 20) // 強烈發光
                        .shadow(color: .white, radius: 5)  // 核心白光
                        .scaleEffect(scale) // 呼吸效果
                }
                .padding(.top, 50)
                
                // 4. 文字與數據區域
                VStack(spacing: 15) {
                    // 主標題
                    Text("虛空終端")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                        .shadow(color: .green, radius: 15)
                        .overlay(
                            Text("虛空終端")
                                .font(.system(size: 40, weight: .black, design: .monospaced))
                                .foregroundStyle(.green.opacity(0.5))
                                .offset(x: 2, y: 2) // 故障疊影效果
                        )
                    
                    Text("AKASHA SYSTEM TERMINAL")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green.opacity(0.7))
                        .tracking(8) // 字距拉寬
                    
                    // 進度條與數字
                    HStack {
                        Text("LOADING...")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(loadingPercent)%")
                            .font(.title3.bold())
                            .fontDesign(.monospaced)
                            .foregroundStyle(.green)
                    }
                    .frame(width: 200)
                    
                    // 實體進度條
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.green.opacity(0.2))
                            Rectangle().fill(Color.green)
                                .frame(width: geo.size.width * CGFloat(loadingPercent) / 100)
                                .shadow(color: .green, radius: 5)
                        }
                    }
                    .frame(width: 200, height: 4)
                    
                    // 系統日誌跑碼
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(logs, id: \.self) { log in
                            Text("> \(log)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.green.opacity(0.8))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(height: 80, alignment: .bottomLeading)
                    .frame(maxWidth: 300, alignment: .leading)
                    .clipped()
                }
            }
            .opacity(opacity) // 整體淡入
            
            // 5. 最後的「權限通過」閃光
            if showAccessGranted {
                Color.green
                    .blendMode(.screen)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                    Text("ACCESS GRANTED")
                        .font(.system(size: 40, weight: .heavy, design: .monospaced))
                        .foregroundStyle(.white)
                }
                .shadow(radius: 10)
            }
        }
        .onAppear {
            startSciFiAnimation()
        }
    }
    
    // MARK: - 動畫邏輯
    func startSciFiAnimation() {
        // 1. 基礎進場
        withAnimation(.easeOut(duration: 1.0)) {
            opacity = 1.0
        }
        
        // 2. 啟動無限循環動畫 (旋轉與呼吸)
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            scale = 1.1
        }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            scanLineY = 400 // 掃描線移動
        }
        
        // 3. 模擬數據載入 (0% -> 100%)
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            if loadingPercent < 100 {
                // 隨機跳動速度，看起來更像在運算
                loadingPercent += Int.random(in: 1...3)
                if loadingPercent > 100 { loadingPercent = 100 }
                
                // 觸覺回饋
                if loadingPercent % 10 == 0 {
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                }
            } else {
                timer.invalidate()
                finishSequence()
            }
        }
        
        // 4. 日誌逐行顯示
        var logIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            if logIndex < fullLogs.count {
                withAnimation {
                    logs.append(fullLogs[logIndex])
                    if logs.count > 5 { logs.removeFirst() }
                }
                logIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func finishSequence() {
        // 顯示最後的閃光與歡迎詞
        withAnimation(.easeInOut(duration: 0.2)) {
            showAccessGranted = true
        }
        
        // 震動
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // 延遲後切換到主頁
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                isActive = true
            }
        }
    }
}

// 輔助視圖：背景網格
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing: CGFloat = 40
                
                // 畫直線
                for i in 0...Int(width / spacing) {
                    path.move(to: CGPoint(x: CGFloat(i) * spacing, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * spacing, y: height))
                }
                // 畫橫線
                for i in 0...Int(height / spacing) {
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * spacing))
                    path.addLine(to: CGPoint(x: width, y: CGFloat(i) * spacing))
                }
            }
            .stroke(Color.green, lineWidth: 0.5)
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}
