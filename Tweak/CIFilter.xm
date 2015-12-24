#import "Tweak.h"

%hook CIImage

- (CIImage *)_imageByApplyingBlur:(double)blur
{
	if (!internalBlurHook)
		return %orig;
	CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[gaussianBlurFilter setValue:self forKey:@"inputImage"]; 
	[gaussianBlurFilter setValue:[NSNumber numberWithDouble:blur] forKey:@"inputRadius"];
	CIImage *resultImage = [gaussianBlurFilter valueForKey:@"outputImage"];
	return resultImage;
}

%end

static CIImage *ciImageInternalFixIfNecessary(CIImage *outputImage, CIFilter *itsFilter)
{
	if (!globalFilterHook)
		return outputImage;
	CGRect rect = itsFilter.inputImage.extent;
	CIImage *fixedImage = [outputImage imageByCroppingToRect:rect];
	return fixedImage;
}

static NSDictionary *dictionaryByAddingSomeNativeValues(NSDictionary *inputDict)
{
	NSMutableDictionary *mutableInputDict = [NSMutableDictionary dictionary];
	[mutableInputDict addEntriesFromDictionary:inputDict];
	NSMutableArray *filterCategoriesArray = [NSMutableArray array];
	[filterCategoriesArray addObjectsFromArray:mutableInputDict[@"CIAttributeFilterCategories"]];
	if (filterCategoriesArray == nil)
		return inputDict;
	if (![filterCategoriesArray containsObject:@"CICategoryXMPSerializable"])
		[filterCategoriesArray addObject:@"CICategoryXMPSerializable"];
	[mutableInputDict setObject:filterCategoriesArray forKey:@"CIAttributeFilterCategories"];
	return mutableInputDict;
}

%hook CIFilter

+ (NSArray *)filterNamesInCategories:(NSArray *)categories
{
	NSMutableArray *orig = [NSMutableArray array];
	[orig addObjectsFromArray:%orig];
	if (orig != nil)
		[orig addObject:CINoneName];
	return orig;
}

- (NSString *)_serializedXMPString
{
	NSString *name = %orig;
	return name == nil ? self.name : name;
}

%end

%hook CISharpenLuminance

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (void)setInputSharpness:(NSNumber *)sharpness
{
	%orig(globalFilterHook ? @(CISharpenLuminance_inputSharpness) : sharpness);
}

%end

%hook CIGaussianBlur

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIPixellate

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIMirror

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIXRay

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CICircleSplashDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIStretch

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIThermal

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIColorInvert

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CITriangleKaleidoscope

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIHoleDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CIWrapMirror

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIPinchDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CILightTunnel

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (CIImage *)outputImage
{
	return ciImageInternalFixIfNecessary(%orig, self);
}

%end

%hook CITwirlDistortion

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIColorMonochrome

- (void)setInputIntensity:(NSNumber *)intensity
{
	%orig(globalFilterHook ? @(CIColorMonochrome_inputIntensity) : intensity);
}

- (void)setInputColor:(CIColor *)color
{
	%orig(globalFilterHook ? [CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B] : color);
}

%end

%hook CIColorPosterize

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

- (void)setInputLevels:(NSNumber *)levels
{
	%orig(globalFilterHook ? @(CIColorPosterize_inputLevels) : levels);
}

%end

%hook CISepiaTone

- (void)setInputIntensity:(NSNumber *)intensity
{
	%orig(globalFilterHook ? @(CISepiaTone_inputIntensity) : intensity);
}

%end

%hook CIVibrance

- (void)setInputAmount:(NSNumber *)amount
{
	%orig(globalFilterHook ? @(CIVibrance_inputAmount) : amount);
}

%end

%hook CIBloom

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CIGloom

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CICircularScreen

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end

%hook CILineScreen

+ (NSDictionary *)customAttributes
{
	return dictionaryByAddingSomeNativeValues(%orig);
}

%end