import SwiftUI

enum MotionType: String, CaseIterable, Identifiable {
    case ripple = "Ripple"
    case diagonalWave = "Diagonal Wave"
    case radar = "Radar"
    
    var id: String { self.rawValue }
}

struct MotionPreview: View {
    var type: MotionType
    var hue: Double // 0.0 - 360.0
    var brightness: Double // 0.0 - 100.0
    
    @State private var startTime = Date()
    
    // Constants from Motion.cpp
    private let levels: Double = 12
    private let sigmaRipple: Double = 0.55
    private let spacingRipple: Double = 0.85
    private let ringsRipple: Int = 4
    private let speedRipple: Double = 0.14 / 0.02 // units per second (0.14 every 20ms)
    
    private let sigmaWave: Double = 0.8
    private let speedWave: Double = 0.18 / 0.02 // units per second (0.18 every 20ms)
    
    private let radarSpeed: Double = 2.5 / 0.02 // degrees per second (2.5 every 20ms)
    private let bwFIdle: Double = 0.8
    private let bwBIdle: Double = 0.05
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            Canvas { context, size in
                let cellSize = size.width / 8
                
                for y in 0..<8 {
                    for x in 0..<8 {
                        let color = calculateColor(x: x, y: y, elapsed: elapsed)
                        let rect = CGRect(
                            x: CGFloat(x) * cellSize,
                            y: CGFloat(y) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            startTime = Date()
        }
        // Reset animation on tap
        .onTapGesture {
            startTime = Date()
        }
    }
    
    private func calculateColor(x: Int, y: Int, elapsed: Double) -> Color {
        switch type {
        case .ripple:
            return calculateRipple(x: x, y: y, elapsed: elapsed)
        case .diagonalWave:
            return calculateDiagonalWave(x: x, y: y, elapsed: elapsed)
        case .radar:
            return calculateRadar(x: x, y: y, elapsed: elapsed)
        }
    }
    
    private func calculateRipple(x: Int, y: Int, elapsed: Double) -> Color {
        let cx = 3.5
        let cy = 3.5
        let dx = Double(x) - cx
        let dy = Double(y) - cy
        let dist = sqrt(dx*dx + dy*dy)
        
        let t = elapsed * speedRipple
        let maxDist = 4.95
        let period = maxDist + Double(ringsRipple - 1) * spacingRipple + 2.0 * sigmaRipple
        
        // Loop the animation for preview with a small pause
        let totalCycle = period + 1.0
        let loopT = t.truncatingRemainder(dividingBy: totalCycle)
        
        if loopT > period {
            return .black
        }
        
        var amp = 0.0
        for k in 0..<ringsRipple {
            let r = loopT - Double(k) * spacingRipple
            let d = dist - r
            amp += exp(-(d*d) / (2.0 * sigmaRipple * sigmaRipple))
        }
        amp = min(amp, 1.0)
        
        let stepped = floor(amp * levels) / levels
        let satf = max(0, min(1, 0.90 - 0.25 * (dist / 4.8)))
        
        let v = gamma8(stepped * 0.9)
        let b = v * (brightness / 100.0)
        
        return Color(hue: hue / 360.0, saturation: satf, brightness: b)
    }
    
    private func calculateDiagonalWave(x: Int, y: Int, elapsed: Double) -> Color {
        let center = 3.5
        let margin = 2.5
        let startLeft = -margin
        let startRight = 7.0 + margin
        let totalDist = (center + margin) * 2.0
        
        let t = elapsed * speedWave
        let totalCycle = totalDist + 1.0
        let loopT = t.truncatingRemainder(dividingBy: totalCycle)
        
        if loopT > totalDist {
            return .black
        }
        
        let posLeft = startLeft + loopT
        let posRight = startRight - loopT
        
        let fx = Double(x)
        let distL = fx - posLeft
        let ampL = exp(-(distL*distL) / (2.0 * sigmaWave * sigmaWave))
        
        let distR = fx - posRight
        let ampR = exp(-(distR*distR) / (2.0 * sigmaWave * sigmaWave))
        
        var amp = ampL + ampR
        amp = min(amp, 1.0)
        
        let stepped = floor(amp * levels) / levels
        let satf = max(0, min(1, 0.90 - 0.25 * amp))
        
        let v = gamma8(stepped * 0.9)
        let b = v * (brightness / 100.0)
        
        return Color(hue: hue / 360.0, saturation: satf, brightness: b)
    }
    
    private func calculateRadar(x: Int, y: Int, elapsed: Double) -> Color {
        let cx = 3.5
        let cy = 3.5
        let dx = Double(x) - cx
        let dy = Double(y) - cy
        let pr = atan2(dy, dx)
        
        let angleDeg = (elapsed * radarSpeed).truncatingRemainder(dividingBy: 360.0)
        let rad = angleDeg * .pi / 180.0
        
        var diff = rad - pr
        while diff > .pi { diff -= 2.0 * .pi }
        while diff < -.pi { diff += 2.0 * .pi }
        
        let bw = (diff > 0) ? bwFIdle : bwBIdle
        let br = exp(-(diff*diff) / (2.0 * bw * bw))
        
        if br > 0.05 {
            let v = gamma8(br)
            let b = v * (brightness / 100.0)
            return Color(hue: hue / 360.0, saturation: 1.0, brightness: b)
        } else {
            return .black
        }
    }
    
    private func gamma8(_ v01: Double) -> Double {
        let v = max(0, min(1, v01))
        return pow(v, 1.0 / 2.2)
    }
}

#Preview {
    VStack {
        MotionPreview(type: .ripple, hue: 74, brightness: 80)
            .frame(width: 200, height: 200)
            .background(Color.black)
        
        MotionPreview(type: .diagonalWave, hue: 212, brightness: 80)
            .frame(width: 200, height: 200)
            .background(Color.black)
            
        MotionPreview(type: .radar, hue: 90, brightness: 80)
            .frame(width: 200, height: 200)
            .background(Color.black)
    }
    .padding()
}
