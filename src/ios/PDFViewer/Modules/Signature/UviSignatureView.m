//
//  CustomSignatureView.m
//  UviGLSignature
//
//  Created by Vignesh on 2/10/16.
//  Copyright © 2016 vigneshuvi. All rights reserved.
//

#import "UviSignatureView.h"
#import <QuartzCore/QuartzCore.h>

#define USER_SIGNATURE_PATH  @"user_signature_path"
#define TEMP_SIGNATURE @"radaee_signature_temp.png"

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

@implementation UviSignatureView

// Initial the Siganture view based on the aDecoder.
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) [self initialize];
    return self;
}

// Initial the Siganture view based on the frame.
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initialize];
    return self;
}

- (void)clean
{
    
}

- (void)initialize {
    
    signPath = [UIBezierPath bezierPath];
    [signPath setLineWidth:2.0];            // Configurate the line Width
    [signPath setLineCapStyle:kCGLineCapRound];
    [signPath setLineJoinStyle:kCGLineJoinRound];
    
    // Added the Tap Reconginzer for capture the touches
    UITapGestureRecognizer *tapReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReconizer:)];
     [tapReconizer setNumberOfTouchesRequired : 1];
     [tapReconizer setNumberOfTapsRequired: 1];
    [self addGestureRecognizer:tapReconizer];
    
    // Added the Pan Reconginzer for capture the touches
    UIPanGestureRecognizer *panReconizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panReconizer:)];
    panReconizer.maximumNumberOfTouches = panReconizer.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panReconizer];
    
    // Erase when long press the view.
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(erase)]];
    
    // Erase when long press view.
    UILongPressGestureRecognizer *longReconizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(erase)];
    [self addGestureRecognizer:longReconizer];
    
    // Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(erase) name:@"shake" object:nil];
    
}

- (void)captureSignature {
    [_pathArray addObject:signPath];
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:_pathArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:saveData forKey:USER_SIGNATURE_PATH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)signatureImage:(CGPoint)position text:(NSString*)text fitSignature:(BOOL)fitSignature {
    
    CGRect bounds = self.bounds;
    
    if(fitSignature) {
        bounds = signPath.bounds;
        bounds.size.width += (self.lineWidth * 2);
        bounds.size.height += (self.lineWidth * 2);
    }
        
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (fitSignature) {
        // translate matrix so that path will be centered in bounds
        CGContextTranslateCTM(context, -(signPath.bounds.origin.x - self.lineWidth), -(signPath.bounds.origin.y - self.lineWidth));
    }

    [self.lineColor setStroke];
    [signPath stroke];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];

    // Save image.
    [UIImagePNGRepresentation(resultImage) writeToFile:filePath atomically:YES];
    
    UIGraphicsEndImageContext();
}

- (UIColor *)lineColor {
    if (_lineColor == nil) {
        _lineColor = [UIColor blackColor];
    }
    return _lineColor;
}

- (CGFloat)lineWidth {
    if (_lineWidth == 0) {
        _lineWidth = 1;
    }
    return _lineWidth;
}

- (NSMutableArray *)pathArray {
    if (_pathArray == nil) {
        _pathArray = [NSMutableArray new];
    }
    return _pathArray;
}

- (CGPoint)placeholderPoint {
    CGFloat height = self.bounds.size.height;
    
    CGFloat bottom = 0.90;
    
    CGFloat x1 = 0;
    
    CGFloat y1 = height*bottom;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    return (CGPoint){x1, y1 - 5 - font.pointSize + font.descender};
}

- (NSArray *)backgroundLines {
    if (backgroundLines == nil) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGFloat bottom = 0.90;
        {
            CGFloat x1 = 0;
            CGFloat x2 = width;
            
            CGFloat y1 = height*bottom;
            CGFloat y2 = height*bottom;
            
            [path moveToPoint:CGPointMake(x1, y1)];
            [path addLineToPoint:CGPointMake(x2, y2)];
        }
        
        backgroundLines = @[path];
    }
    return backgroundLines;
}


// Erase the Siganture view by initial the new path.
- (void)erase {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_SIGNATURE_PATH];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_pathArray removeAllObjects];
   signPath = [UIBezierPath bezierPath];
   [signPath setLineWidth:2.0];
    [signPath setLineCapStyle:kCGLineCapRound];
    [signPath setLineJoinStyle:kCGLineJoinRound];
   [self setNeedsDisplay];             // Update the view.
}

// panReconizer method triggers while touch the view.
- (void)tapReconizer:(UITapGestureRecognizer *)tab {
    
    CGPoint currentPoint = [tab locationInView:self];

    CGPoint prevPoint = CGPointMake(currentPoint.x, currentPoint.y-2);
    CGPoint midPoint = midpoint(currentPoint, prevPoint);
    [signPath moveToPoint:currentPoint];
    [signPath addLineToPoint:midPoint];
    
    [self setNeedsDisplay]; // Update the view.
}

// panReconizer method triggers while touch the view.
- (void)panReconizer:(UIPanGestureRecognizer *)pan {
    
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(currentPoint, previousPoint);
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [signPath moveToPoint:currentPoint];
            break;
            
        case UIGestureRecognizerStateChanged:
            [signPath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            break;
            
        case UIGestureRecognizerStateRecognized:
            [signPath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            break;
            
        case UIGestureRecognizerStatePossible:
            [signPath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
            break;
            
        default:
            break;
    }
    
    previousPoint = currentPoint;
    
    [self setNeedsDisplay]; // Update the view.
}


- (BOOL)signatureExists {
    return self.pathArray.count > 0;
}

// Setup the stroke color.

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    for (UIBezierPath *path in self.backgroundLines) {
        [[[UIColor blackColor] colorWithAlphaComponent:0.2] setStroke];
        [path stroke];
    }
    
    if (![self signatureExists] && (!signPath || [signPath isEmpty])) {
        [@"Sign here" drawAtPoint:[self placeholderPoint]
                                                                withAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:12],
                                                                                  NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.2]}];
    }
    
    for (UIBezierPath *path in self.pathArray) {
        [self.lineColor setStroke];
        [path stroke];
    }
    
    [self.lineColor setStroke];
    [signPath stroke];
}


@end
