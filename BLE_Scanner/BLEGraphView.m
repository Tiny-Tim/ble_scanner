//
//  BLEGraphView.m
//  BLE_Scanner
//
//  Created by Chip Keyes on 2/10/13.
//  Copyright (c) 2013 Chip Keyes. All rights reserved.
//

#import "BLEGraphView.h"
#import "AxesDrawer.h"
#import "BLEAcclerometerValue.h"


@interface BLEGraphView()

@property (nonatomic) CGPoint graphOrigin;

@property (nonatomic) CGFloat graphScale;

@end

@implementation BLEGraphView

@synthesize graphOrigin = _graphOrigin;

@synthesize graphScale = _graphScale;

  

-(void)setAccelerationData:(NSArray *)accelerationData
{
    _accelerationData = accelerationData;
    
    [self setNeedsDisplay];
}

// Get the grqph origin coordinates
-(CGPoint) graphOrigin
{

    if ( (_graphOrigin.x == 0) && (_graphOrigin.y == 0) )
    {
        // set the graph origin 20 points from left edge and centered vertically
        // in the center of the view
        CGPoint origin;
        // content scale factor is the number of pixels representing each point (noramlly 1.0 or 2.0)
        origin.x = self.bounds.origin.x + 20;
       
        origin.y = self.bounds.origin.y + self.bounds.size.height/2;
        _graphOrigin = origin;
        
        return _graphOrigin;
    }
    else
    {
        return _graphOrigin;
    }
}


// Set the graph origin coordinates
- (void)setGraphOrigin:(CGPoint)graphOrigin
{
    BOOL needsRedraw = NO;
    
    if (graphOrigin.x != _graphOrigin.x)
    {
        _graphOrigin.x = graphOrigin.x;
        needsRedraw = YES;
    }
    
    if (graphOrigin.y != _graphOrigin.y)
    {
        _graphOrigin.y = graphOrigin.y;
        needsRedraw = YES;
    }
    
    if (needsRedraw)
    {
        // Ask the delegate to store the scale
    //    [self.dataSource storeOriginInUserDefaults:_graphOrigin];
        
        // request redraw
        [self setNeedsDisplay];
    }
    
    
}   


// Get the scale factor
-(CGFloat)graphScale
{
    if (! _graphScale)
    {
        // points per graph unit
        return 3;
    }
    else
    {
        return _graphScale;
    }
}


// Set the scale factor
- (void)setGraphScale:(CGFloat)scale
{
    if (scale != _graphScale)
    {
        _graphScale = scale;
        
        // Ask the delegate to store the scale
     //   [self.dataSource storeScaleInUserDefaults:_scale];
        
        [self setNeedsDisplay];
    }
}



-(void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}


-(void)awakeFromNib
{
    [self setup];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


- (CGPoint) translateGraphToViewCoordinates:(CGPoint)graphValue
{
    CGPoint viewPoint;
    
    viewPoint.x = self.graphScale * graphValue.x + self.graphOrigin.x;
    viewPoint.y = 25 * self.graphScale * graphValue.y + self.graphOrigin.y;
    
    return viewPoint;
}


-(void) plotFunction: (NSUInteger)component usingContext:(CGContextRef)context
{
    BOOL firstPoint = YES;
    UIColor *strokeColor;
    
    // set the stroke color
    if (component == 0)
    {
        // X axis accelerometer color
        strokeColor = [UIColor redColor];
    }
    else if (component == 1)
    {
        // Y axis accelerometer color
        strokeColor = [UIColor greenColor];
    }
    else if (component == 2)
    {
        // Z axis accelerometer color
        strokeColor = [UIColor blueColor];
    }
    else
    {
        // should never reach here
        strokeColor = [UIColor blackColor];
    }
    
    [strokeColor setStroke];
    
    for (int i=0; i< [self.accelerationData count]; i++)
    {
        CGPoint plotValue;
        
        // X value represents the sample number of the acceleration data
        plotValue.x = i;
        
        BLEAcclerometerValue *accel_data = self.accelerationData[i];
        switch (component)
        {
            // X axis accelerometer value
            case 0:
                plotValue.y = -accel_data.xAxisValue;
                break;
                
             // Y axis accelerometer value
            case 1:
                 plotValue.y = -accel_data.yAxisValue;
                break;
            // Z axis accelerometer value
            case 2:
                plotValue.y = -accel_data.zAxisValue;
                break;
                
            default:
                // unreachable
                break;
        }
        
        CGPoint viewCoordinatePoint = [self translateGraphToViewCoordinates:plotValue];
        
        if (firstPoint)
        {
            CGContextMoveToPoint(context, viewCoordinatePoint.x, viewCoordinatePoint.y);
            firstPoint = NO;
        }
        
        CGContextAddLineToPoint(context, viewCoordinatePoint.x, viewCoordinatePoint.y);
        
    }
    CGContextStrokePath(context);
}





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0);
    
    // draw axes
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.graphOrigin scale:self.graphScale];
    
    // Draw each accelerometer component a a function on the same graph
    for (NSUInteger component=0; component < 3; component++)
    {
       
        [self plotFunction:component usingContext:context];
    }
    
    UIGraphicsPopContext();
    
}


@end
