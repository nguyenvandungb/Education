//
//  DrawPathHelper.h
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#ifdef __cplusplus
extern "C" {
#endif
    UIImage *imageFromPath(NSString* path, UIColor *color);
    UIBezierPath *uibezierPathFromSVGString(NSString *svgPath);
    UIImage *asImageWithSize(NSString* svgPath, CGSize maximumSize, CGFloat scale, CGRect viewBox);
#ifdef __cplusplus
}
#endif

@interface DrawPathHelper : NSObject

@end
