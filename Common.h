#import "../PS.h"

#define kFontSize 14
#define NORMAL_EFFECT_COUNT 8
#define EXTRA_EFFECT_COUNT 25
#define CINoneName @"CINone"
#define tweakIdentifier @"com.PS.EffectsPlus"
#define tweakName @"Effects+"

@interface CIFilter (Addition)
@property(retain, nonatomic) CIImage *inputImage;
//@property (nonatomic, copy) NSString *anotherFilter;
- (NSDictionary *)_outputProperties;
@end

@interface PLEditPhotoController (Addition)
- (void)EPSavePhoto;
- (void)ep_save:(int)mode;
@end

@interface PUPhotoFilterThumbnailRenderer : NSObject
- (UIImage *)_thumbnailImage;
@end

extern "C" NSString *PLLocalizedFrameworkString(NSString *key, NSString *comment);