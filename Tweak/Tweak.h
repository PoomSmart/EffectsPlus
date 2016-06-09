#import "../Common.h"

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