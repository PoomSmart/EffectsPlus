#import "Common.h"

static NSString *localizedString(NSString *string)
{
	if (!isiOS9Up)
		return PLLocalizedFrameworkString(string, nil);
	NSBundle *bundle = [[NSBundle bundleForClass:NSClassFromString(@"CAMViewfinderViewController")] retain];
	NSString *lstring = [[bundle localizedStringForKey:string value:@"" table:@"CameraUI"] retain];
	[bundle release];
	return [lstring autorelease];
}

static NSString *displayNameFromCIFilterName(NSString *name)
{
	#define EPReturn1(name1, name2) if ([name isEqualToString:name2]) return name1
	#define EPReturn(name3, name4) else if ([name isEqualToString:name4]) return name3
	EPReturn1(localizedString(@"FILTER_MONO"), @"CIPhotoEffectMono");
	EPReturn(localizedString(@"FILTER_NOIR"), @"CIPhotoEffectNoir");
	EPReturn(localizedString(@"FILTER_FADE"), @"CIPhotoEffectFade");
	EPReturn(localizedString(@"FILTER_CHROME"), @"CIPhotoEffectChrome");
	EPReturn(localizedString(@"FILTER_NONE"), CINoneName);
	EPReturn(localizedString(@"FILTER_PROCESS"), @"CIPhotoEffectProcess");
	EPReturn(localizedString(@"FILTER_TRANSFER"), @"CIPhotoEffectTransfer");
	EPReturn(localizedString(@"FILTER_INSTANT"), @"CIPhotoEffectInstant");
	EPReturn(localizedString(@"FILTER_TONAL"), @"CIPhotoEffectTonal");
	
	EPReturn(@"Sepia", @"CISepiaTone");
	EPReturn(@"Vibrance", @"CIVibrance");
	EPReturn(@"Invert", @"CIColorInvert");
	EPReturn(@"Replace", @"CIColorMonochrome");
	EPReturn(@"Posterize", @"CIColorPosterize");
	EPReturn(@"Gloom", @"CIGloom");
	EPReturn(@"Bloom", @"CIBloom");
	EPReturn(@"Sharp", @"CISharpenLuminance");
	EPReturn(@"SRGB", @"CILinearToSRGBToneCurve");
	EPReturn(@"Pixel", @"CIPixellate");
	EPReturn(@"Blur", @"CIGaussianBlur");
	EPReturn(@"False", @"CIFalseColor");
	EPReturn(@"Hole", @"CIHoleDistortion");
	EPReturn(@"Twirl", @"CITwirlDistortion");
	EPReturn(@"Circle", @"CICircleSplashDistortion");
	EPReturn(@"Circular", @"CICircularScreen");
	EPReturn(@"Line", @"CILineScreen");
	
	EPReturn(@"X-Ray", @"CIXRay");
	EPReturn(@"Mirrors", @"CIWrapMirror");
	EPReturn(@"Stretch", @"CIStretch");
	EPReturn(@"Mirror", @"CIMirror");
	EPReturn(@"Triangle", @"CITriangleKaleidoscope");
	EPReturn(@"Squeeze", @"CIPinchDistortion");
	EPReturn(@"Thermal", @"CIThermal");
	EPReturn(@"Light Tunnel", @"CILightTunnel");
	return nil;
}

static NSMutableArray *effectsThatNotSupportedModernEditor()
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:CINoneName];
	[array addObject:@"CIMirror"];
	[array addObject:@"CITriangleKaleidoscope"];
	[array addObject:@"CILightTunnel"];
	[array addObject:@"CIPinchDistortion"];
	[array addObject:@"CITwirlDistortion"];
	[array addObject:@"CIStretch"];
	[array addObject:@"CIWrapMirror"];
	[array addObject:@"CIHoleDistortion"];
	[array addObject:@"CICircleSplashDistortion"];
	return array;
}