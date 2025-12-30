import SwiftUI
import FoundationModels
import TipKit
import Kingfisher
import Zoomable

// 提示 1: 告訴使用者圖片可以點擊放大
struct BossImageTip: Tip {
    var title: Text { Text("查看弱點細節") }
    var message: Text? { Text("點擊 Boss 頭像可進入全螢幕模式，並支援雙指縮放查看模型細節。") }
    var image: Image? { Image(systemName: "plus.magnifyingglass") }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1),
            Tips.IgnoresDisplayFrequency(true)
        ]
    }
}

// 提示 2: 引導使用者開始模擬
struct SimulateTip: Tip {
    var title: Text { Text("啟動戰術推演") }
    var message: Text? { Text("資料讀取完畢後，點擊此處讓 AI 根據你的角色與聖遺物數據，分析最佳攻略法。") }
    var image: Image? { Image(systemName: "brain.head.profile") }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1),
            Tips.IgnoresDisplayFrequency(true)
        ]
    }
}

struct GenshinData: Codable {
    let enemies: [Enemy]
}

struct Enemy: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let element: String
    let description: String
    let imageUrl: String?
    let resistances: Resistances
    
    enum CodingKeys: String, CodingKey {
        case id, name, element, description, resistances
        case imageUrl = "image_url"
    }
    
    static func == (lhs: Enemy, rhs: Enemy) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Resistances: Codable {
    let physical: Double
    let pyro: Double
    let hydro: Double
    let dendro: Double
    let electro: Double
    let anemo: Double
    let cryo: Double
    let geo: Double
}

struct TacticalSimView: View {
    @EnvironmentObject var sharedData: SharedDataModel
    
    @State private var enemies: [Enemy] = []
    @State private var selectedBoss: Enemy?
    @State private var targetTime: Double = 90
    
    @State private var aiAnalysis: String = ""
    @State private var isAnalyzing: Bool = false
    @State private var isLoadingData: Bool = false
    
    @State private var session = LanguageModelSession()
    @State private var showImageViewer = false
    
    @State private var fullscreenBoss: Enemy? = nil
    
