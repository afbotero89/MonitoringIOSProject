//
//  BWCircularSlider.swift
//  TB_CustomControlsSwift
//
//  Created by Yari D'areglia on 03/11/14.
//  Copyright (c) 2014 Yari D'areglia. All rights reserved.
//

import UIKit

struct Config {
    
    static let TB_SLIDER_SIZE:CGFloat = UIScreen.main.bounds.size.width
    static let TB_SAFEAREA_PADDING:CGFloat = 60.0
    static let TB_LINE_WIDTH:CGFloat = 40.0
    static let TB_FONTSIZE:CGFloat = 20.0
    
}


// MARK: Math Helpers 

func DegreesToRadians (_ value:Double) -> Double {
    return value * M_PI /   180.0
}

func RadiansToDegrees (_ value:Double) -> Double {
    return value * 180.0 / M_PI
}

func Square (_ value:CGFloat) -> CGFloat {
    return value * value
}


// MARK: Circular Slider

class BWCircularSlider: UIControl {

    var textField:UITextField?
    var radius:CGFloat = 0
    var angle:Int!
    var startColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
    var endColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
    
    // Custom initializer
    convenience init(startColor:UIColor, endColor:UIColor, frame:CGRect){
        self.init(frame: frame)
        
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - Config.TB_SAFEAREA_PADDING
        
        //Define the Font
        let font = UIFont(name: "Avenir", size: Config.TB_FONTSIZE)
        //Calculate font size needed to display 3 numbers
        let str = "000" as NSString
        let fontSize:CGSize = str.size(attributes: [NSFontAttributeName:font!])
        
        //Using a TextField area we can easily modify the control to get user input from this field
        let textFieldRect = CGRect(
            x: (frame.size.width  - fontSize.width) / 2.2,
            y: (frame.size.height - fontSize.height) / 2.0,
            width: fontSize.width + 40, height: fontSize.height);
        
        textField = UITextField(frame: textFieldRect)
        textField?.backgroundColor = UIColor.clear
        textField?.textColor = UIColor.black
        textField?.textAlignment = .center
        textField?.font = font
        if UserSelectedConfiguration.userSelectMeasurementTime == nil{
            angle = 3
            UserSelectedConfiguration.userSelectMeasurementTime = 3
        }
        angle = UserSelectedConfiguration.userSelectMeasurementTime*6
        textField?.text = "\(UserSelectedConfiguration.userSelectMeasurementTime!) min"
        UserSelectedConfiguration.userSelectMeasurementTime = self.angle/6
        addSubview(textField!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        return true
    }
    
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let lastPoint = touch.location(in: self)
        
        self.moveHandle(lastPoint)
        
        self.sendActions(for: UIControlEvents.valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }
    
    
    
    
    //Use the draw rect to draw the Background, the Circle and the Handle
    override func draw(_ rect: CGRect){
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        /** Draw the Background **/
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let startAngle :CGFloat = 0.0
        let endAngle = 2*CGFloat.pi
        let strokeWidth:CGFloat = 1.0
        let center = CGPoint(x: self.frame.midX, y: self.frame.size.height/2)
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(strokeWidth)
        context.setFillColor(UIColor.clear.cgColor)
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngle), clockwise: false)
        
