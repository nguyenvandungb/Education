#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PDFImageConverter : NSObject {

}

+ (NSData *) convertImageToPDF: (UIImage *) image;
+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution;
+ (NSData *) convertImageToPDF: (UIImage *) image withHorizontalResolution: (double) horzRes verticalResolution: (double) vertRes;
+ (NSData *) convertImageToPDF: (UIImage *) image withResolution: (double) resolution maxBoundsRect: (CGRect) boundsRect pageSize: (CGSize) pageSize;

@end