    let bossImageTip = BossImageTip()
    let simulateTip = SimulateTip()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景：深色科技感
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame(.horizontal)
                    .ignoresSafeArea()
                    .overlay(.black.opacity(0.25))
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 15) {
                            Text("虛空資料庫")
                                .font(.headline).foregroundStyle(.cyan)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if enemies.isEmpty {
                                ContentUnavailableView("尚無敵情數據", systemImage: "wifi.slash")
                                    .foregroundStyle(.gray)
                                
                                Button { Task { await fetchEnemyData() } } label: {
                                    HStack {
                                        if isLoadingData { ProgressView().tint(.black) }
                                        Text(isLoadingData ? "下載中..." : "連線至世界樹")
                                    }
                                    .fontWeight(.bold).padding().frame(maxWidth: .infinity)
                                    .background(.cyan).foregroundStyle(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            } else {
                                Menu {
                                    ForEach(enemies) { enemy in
                                        Button(enemy.name) { withAnimation { selectedBoss = enemy } }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedBoss?.name ?? "請選擇討伐對象").font(.title3.bold())
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.cyan.opacity(0.5), lineWidth: 1))
                                }
                                .foregroundStyle(.white)
                            }
                        }
                        .padding().background(.black.opacity(0.4)).clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        if let boss = selectedBoss {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(alignment: .top, spacing: 15) {
                                    Button {
                                        fullscreenBoss = boss // 設定要放大的 Boss
                                        showImageViewer = true // 開啟全螢幕
                                        bossImageTip.invalidate(reason: .actionPerformed)
                                    } label: {
                                        KFImage(URL(string: boss.imageUrl ?? ""))
                                            .placeholder { Image(systemName: "photo.circle").font(.largeTitle).foregroundStyle(.gray) }
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(.cyan, lineWidth: 2))
                                            .shadow(radius: 5)
                                            .overlay(alignment: .bottomTrailing) {
                                                Image(systemName: "magnifyingglass.circle.fill")
                                                    .foregroundStyle(.white, .blue)
                                                    .font(.title3)
                                                    .offset(x: 5, y: 5)
                                            }
                                    }
                                    .popoverTip(bossImageTip, arrowEdge: .bottom)
                                    VStack(alignment: .leading) {
                                        Text("目標分析：\(boss.name)").font(.title2.bold()).foregroundStyle(.white)
                                        Text(boss.element).font(.caption).padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(.orange.opacity(0.8)).clipShape(Capsule()).foregroundStyle(.white)
                                    }
                                    Spacer()
                                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange).font(.title2)
                                }
                                Text(boss.description).font(.footnote).foregroundStyle(.gray)
                                Divider().background(.gray)
                                Text("抗性掃描 (Resistance Scan)").font(.caption).bold().foregroundStyle(.cyan)
                                
                                // 抗性條 (這裡只列出幾個範例)
                                VStack(spacing: 8) {
                                    ResistanceRow(name: "物理", value: boss.resistances.physical, color: .gray)
                                    // 四大元素
                                    ResistanceRow(name: "火元素", value: boss.resistances.pyro, color: .red)
                                    ResistanceRow(name: "水元素", value: boss.resistances.hydro, color: .blue)
                                    ResistanceRow(name: "冰元素", value: boss.resistances.cryo, color: .cyan)
                                    ResistanceRow(name: "雷元素", value: boss.resistances.electro, color: .purple)
                                    
                                    // 特殊元素
                                    ResistanceRow(name: "風元素", value: boss.resistances.anemo, color: .mint)
                                    ResistanceRow(name: "岩元素", value: boss.resistances.geo, color: .yellow)
                                    ResistanceRow(name: "草元素", value: boss.resistances.dendro, color: .green)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(.black.opacity(0.6)).stroke(.cyan.opacity(0.3), lineWidth: 1))
                        }
                        
                        // MARK: - C. 我方戰力分析 (讀取 SharedData)
                        VStack(alignment: .leading, spacing: 20) {
                            Text("我方戰力配置 (Loaded from Tab 1 & 2)")
                                .font(.headline).foregroundStyle(.green)
                            
                            HStack(alignment: .top, spacing: 20) {
                                // 左側：角色資訊 (Tab 1)
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("出戰角色", systemImage: "person.fill").font(.caption).foregroundStyle(.gray)
                                    Text(sharedData.characterName.isEmpty ? "未命名" : sharedData.characterName)
                                        .font(.title2.bold()).foregroundStyle(.white)
                                    
                                    HStack {
                                        Text(sharedData.selectedElement)
                                            .font(.caption).padding(4).background(.green.opacity(0.2)).cornerRadius(4)
                                        Text(sharedData.selectedWeapon)
                                            .font(.caption).padding(4).background(.gray.opacity(0.2)).cornerRadius(4)
                                    }
                                    .foregroundStyle(.white)
                                }
                                
                                Divider().background(.gray)
                                
                                // 右側：聖遺物總和 (Tab 2)
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("聖遺物面板", systemImage: "chart.bar.fill").font(.caption).foregroundStyle(.gray)
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("總爆率").font(.caption2).foregroundStyle(.yellow)
                                            Text("\(sharedData.totalCritRate, specifier: "%.1f")%")
                                                .font(.headline).foregroundStyle(.white).bold()
                                        }
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("總爆傷").font(.caption2).foregroundStyle(.yellow)
                                            Text("\(sharedData.totalCritDmg, specifier: "%.1f")%")
                                                .font(.headline).foregroundStyle(.white).bold()
                                        }
                                    }
                                }
                            }
                            
                            Divider().background(.gray.opacity(0.5))
                            
                            // 目標時間設定 (已移除日期選擇)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("目標通關時間").foregroundStyle(.white)
                                    Spacer()
                                    Text("\(Int(targetTime)) 秒").foregroundStyle(.yellow).bold()
                                }
                                Slider(value: $targetTime, in: 30...180, step: 10).tint(.green)
                            }
                        }
                        .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // MARK: - D. 戰術模擬 (AI)
                        VStack(spacing: 15) {
                            Button {
                                Task { await runSimulation() }
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text(isAnalyzing ? "正在推演戰局..." : "啟動戰術模擬 (Simulate)")
                                }
                                .font(.headline).foregroundStyle(.black).padding().frame(maxWidth: .infinity)
                                .background(isAnalyzing ? .gray : (sharedData.isReadyForSim && selectedBoss != nil ? .green : .gray.opacity(0.5)))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(selectedBoss == nil || isAnalyzing || !sharedData.isReadyForSim)
                            .popoverTip(simulateTip)
                            
                            // 提示訊息
                            if !sharedData.isReadyForSim {
                                Text("⚠️ 請先至 Tab 1 設定名字 並於 Tab 2 掃描聖遺物")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            
                            // 終端機輸出
                            if !aiAnalysis.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle().fill(.red).frame(width: 10)
                                        Circle().fill(.yellow).frame(width: 10)
                                        Circle().fill(.green).frame(width: 10)
                                        Spacer()
                                        Text("TERMINAL_OUTPUT").font(.caption).fontDesign(.monospaced).foregroundStyle(.gray)
                                    }
                                    Divider().background(.gray)
                                    Text(aiAnalysis)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(.green)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding().background(.black).clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.green.opacity(0.5), lineWidth: 1))
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("戰術模擬")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $fullscreenBoss) { boss in
                ZStack(alignment: .topTrailing) {
                    // 1. 黑色背景
                    Color.black.ignoresSafeArea()
                    
                    // 2. 圖片處理
                    if let urlString = boss.imageUrl, let url = URL(string: urlString) {
                        KFImage(url)
                            .placeholder {
                                VStack {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.5)
                                    Text("讀取影像中...")
                                        .foregroundStyle(.gray)
                                        .font(.caption)
                                }
                            }
                            .onFailure { error in
                                print("圖片讀取失敗: \(error)")
                            }
                            .resizable()
                            .scaledToFit()
                            .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 3.0) // 縮放功能
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // 如果沒有網址，顯示提示
                        ContentUnavailableView("無圖片資料", systemImage: "photo.slash")
                            .foregroundStyle(.white)
                    }
                    
                    // 3. 關閉按鈕 (X)
                    Button {
                        fullscreenBoss = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding()
                            .padding(.top, 40)
                    }
                }
                // 確保背景是黑色的
                .presentationBackground(.black)
            }
        }
    }
    
    func fetchEnemyData() async {
        isLoadingData = true
        let urlString = "https://raw.githubusercontent.com/Aaron0626/GeshinData/refs/heads/main/genshin_data.json"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(GenshinData.self, from: data)
            self.enemies = result.enemies
            self.selectedBoss = result.enemies.first
        } catch { aiAnalysis = "連線錯誤：\(error.localizedDescription)" }
        isLoadingData = false
    }
    
    func runSimulation() async {
        guard let boss = selectedBoss else { return }
        isAnalyzing = true
        aiAnalysis = "> Initializing combat simulation...\n> Loading character data...\n> Loading artifact stats...\n"
        
        // 模擬讀取時間
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let prompt = """
        扮演原神戰術AI。
        
        【敵方情報】
        - 名稱：\(boss.name)
        - 抗性：物理\(boss.resistances.physical)%, 火\(boss.resistances.pyro)%, 水\(boss.resistances.hydro)%
        
        【我方情報 (來自使用者設定)】
        - 角色：\(sharedData.characterName) (元素：\(sharedData.selectedElement), 武器：\(sharedData.selectedWeapon))
        - 聖遺物總面板：爆擊率 \(String(format: "%.1f", sharedData.totalCritRate))%, 爆擊傷害 \(String(format: "%.1f", sharedData.totalCritDmg))%
        - 目標時間：\(Int(targetTime))秒
        
        請用「軍事報告」的口吻，繁體中文輸出：
        1. [戰力評估]：根據雙爆面板評價輸出能力 (例如：爆率過低建議提升)。
        2. [勝率分析]：考慮屬性剋制與面板數據。
        3. [戰術建議]：針對 Boss 抗性弱點的打法。
        """
        
        do {
            let response = try await session.respond(to: prompt)
            let fullText = response.content
            
            for char in fullText {
                aiAnalysis.append(char)
                try? await Task.sleep(nanoseconds: 20_000_000)
            }
        } catch { aiAnalysis = "Error: 運算模組故障。" }
        isAnalyzing = false
    }
}

