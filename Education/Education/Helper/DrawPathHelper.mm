//
//  DrawPathHelper.m
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import "DrawPathHelper.h"
#import <UIKit/UIKit.h>


static bool readCGFloat(NSString *string, int &position, CGFloat &result) {
    int start = position;
    bool seenDot = false;
    int length = (int)string.length;
    while (position < length) {
        unichar c = [string characterAtIndex:position];
        position++;

        if (c == '.') {
            if (seenDot) {
                return false;
            } else {
                seenDot = true;
            }
        } else if (c < '0' || c > '9') {
            if (position == start) {
                result = 0.0f;
                return true;
            } else {
                result = [[string substringWithRange:NSMakeRange(start, position - start)] floatValue];
                return true;
            }
        }
    }
    if (position == start) {
        result = 0.0f;
        return true;
    } else {
        result = [[string substringWithRange:NSMakeRange(start, position - start)] floatValue];
        return true;
    }
    return true;
}

UIBezierPath *uibezierPathFromSVGString(NSString *svgPath) {
    int position = 0;
    int length = (int)svgPath.length;

    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CGPoint _lastControlPoint;
    while (position < length) {
        unichar c = [svgPath characterAtIndex:position];
        position++;

        if (c == ' ') {
            continue;
        }
        if (c == 'M' || c == 'm') { // M
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(svgPath, position, x);
            readCGFloat(svgPath, position, y);
            [bezierPath moveToPoint: CGPointMake(x, y)];
        } else if ((c == 'L' || c == 'l')
                   || (c == 'H' || c == 'h')
                   || (c == 'V' || c == 'v')) { // L
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(svgPath, position, x);
            readCGFloat(svgPath, position, y);
            [bezierPath addLineToPoint: CGPointMake(x, y)];
        } else if (c == 'C' || c == 'c'){ // C
            CGFloat x1 = 0.0f;
            CGFloat y1 = 0.0f;
            CGFloat x2 = 0.0f;
            CGFloat y2 = 0.0f;
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(svgPath, position, x1);
            readCGFloat(svgPath, position, y1);
            readCGFloat(svgPath, position, x2);
            readCGFloat(svgPath, position, y2);
            readCGFloat(svgPath, position, x);
            readCGFloat(svgPath, position, y);
            [bezierPath addCurveToPoint: CGPointMake(x, y)
                          controlPoint1: CGPointMake(x1, y1)
                          controlPoint2: CGPointMake(x2, y2)];
        } else if (c == 'Z' || c == 'z') { // Z
            [bezierPath closePath];
        }
    }
    [[UIColor redColor] setFill];
    [bezierPath fill];
    return bezierPath;
}

void DrawSvgPath(CGContextRef context, NSString *path) {
    int position = 0;
    int length = (int)path.length;

    while (position < length) {
        unichar c = [path characterAtIndex:position];
        position++;

        if (c == ' ') {
            continue;
        }

        if (c == 'M' | c == 'm') { // M
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);
            CGContextMoveToPoint(context, x, y);
        } else if (c == 'L' || c == 'l') { // L
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);
            CGContextAddLineToPoint(context, x, y);
        } else if (c == 'C' || c == 'c') { // C
            CGFloat x1 = 0.0f;
            CGFloat y1 = 0.0f;
            CGFloat x2 = 0.0f;
            CGFloat y2 = 0.0f;
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x1);
            readCGFloat(path, position, y1);
            readCGFloat(path, position, x2);
            readCGFloat(path, position, y2);
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);

            CGContextAddCurveToPoint(context, x1, y1, x2, y2, x, y);
        } else if (c == 'Z' || c == 'z') { // Z
            CGContextClosePath(context);
            CGContextFillPath(context);
            CGContextBeginPath(context);
        }
    }
}


UIImage *asImageWithSize(NSString* svgPath, CGSize maximumSize, CGFloat scale, CGRect viewBox)
{
    CGRect documentRect = viewBox;
    CGSize documentSize = documentRect.size;

    CGFloat interiorAspectRatio = maximumSize.width/maximumSize.height;
    CGFloat rendererAspectRatio = documentSize.width/documentSize.height;
    CGFloat fittedScaling;
    if(interiorAspectRatio >= rendererAspectRatio)
    {
        fittedScaling = maximumSize.height/documentSize.height;
    }
    else
    {
        fittedScaling = maximumSize.width/documentSize.width;
    }

    CGFloat scaledWidth = floor(documentSize.width*fittedScaling);
    CGFloat scaleHeight = floor(documentSize.height*fittedScaling);

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(scaledWidth, scaleHeight), NO, scale);
    CGContextRef quartzContext = UIGraphicsGetCurrentContext();
    CGContextClearRect(quartzContext, CGRectMake(0, 0, scaledWidth, scaleHeight));

    CGContextSaveGState(quartzContext);
    CGContextScaleCTM(quartzContext,fittedScaling,fittedScaling);
    CGContextTranslateCTM(quartzContext, -documentRect.origin.x*fittedScaling, -documentRect.origin.y*fittedScaling);

    // tell the renderer to draw into my context
    DrawSvgPath(quartzContext, svgPath);
    CGContextRestoreGState(quartzContext);
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(result, 1);
    [data writeToFile:@"/Users/dungnv20384/Desktop/export_pdf/image.jpg" atomically:true];

    return result;
}


UIImage *imageFromPath(NSString* path, UIColor *color)
{
    CGFloat radius = 109;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, color.CGColor);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
   // CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

//    CGContextTranslateCTM(context, -0.5, 0.5);
//    CGFloat factor = 28.0f / 34.0f;
//    CGContextScaleCTM(context, 0.5f * factor, 0.5f * factor);

    DrawSvgPath(context, path);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [data writeToFile:@"/Users/dungnv20384/Desktop/export_pdf/image.jpg" atomically:true];
    return image;
}

@implementation DrawPathHelper

@end
