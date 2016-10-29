//
//  Utils.h
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject
+ (void)loadCustomFont:(NSMutableArray *)customFontFilePaths;
+ (void)loadFont;
+ (CGSize) sizeForText:(NSString *)text
             boundSize:(CGSize)bsize
                option:(NSStringDrawingOptions)option
         lineBreakMode:(NSLineBreakMode)lineBreakMode
                  font:(UIFont *)font;
@end