// 輔助視圖：抗性條 (維持不變)
struct ResistanceRow: View {
    let name: String
    let value: Double
    let color: Color
    
    var percentage: Int {
        Int(value * 100)
    }
    
    var resistanceLevel: (color: Color, icon: String) {
        if value >= 0.99 { return (.red, "🚫") } // 免疫
        if value >= 0.5 { return (.orange, "⚠️") } // 高抗
        if value <= 0.1 { return (.green, "🟢") } // 弱點
        return (.gray, "") // 普通
    }
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: 50, alignment: .leading)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.1))
                    .frame(height: 8)
                Capsule()
                    .fill(resistanceLevel.color)
                    .frame(width: CGFloat(min(value * 1.5, 1.0)) * 150, height: 8)
            }
            HStack(spacing: 2) {
                if value >= 0.99 {
                    Text("免疫")
                        .font(.caption).bold()
                        .foregroundStyle(.red)
                } else {
                    Text("\(percentage)%")
                        .font(.caption).bold()
                        // 數值顏色跟著抗性等級變
                        .foregroundStyle(resistanceLevel.color)
                }
                
                // 狀態 Icon (例如 ⚠️)
                if !resistanceLevel.icon.isEmpty {
                    Text(resistanceLevel.icon)
                        .font(.caption2)
                }
            }
        }
    }
}

#Preview{
    TacticalSimView()
        .environmentObject(SharedDataModel())
}