        //CGContextAddArc(ctx, CGFloat(self.frame.size.width / 2.0), CGFloat(self.frame.size.height / 2.0), radius, 0, CGFloat(M_PI * 2), 0)
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).set()
        
        ctx?.setLineWidth(72)
        ctx?.setLineCap(CGLineCap.butt)
        
        ctx?.drawPath(using: CGPathDrawingMode.stroke)
        
        
        /** Draw the circle **/
        
        /** Create THE MASK Image **/
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width,height: self.bounds.size.height));
        let imageCtx = UIGraphicsGetCurrentContext()
        //CGContextAddArc(imageCtx, CGFloat(self.frame.size.width/2)  , CGFloat(self.frame.size.height/2), radius, 0, CGFloat(DegreesToRadians(Double(angle))) , 0);
        UIColor.red.set()
        
        //Use shadow to create the Blur effect
        imageCtx?.setShadow(offset: CGSize(width: 0, height: 0), blur: CGFloat(angle/15), color: UIColor.black.cgColor);
       
        //define the path
        imageCtx?.setLineWidth(Config.TB_LINE_WIDTH)
        imageCtx?.drawPath(using: CGPathDrawingMode.stroke)
        
        //save the context content into the image mask
        let mask:CGImage = UIGraphicsGetCurrentContext()!.makeImage()!;
        UIGraphicsEndImageContext();
        
        /** Clip Context to the mask **/
        ctx?.saveGState()
        
        ctx?.clip(to: self.bounds, mask: mask)
        
        
        /** The Gradient **/
        
        // Split colors in components (rgba)
        
        let startColorComps:[CGFloat] = startColor.cgColor.components!;
        let endColorComps:[CGFloat] = endColor.cgColor.components!;

        let components : [CGFloat] = [
            startColorComps[0], startColorComps[1], startColorComps[2], 1.0,     // Start color
            endColorComps[0], endColorComps[1], endColorComps[2], 1.0      // End color
        ]
        
        // Setup the gradient
        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: baseSpace, colorComponents: components, locations: nil, count: 2)

        // Gradient direction
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)
        
        // Draw the gradient
        ctx?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: []);
        ctx?.restoreGState();
        
        /* Draw the handle */
        drawTheHandle(ctx!)

    }
    
    
    
    /** Draw a white knob over the circle **/
    
    func drawTheHandle(_ ctx:CGContext){
        
        ctx.saveGState();
        
        //I Love shadows
        ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 3, color: UIColor.black.cgColor);
        
        //Get the handle position
        let handleCenter = pointFromAngle(angle)
        
        //Draw It!
        UIColor(white:1.0, alpha:0.7).set();
        ctx.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: Config.TB_LINE_WIDTH, height: Config.TB_LINE_WIDTH));
        
        ctx.restoreGState();
    }
    
    
    
    /** Move the Handle **/

    func moveHandle(_ lastPoint:CGPoint){
        
        //Get the center
        let centerPoint:CGPoint  = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
        //Calculate the direction from a center point and a arbitrary position.
        let currentAngle:Double = AngleFromNorth(centerPoint, p2: lastPoint, flipped: false);
        let angleInt = Int(floor(currentAngle))
        
        //Store the new angle
        angle = Int(360 - angleInt)
        
        if angle/6 <= 2{
            angle = 18
        }
        
        //Update the textfield
        textField!.text = "\(angle/6) min"
        UserSelectedConfiguration.userSelectMeasurementTime = self.angle/6
        
        //Redraw
        setNeedsDisplay()
    }
    
    /** Given the angle, get the point position on circumference **/
    func pointFromAngle(_ angleInt:Int)->CGPoint{
    
        //Circle center
        let centerPoint = CGPoint(x: self.frame.size.width/2.0 - Config.TB_LINE_WIDTH/2.0, y: self.frame.size.height/2.0 - Config.TB_LINE_WIDTH/2.0);

        //The point position on the circumference
        var result:CGPoint = CGPoint.zero
        let y = round(Double(radius) * sin(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.y)
        let x = round(Double(radius) * cos(DegreesToRadians(Double(-angleInt)))) + Double(centerPoint.x)
        result.y = CGFloat(y)
        result.x = CGFloat(x)
            
        return result;
    }
    
    
    //Sourcecode from Apple example clockControl
    //Calculate the direction in degrees from a center point to an arbitrary position.
    func AngleFromNorth(_ p1:CGPoint , p2:CGPoint , flipped:Bool) -> Double {
        var v:CGPoint  = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag:CGFloat = Square(Square(v.x) + Square(v.y))
        var result:Double = 0.0
        v.x /= vmag;
        v.y /= vmag;
        let radians = Double(atan2(v.y,v.x))
        result = RadiansToDegrees(radians)
        return (result >= 0  ? result : result + 360.0);
    }

}
