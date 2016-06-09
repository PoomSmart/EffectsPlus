#import <HBPreferences.h>

NSString *EnabledKey = @"Enabled";
NSString *FillGridKey = @"FillGrid";
NSString *AutoHideBBKey = @"AutoHideBB";
NSString *useOldEditorKey = @"useOldEditor";
NSString *qualityFactorKey = @"qualityFactor";
NSString *saveModeKey = @"saveMode";
NSString *ENABLED_EFFECT = @"EnabledEffects";
NSString *DISABLED_EFFECT = @"DisabledEffects";

#define abc(key) \
	NSString * (key ## Key) = (@ #key);
	
abc(CIColorMonochrome_R)
abc(CIColorMonochrome_G)
abc(CIColorMonochrome_B)
abc(CIFalseColor_R1)
abc(CIFalseColor_G1)
abc(CIFalseColor_B1)
abc(CIFalseColor_R2)
abc(CIFalseColor_G2)
abc(CIFalseColor_B2)
abc(CISepiaTone_inputIntensity)
abc(CIVibrance_inputAmount)
abc(CIColorMonochrome_inputIntensity)
abc(CIColorPosterize_inputLevels)
abc(CIGloom_inputRadius)
abc(CIGloom_inputIntensity)
abc(CIBloom_inputRadius)
abc(CIBloom_inputIntensity)
abc(CISharpenLuminance_inputSharpness)
abc(CIPixellate_inputScale)
abc(CIGaussianBlur_inputRadius)
abc(CITwirlDistortion_inputRadius)
abc(CITwirlDistortion_inputAngle)
abc(CITriangleKaleidoscope_inputSize)
abc(CITriangleKaleidoscope_inputDecay)
abc(CIPinchDistortion_inputRadius)
abc(CIPinchDistortion_inputScale)
abc(CILightTunnel_inputRadius)
abc(CILightTunnel_inputRotation)
abc(CIHoleDistortion_inputRadius)
abc(CICircleSplashDistortion_inputRadius)
abc(CICircularScreen_inputWidth)
abc(CICircularScreen_inputSharpness)
abc(CILineScreen_inputAngle)
abc(CILineScreen_inputWidth)
abc(CILineScreen_inputSharpness)
abc(CIMirror_inputAngle)

void registerPref(HBPreferences *preferences)
{
	[preferences registerDefaults:@{
		EnabledKey : @YES,
		FillGridKey : @NO,
		AutoHideBBKey : @NO,
		useOldEditorKey : @NO,
		qualityFactorKey : @1.0,
		saveModeKey : @1,
		CIColorMonochrome_RKey : @0.5f,
		CIColorMonochrome_GKey : @0.6f,
		CIColorMonochrome_BKey : @0.7f,
		CIFalseColor_R1Key : @0.2f,
		CIFalseColor_G1Key : @0.3f,
		CIFalseColor_B1Key : @0.5f,
		CIFalseColor_R2Key : @0.6f,
		CIFalseColor_G2Key : @0.8f,
		CIFalseColor_B2Key : @0.9f,
		CISepiaTone_inputIntensityKey : @1.0f,
		CIVibrance_inputAmountKey : @1.0f,
		CIColorMonochrome_inputIntensityKey : @1.0f,
		CIColorPosterize_inputLevelsKey : @6.0f,
		CIGloom_inputRadiusKey : @10.0f,
		CIGloom_inputIntensityKey : @1.0f,
		CIBloom_inputRadiusKey : @10.0f,
		CIBloom_inputIntensityKey : @1.0f,
		CISharpenLuminance_inputSharpnessKey : @0.4f,
		CIPixellate_inputScaleKey : @8.0f,
		CIGaussianBlur_inputRadiusKey : @10.0f,
		CITwirlDistortion_inputRadiusKey : @200.0f,
		CITwirlDistortion_inputAngleKey : @3.14f,
		CITriangleKaleidoscope_inputSizeKey : @300.0f,
		CITriangleKaleidoscope_inputDecayKey : @0.85f,
		CIPinchDistortion_inputRadiusKey : @200.0f,
		CIPinchDistortion_inputScaleKey : @0.5f,
		CILightTunnel_inputRadiusKey : @90.0f,
		CILightTunnel_inputRotationKey : @0.0f,
		CIHoleDistortion_inputRadiusKey : @150.0f,
		CICircleSplashDistortion_inputRadiusKey : @150.0f,
		CICircularScreen_inputWidthKey : @6.0f,
		CICircularScreen_inputSharpnessKey : @0.7f,
		CILineScreen_inputAngleKey : @0.0f,
		CILineScreen_inputWidthKey : @6.0f,
		CILineScreen_inputSharpnessKey : @0.7f,
		CIMirror_inputAngleKey : @0.0f
	}];
}