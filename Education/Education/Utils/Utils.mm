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
+ (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

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

+ (CGRect)SVGStringToRect:(NSString*)serializedRect {
    CGRect	result  = CGRectZero;
    NSInteger stringLength = serializedRect.length;
    if(stringLength >= 7 && stringLength < 255) {
        NSInteger stringIndex = 0;
        char stringBuffer[256];
        char numberBuffer[256];
        if ([serializedRect  getCString:stringBuffer maxLength:255 encoding:NSASCIIStringEncoding]) {
            while(stringIndex < stringLength) {
                char aChar = stringBuffer[stringIndex];
                if(aChar == '-' || aChar == '.' || (aChar >= '0' && aChar <= '9')) {
                    break;
                } else {
                    stringIndex++;
                }
            }
            if ((stringLength-stringIndex) >= 7) {
                float parameters[4];
                NSUInteger parameterIndex = 0;
                BOOL failed = NO;
                while(stringIndex < stringLength && !failed && parameterIndex < 4) {
                    char aChar = stringBuffer[stringIndex];
                    NSInteger beginNumberIndex = -1;
                    BOOL numberSeen = NO;
                    BOOL periodSeen = NO;
                    while(beginNumberIndex == -1 && stringIndex < stringLength) {
                        if(aChar == '-') {
                            beginNumberIndex = stringIndex++;
                        } else if(aChar == '.') {
                            beginNumberIndex = stringIndex++;
                            periodSeen = YES;
                        } else if(aChar >= '0' && aChar <= '9') {
                            beginNumberIndex = stringIndex++;
                            numberSeen = YES;
                        } else {
                            stringIndex++;
                        }
                        aChar = stringBuffer[stringIndex];
                    }

                    if(beginNumberIndex > -1) {
                        NSInteger endNumIndex = beginNumberIndex;
                        while(stringIndex < stringLength) {
                            aChar = stringBuffer[stringIndex++];
                            if(aChar >= '0' && aChar <= '9') {
                                numberSeen = YES;
                                endNumIndex++;
                            } else if(aChar == '.' && !periodSeen) {
                                periodSeen = YES;
                                endNumIndex++;
                            } else {
                                break;
                            }
                        }
                        if(numberSeen) {
                            memcpy(numberBuffer, &stringBuffer[beginNumberIndex], endNumIndex-beginNumberIndex+1);
                            numberBuffer[endNumIndex-beginNumberIndex+1]= 0;
                            if(periodSeen) {
                                parameters[parameterIndex++]  = atof(numberBuffer);
                            } else {
                                parameters[parameterIndex++]  = atoi(numberBuffer);
                            }
                        } else {
                            failed = YES;
                        }
                    } else {
                        failed = YES;
                    }
                }
                if(!failed) {
                    result = CGRectMake(parameters[0], parameters[1], parameters[2], parameters[3]);
                }
            }
        }
    }
    return result;
}

+ (CGRect)makeDrawingRect:(CGRect)boxRect bound:(CGRect)bound {
    CGRect	myBounds = bound;
    CGRect	preferredRect = boxRect;
    if(CGRectIsEmpty(preferredRect)) {
        preferredRect = myBounds;
    }

    CGFloat	nativeWidth = preferredRect.size.width;
    CGFloat	nativeHeight = preferredRect.size.height;
    CGFloat	nativeAspectRatio = nativeWidth/nativeHeight;
    CGFloat	boundedAspectRatio = myBounds.size.width/myBounds.size.height;

    CGFloat	paintedWidth = myBounds.size.width;
    CGFloat	paintedHeight = myBounds.size.height;
    CGRect	result = myBounds;

    NSString* myGravity = @"center";
    if([myGravity isEqualToString:kCAGravityResizeAspect])
    {

        if(nativeAspectRatio >= boundedAspectRatio) // blank space on top and bottom
        {
            paintedHeight = paintedWidth/nativeAspectRatio;
        }
        else
        {
            paintedWidth = paintedHeight*nativeAspectRatio;
        }
        paintedWidth = rintf(paintedWidth);
        paintedHeight = rintf(paintedHeight);

        CGFloat xOrigin = (myBounds.size.width-paintedWidth)/2.0f;
        CGFloat yOrigin = (myBounds.size.height-paintedHeight)/2.0f;
        result = CGRectMake(xOrigin, yOrigin, paintedWidth, paintedHeight);
    }
    else if([myGravity isEqualToString:kCAGravityResizeAspectFill])
    {
        if(nativeAspectRatio <= boundedAspectRatio) // blank space on top and bottom
        {
            paintedHeight = paintedWidth/nativeAspectRatio;
        }
        else
        {
            paintedWidth = paintedHeight*nativeAspectRatio;
        }
        paintedWidth = rintf(paintedWidth);
        paintedHeight = rintf(paintedHeight);

        CGFloat xOrigin = (myBounds.size.width-paintedWidth)/2.0f;
        CGFloat yOrigin = (myBounds.size.height-paintedHeight)/2.0f;
        result = CGRectMake(xOrigin, yOrigin, paintedWidth, paintedHeight);
    }
    else if([myGravity isEqualToString:kCAGravityBottomLeft])
    { // flipped

        result = CGRectMake(0, 0, preferredRect.size.width, preferredRect.size.height);
    }

    result = CGRectIntegral(result);
    return result;
}

@end
