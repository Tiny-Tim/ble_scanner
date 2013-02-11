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

// 20 points for left margin pad when setting origin of graph
#define GRAPH_LEFT_MARGIN 20

@interface BLEGraphView()

// location within frame of the graph's origin
@property (nonatomic) CGPoint graphOrigin;

// graphScale corresponding to the number of frame points per graph function value
@property (nonatomic) CGFloat graphScale;

@end

@implementation BLEGraphView

@synthesize graphOrigin = _graphOrigin;

@synthesize graphScale = _graphScale;


#pragma mark- Properties
/*
 *
 * Method Name:  maxDataPoints
 *
 * Description:  The maximum number of data points to be shown on screen at one time. This represents the visible accelerometer history which is nominally 100 points sampled at 10 hz.
 *
 * Parameter(s): 
 *
 */
-(NSUInteger)maxDataPoints
{
    // protect against 0 value
    if (_maxDataPoints == 0)
    {
        // error prevention to avoid a divide by 0 error if dat not specified.
        _maxDataPoints = 100;
    }
    
    return _maxDataPoints;
}



// Acceleration data to be plotted. Each element in the array contains an object with three values corresponding to the three axial acceleration components.
-(void)setAccelerationData:(NSArray *)accelerationData
{
    _accelerationData = accelerationData;
    
    [self setNeedsDisplay];
}

// Lazy initializer for graph origin which is centered vertically and offset from left edge by a specified margin amount.
-(CGPoint) graphOrigin
{

    if ( (_graphOrigin.x == 0) && (_graphOrigin.y == 0) )
    {
        // set the graph origin near the left edge and centered vertically in the view
        CGPoint origin;
        
        origin.x = self.bounds.origin.x + GRAPH_LEFT_MARGIN;
       
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
        // request redraw
        [self setNeedsDisplay];
    }
}   


// Get the scale factor
-(CGFloat)graphScale
{
    if (! _graphScale)
    {
        // divide the number of points in bounds.size.width (minus margin) by the max number of data points to be displayed at once.
       
        _graphScale = (self.bounds.size.width - GRAPH_LEFT_MARGIN) / self.maxDataPoints;
        
        [self setNeedsDisplay];
    }
    
    return _graphScale;
    
}


// Set the scale factor
- (void)setGraphScale:(CGFloat)scale
{
    if (scale != _graphScale)
    {
        _graphScale = scale;
        
        [self setNeedsDisplay];
    }
}


#pragma mark- Controller Lifecycle

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


#pragma mark- Private helper methods


/*
 *
 * Method Name:  translateGraphToViewCoordinates
 *
 * Description:  scales the accelerometer data to be plotted in view coordinates
 *
 * Parameter(s): graphValue - point to be plotted
 *
 */
- (CGPoint) translateGraphToViewCoordinates:(CGPoint)graphValue
{
    CGPoint viewPoint;
    
    viewPoint.x = self.graphScale * graphValue.x + self.graphOrigin.x;
    viewPoint.y = 25 * self.graphScale * graphValue.y + self.graphOrigin.y;
    
    return viewPoint;
}


/*
 *
 * Method Name:  plotFunction 
 *
 * Description:  Plots the provided axial accelerometer component data using different colors for each component.
 *
 * Parameter(s): component - index signifying which component is being plotted
 *               context - graphical context to plot in
 *
 */
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




/*
 *
 * Method Name:  drawRect
 *
 * Description:  draws the plot of the three acceleromter components
 *
 * Parameter(s): none
 *
 */
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
        // do the plotting
        [self plotFunction:component usingContext:context];
    }
    
    // restore context
    UIGraphicsPopContext();
}


@end
