#import "../Common.h"
#import "../Prefs.h"
#import "../../PSPrefs.x"

BOOL internalBlurHook = NO;
BOOL globalFilterHook = NO;

BOOL TweakEnabled;
BOOL FillGrid;
BOOL AutoHideBB;
BOOL oldEditor;

CGFloat CISepiaTone_inputIntensity;
CGFloat CIVibrance_inputAmount;
CGFloat CIColorMonochrome_inputIntensity;
CGFloat CIColorMonochrome_R, CIColorMonochrome_G, CIColorMonochrome_B;
CGFloat CIColorPosterize_inputLevels;
CGFloat CIGloom_inputRadius, CIGloom_inputIntensity;
CGFloat CIBloom_inputRadius, CIBloom_inputIntensity;
CGFloat CISharpenLuminance_inputSharpness;
CGFloat CIPixellate_inputScale;
CGFloat CIGaussianBlur_inputRadius;
CGFloat CIFalseColor_R1, CIFalseColor_G1, CIFalseColor_B1;
CGFloat CIFalseColor_R2, CIFalseColor_G2, CIFalseColor_B2;
CGFloat CITwirlDistortion_inputRadius, CITwirlDistortion_inputAngle;
CGFloat CITriangleKaleidoscope_inputSize, CITriangleKaleidoscope_inputDecay;
CGFloat CIPinchDistortion_inputRadius, CIPinchDistortion_inputScale;
CGFloat CILightTunnel_inputRadius, CILightTunnel_inputRotation;
CGFloat CIHoleDistortion_inputRadius;
CGFloat CICircleSplashDistortion_inputRadius;
CGFloat CICircularScreen_inputWidth, CICircularScreen_inputSharpness;
CGFloat CILineScreen_inputAngle, CILineScreen_inputWidth, CILineScreen_inputSharpness;
CGFloat CIMirror_inputAngle;

CGFloat qualityFactor;
NSInteger mode;
NSUInteger ciNoneIndex = NSNotFound;

NSMutableArray *cachedEffects = nil;
NSArray *enabledArray = nil;
NSMutableArray *enabledArray2 = nil;

static void configEffect(CIFilter *filter)
{
	NSString *filterName = filter.name;
	if ([filterName isEqualToString:@"CIGloom"])
		[(CIGloom *)filter setInputIntensity:@(CIGloom_inputIntensity)];
	else if ([filterName isEqualToString:@"CIBloom"])
		[(CIBloom *)filter setInputIntensity:@(CIBloom_inputIntensity)];
	else if ([filterName isEqualToString:@"CITwirlDistortion"])
		[(CITwirlDistortion *)filter setInputAngle:@(M_PI / 2 + CITwirlDistortion_inputAngle)];
	else if ([filterName isEqualToString:@"CIPinchDistortion"])
		[(CIPinchDistortion *)filter setInputScale:@(CIPinchDistortion_inputScale)];
	else if ([filterName isEqualToString:@"CIVibrance"])
		[(CIVibrance *)filter setInputAmount:@(CIVibrance_inputAmount)];
	else if ([filterName isEqualToString:@"CISepiaTone"])
		[(CISepiaTone *)filter setInputIntensity:@(CISepiaTone_inputIntensity)];
	else if ([filterName isEqualToString:@"CIColorMonochrome"])
		[(CIColorMonochrome *)filter setInputColor:[CIColor colorWithRed:CIColorMonochrome_R green:CIColorMonochrome_G blue:CIColorMonochrome_B]];
	else if ([filterName isEqualToString:@"CIFalseColor"]) {
		CIColor *color0 = [CIColor colorWithRed:CIFalseColor_R1 green:CIFalseColor_G1 blue:CIFalseColor_B1];
		CIColor *color1 = [CIColor colorWithRed:CIFalseColor_R2 green:CIFalseColor_G2 blue:CIFalseColor_B2];
		[(CIFalseColor *)filter setInputColor0:color0];
		[(CIFalseColor *)filter setInputColor1:color1];
	}
	else if ([filterName isEqualToString:@"CILightTunnel"])
		[(CILightTunnel *)filter setInputRotation:@(CILightTunnel_inputRotation)];
	else if ([filterName isEqualToString:@"CICircularScreen"]) {
		[(CICircularScreen *)filter setInputWidth:@(CICircularScreen_inputWidth)];
		[(CICircularScreen *)filter setInputSharpness:@(CICircularScreen_inputSharpness)];
	}
	else if ([filterName isEqualToString:@"CILineScreen"]) {
		[(CILineScreen *)filter setInputAngle:@(CILineScreen_inputAngle)];
		[(CILineScreen *)filter setInputSharpness:@(CILineScreen_inputSharpness)];
	}
}

