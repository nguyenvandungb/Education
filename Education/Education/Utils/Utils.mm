//
//  Utils.m
//  Education
//
//  Created by Nguyen Van Dung on 10/28/16.
//  Copyright © 2016 Dht. All rights reserved.
//

#import "Utils.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@implementation Utils
+(void) loadCustomFont:(NSMutableArray *)customFontFilePaths {

    for(NSString *fontFilePath in customFontFilePaths){

        if([[NSFileManager defaultManager] fileExistsAtPath:fontFilePath]){

            NSData *inData = [NSData dataWithContentsOfFile:fontFilePath];
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
            if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                CFRelease(errorDescription);
            }
            CFRelease(font);
            CFRelease(provider);
        }
    }
}

+ (void)loadFont {
    NSMutableArray *customFontsPath = [[NSMutableArray alloc] init];
    NSArray *fontFileNameArray = [NSArray arrayWithObjects:
                                  @"KanjiStrokeOrders_v4.001.ttf", nil];
    for(NSString *fontFileName in fontFileNameArray){

        NSString *fileName = [fontFileName stringByDeletingPathExtension];
        NSString *fileExtension = [fontFileName pathExtension];
        [customFontsPath addObject:[[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension]];
    }

    [Utils loadCustomFont:customFontsPath];
}


+ (CGSize) sizeForText:(NSString *)text
             boundSize:(CGSize)bsize
                option:(NSStringDrawingOptions)option
         lineBreakMode:(NSLineBreakMode)lineBreakMode
                  font:(UIFont *)font {
    if (!text || text.length ==0 || !font) {
        return CGSizeZero;
    }
    CGSize textSize = CGSizeZero;
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;

    textSize = [text boundingRectWithSize: bsize
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}
                                  context:nil].size;
    return textSize;
}
@end
