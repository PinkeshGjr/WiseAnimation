import SwiftUI

struct GlassShape: Shape {
    var bottomWidthRatio: CGFloat = 0.82
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // A simple tapered glass tumbler
        let topW = w
        let botW = w * bottomWidthRatio
        let r: CGFloat = cornerRadius
        
        // Top left lip
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top right lip
        path.addLine(to: CGPoint(x: topW, y: 0))
        
        // Right side going down (tapered)
        path.addLine(to: CGPoint(x: w - (w - botW) / 2, y: h - r))
        
        // Bottom right corner
        path.addQuadCurve(to: CGPoint(x: w - (w - botW) / 2 - r, y: h),
                          control: CGPoint(x: w - (w - botW) / 2, y: h))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: (w - botW) / 2 + r, y: h))
        
        // Bottom left corner
        path.addQuadCurve(to: CGPoint(x: (w - botW) / 2, y: h - r),
                          control: CGPoint(x: (w - botW) / 2, y: h))
        
        // Left side going up (tapered)
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.closeSubpath()
        return path
    }
}

struct GlassFrontShape: Shape {
    var rimH: CGFloat
    var bottomWidthRatio: CGFloat = 0.82
    var cornerRadius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let topW = w
        let botW = w * bottomWidthRatio
        let r: CGFloat = cornerRadius
        
        // Start top left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Curve along the bottom lip of the glass opening!
        let controlY = (rimH / 2.0) * (4.0 / 3.0) // Perfect cubic bezier approximation for a half ellipse arc
        path.addCurve(to: CGPoint(x: topW, y: 0),
                      control1: CGPoint(x: 0, y: controlY),
                      control2: CGPoint(x: topW, y: controlY))
        
        // Right side going down
        path.addLine(to: CGPoint(x: w - (w - botW) / 2, y: h - r))
        
        // Bottom right corner
        path.addQuadCurve(to: CGPoint(x: w - (w - botW) / 2 - r, y: h),
                          control: CGPoint(x: w - (w - botW) / 2, y: h))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: (w - botW) / 2 + r, y: h))
        
        // Bottom left corner
        path.addQuadCurve(to: CGPoint(x: (w - botW) / 2, y: h - r),
                          control: CGPoint(x: (w - botW) / 2, y: h))
        
        // Left side going up
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.closeSubpath()
        return path
    }
}
