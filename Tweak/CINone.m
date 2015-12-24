#import "CINone.h"

@implementation CINone
@synthesize inputImage;

- (CIImage *)outputImage
{
    return inputImage;
}

@end