#import <CoreImage/CIFilter.h>

@interface CINone : CIFilter {
    CIImage *inputImage;
}
@property (retain, nonatomic) CIImage *inputImage;
@end