HaveCallback()
{
	GetPrefs()
	BOOL isAssetsd = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.assetsd"];
	if (!isAssetsd) {
		GetBool(TweakEnabled, EnabledKey, YES)
		GetBool2(FillGrid, NO)
		GetBool2(AutoHideBB, NO)
		GetBool(oldEditor, useOldEditorKey, NO)
		GetInt(mode, saveModeKey, 1)
		GetGeneric(enabledArray, ENABLED_EFFECT, @[])
		if (isiOS9Up) {
			enabledArray2 = [enabledArray mutableCopy];
			[enabledArray2 removeObject:@"CINone"];
		}
	}
	GetFloat2(CIColorMonochrome_R, 0.5f)
	GetFloat2(CIColorMonochrome_G, 0.6f)
	GetFloat2(CIColorMonochrome_B, 0.7f)
	GetFloat2(CIFalseColor_R1, 0.2f)
	GetFloat2(CIFalseColor_G1, 0.3f)
	GetFloat2(CIFalseColor_B1, 0.5f)
	GetFloat2(CIFalseColor_R2, 0.6f)
	GetFloat2(CIFalseColor_G2, 0.8f)
	GetFloat2(CIFalseColor_B2, 0.9f)
	GetFloat2(CISepiaTone_inputIntensity, 1.0f)
	GetFloat2(CIVibrance_inputAmount, 1.0f)
	GetFloat2(CIColorMonochrome_inputIntensity, 1.0f)
	GetFloat2(CIColorPosterize_inputLevels, 6.0f)
	GetFloat2(CIGloom_inputRadius, 10.0f)
	GetFloat2(CIGloom_inputIntensity, 1.0f)
	GetFloat2(CIBloom_inputRadius, 10.0f)
	GetFloat2(CIBloom_inputIntensity, 1.0f)
	GetFloat2(CISharpenLuminance_inputSharpness, 0.4f)
	GetFloat2(CIPixellate_inputScale, 8.0f)
	GetFloat2(CIGaussianBlur_inputRadius, 10.0f)
	GetFloat2(CITwirlDistortion_inputRadius, 200.0f)
	GetFloat2(CITwirlDistortion_inputAngle, 3.14f)
	GetFloat2(CITriangleKaleidoscope_inputSize, 300.0f)
	GetFloat2(CITriangleKaleidoscope_inputDecay, 0.85f)
	GetFloat2(CIPinchDistortion_inputRadius, 200.0f)
	GetFloat2(CIPinchDistortion_inputScale, 0.5f)
	GetFloat2(CILightTunnel_inputRadius, 90.0f)
	GetFloat2(CILightTunnel_inputRotation, 0.0f)
	GetFloat2(CIHoleDistortion_inputRadius, 150.0f)
	GetFloat2(CICircleSplashDistortion_inputRadius, 150.0f)
	GetFloat2(CICircularScreen_inputWidth, 6.0f)
	GetFloat2(CICircularScreen_inputSharpness, 0.7f)
	GetFloat2(CILineScreen_inputAngle, 0.0f)
	GetFloat2(CILineScreen_inputWidth, 6.0f)
	GetFloat2(CILineScreen_inputSharpness, 0.7f)
	GetFloat2(CIMirror_inputAngle, 0.0f)
	if (isiOS8Up && !isAssetsd) {
		ciNoneIndex = NSNotFound;
		if (cachedEffects == nil)
			cachedEffects = [[NSMutableArray array] retain];
		else
			[cachedEffects removeAllObjects];
		for (int i = 0; i < enabledArray.count; i++) {
			if ([enabledArray[i] isEqualToString:CINoneName])
				ciNoneIndex = i;
			CIFilter *filter = [[CIFilter filterWithName:enabledArray[i]] retain];
			configEffect(filter);
			[cachedEffects addObject:filter];
		}
	}
}