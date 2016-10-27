//
//  SVGParser.m
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import "SVGParser.h"
#import <vector>
#import <CoreGraphics/CoreGraphics.h>
NSString * const kValidSVGCommands = @"CcMmLlHhVvZzqQaAsS";

@interface SVGParser()
{
    CGMutablePathRef _path;
    CGPoint _lastControlPoint;
    unichar command, _lastCmd;
    std::vector<float> _operands;
    CGFloat padding;
}
@property (nonatomic, copy) NSString *svgPath;
@end

@implementation SVGParser
- (instancetype)initWithSVGPathStr:(NSString *)svg {
    self = [super init];
    if (self) {
        self.svgPath = svg;
        padding = 20;
    }
    return self;
}

- (UIBezierPath *)parse {
    _path = CGPathCreateMutable();
    CGPathMoveToPoint(_path, NULL, 0, 0);
    NSScanner * const scanner = [NSScanner scannerWithString: _svgPath];
    static NSCharacterSet *separators, *commands;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commands   = [NSCharacterSet characterSetWithCharactersInString:kValidSVGCommands];
        separators = [NSMutableCharacterSet characterSetWithCharactersInString:@","];
        [(NSMutableCharacterSet *)separators formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    });
    scanner.charactersToBeSkipped = separators;

    NSString *cmdBuf;
    while([scanner scanCharactersFromSet:commands intoString:&cmdBuf]) {
        _operands.clear();
        if([cmdBuf length] > 1) {
            scanner.scanLocation -= [cmdBuf length]-1;
        } else {
            for(float operand;
                [scanner scanFloat:&operand];
                _operands.push_back(operand));
        }
        _lastCmd = command;
        command = [cmdBuf characterAtIndex:0];
        switch(command) {
            case 'M': case 'm':
                [self appendMoveTo];
                break;
            case 'L': case 'l':
            case 'H': case 'h':
            case 'V': case 'v':
                [self appendLineTo];
                break;
            case 'C': case 'c':
                [self appendCurve];
                break;
            case 'S': case 's':
                [self appendShorthandCurve];
                break;
            case 'a': case 'A':
                NSLog(@"*** Error: Elliptical arcs not supported"); // TODO
                break;
            case 'Z': case 'z':
                CGPathCloseSubpath(_path);
                break;
            default:
                NSLog(@"*** Error: Cannot process command : '%c'", command);
                break;
        }
    }
    return [UIBezierPath bezierPathWithCGPath:_path];
}

- (void)appendMoveTo {
    if(_operands.size()%2 != 0) {
        NSLog(@"*** Error: Invalid parameter count in M style token");
        return;
    }

    for(NSUInteger i = 0; i < _operands.size(); i += 2) {
        CGPoint currentPoint = CGPathGetCurrentPoint(_path);
        CGFloat x = _operands[i+0] + (command == 'm' ? currentPoint.x : 0);
        CGFloat y = _operands[i+1] + (command == 'm' ? currentPoint.y : 0);

        if(i == 0)
            CGPathMoveToPoint(_path, NULL, x, y);
        else
            CGPathAddLineToPoint(_path, NULL, x, y);
    }
}

- (void)appendLineTo {
    for(NSUInteger i = 0; i < _operands.size(); ++i) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGPoint const currentPoint = CGPathGetCurrentPoint(_path);
        switch(command) {
            case 'l':
                x = currentPoint.x;
                y = currentPoint.y;
            case 'L':
                x += _operands[i];
                if (++i == _operands.size()) {
                    NSLog(@"*** Error: Invalid parameter count in L style token");
                    return;
                }
                y += _operands[i];
                break;
            case 'h' :
                x = currentPoint.x;
            case 'H' :
                x += _operands[i];
                y = currentPoint.y;
                break;
            case 'v' :
                y = currentPoint.y;
            case 'V' :
                y += _operands[i];
                x = currentPoint.x;
                break;
            default:
                NSLog(@"*** Error: Unrecognised L style command.");
                return;
        }
        CGPathAddLineToPoint(_path, NULL, x, y);
    }
}

- (void)appendCurve {
    if(_operands.size()%6 != 0) {
        NSLog(@"*** Error: Invalid number of parameters for C command");
        return;
    }

    // (x1, y1, x2, y2, x, y)
    for(NSUInteger i = 0; i < _operands.size(); i += 6) {
        CGPoint const currentPoint = CGPathGetCurrentPoint(_path);
        CGFloat const x1 = _operands[i+0] + (command == 'c' ? currentPoint.x : 0);
        CGFloat const y1 = _operands[i+1] + (command == 'c' ? currentPoint.y : 0);
        CGFloat const x2 = _operands[i+2] + (command == 'c' ? currentPoint.x : 0);
        CGFloat const y2 = _operands[i+3] + (command == 'c' ? currentPoint.y : 0);
        CGFloat const x  = _operands[i+4] + (command == 'c' ? currentPoint.x : 0);
        CGFloat const y  = _operands[i+5] + (command == 'c' ? currentPoint.y : 0);

        CGPathAddCurveToPoint(_path, NULL, x1, y1, x2, y2, x, y);
        _lastControlPoint = CGPointMake(x2, y2);
    }
}

- (void)appendShorthandCurve {
    if(_operands.size()%4 != 0) {
        NSLog(@"*** Error: Invalid number of parameters for S command");
        return;
    }
    if(_lastCmd != 'C' && _lastCmd != 'c' && _lastCmd != 'S' && _lastCmd != 's')
        _lastControlPoint = CGPathGetCurrentPoint(_path);

    // (x2, y2, x, y)
    for(NSUInteger i = 0; i < _operands.size(); i += 4) {
        CGPoint const currentPoint = CGPathGetCurrentPoint(_path);
        CGFloat const x1 = currentPoint.x + (currentPoint.x - _lastControlPoint.x);
        CGFloat const y1 = currentPoint.y + (currentPoint.y - _lastControlPoint.y);
        CGFloat const x2 = _operands[i+0] + (command == 's' ? currentPoint.x : 0);
        CGFloat const y2 = _operands[i+1] + (command == 's' ? currentPoint.y : 0);
        CGFloat const x  = _operands[i+2] + (command == 's' ? currentPoint.x : 0);
        CGFloat const y  = _operands[i+3] + (command == 's' ? currentPoint.y : 0);

        CGPathAddCurveToPoint(_path, NULL, x1, y1, x2, y2, x, y);
        _lastControlPoint = CGPointMake(x2, y2);
    }
}
@end
