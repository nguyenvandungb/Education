//
//  SVGParser.h
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface SVGParser : NSObject
- (instancetype)initWithSVGPathStr:(NSString *)svg;
- (UIBezierPath *)parse;
@end
