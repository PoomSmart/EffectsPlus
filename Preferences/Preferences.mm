#import "../Common.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Social/Social.h>
#import <notify.h>

#include <objc/runtime.h>
#include <sys/sysctl.h>

#define fitColor [UIColor systemBlueColor]

@interface PSViewController (EffectsPlus)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)viewDidLoad;
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface UITableViewCell (EffectsPlus)
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;
@end

@interface PSTableCell (EffectsPlus)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier;
@end

@interface EffectsPlusFiltersSelectionController : PSViewController
- (UITableView *)tableView;
@end

@interface EffectsPlusFiltersSelectionController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	NSMutableOrderedSet *_enabledEffects;
	NSMutableOrderedSet *_disabledEffects;
}
@end

static NSBundle *epBundle()
{
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/EffectsPlusPref.bundle"];
}

@implementation EffectsPlusFiltersSelectionController

- (NSString *)title
{
	return @"Select Filters";
}

- (UITableView *)tableView
{
    return (UITableView *)self.view;
}

- (NSMutableArray *)arrayByAddingDefaults
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIPhotoEffectMono"]; [array addObject:@"CIPhotoEffectTonal"];
	[array addObject:@"CIPhotoEffectNoir"]; [array addObject:@"CIPhotoEffectFade"];
	[array addObject:@"CINone"];
	[array addObject:@"CIPhotoEffectChrome"]; [array addObject:@"CIPhotoEffectProcess"];
	[array addObject:@"CIPhotoEffectTransfer"];	[array addObject:@"CIPhotoEffectInstant"];
	return array;
}

- (NSMutableArray *)arrayByAddingPhotoBooths
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIThermal"]; [array addObject:@"CIMirror"];
	[array addObject:@"CIXRay"]; [array addObject:@"CITriangleKaleidoscope"];
	[array addObject:@"CILightTunnel"]; [array addObject:@"CIPinchDistortion"];
	[array addObject:@"CITwirlDistortion"];	[array addObject:@"CIStretch"];
	return array;
}

- (NSMutableArray *)arrayByAddingExternal1
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CISepiaTone"]; [array addObject:@"CIVibrance"];
	[array addObject:@"CIColorMonochrome"]; [array addObject:@"CIColorPosterize"];
	[array addObject:@"CIGloom"]; [array addObject:@"CIBloom"];
	[array addObject:@"CISharpenLuminance"]; [array addObject:@"CILinearToSRGBToneCurve"];
	[array addObject:@"CIPixellate"];
	return array;
}

- (NSMutableArray *)arrayByAddingExternal2
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIGaussianBlur"]; [array addObject:@"CIFalseColor"];
	[array addObject:@"CIWrapMirror"]; [array addObject:@"CIColorInvert"];
	[array addObject:@"CIHoleDistortion"]; [array addObject:@"CICircleSplashDistortion"];
	[array addObject:@"CICircularScreen"]; [array addObject:@"CILineScreen"];
	return array;
}

- (NSMutableArray *)arrayByAddingExtras
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObjectsFromArray:[self arrayByAddingExternal1]];
	[array addObjectsFromArray:[self arrayByAddingExternal2]];
	[array addObjectsFromArray:[self arrayByAddingPhotoBooths]];
	return array;
}

- (void)toggleFiltersArray
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
		@"Default",
		@"Enable All",
		@"Disable All",
		@"Photo Booth",
		@"Extra Set #1",
		@"Extra Set #2",
		@"All Extra Enabled",
		nil];
	sheet.tag = 9596;
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (popup.tag == 9596) {
		switch (buttonIndex) {
			case 0:
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]];
				break;
			case 1:
				[_enabledEffects addObjectsFromArray:_disabledEffects.array];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
				break;
			case 2:
				[_disabledEffects addObjectsFromArray:_enabledEffects.array];
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
				break;
			case 3:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingPhotoBooths]];
				NSMutableArray *array3 = [NSMutableArray array];
				[array3 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array3 addObjectsFromArray:[self arrayByAddingExternal1]];
				[array3 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array3];
				break;
			}
			case 4:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal1]];
				NSMutableArray *array4 = [NSMutableArray array];
				[array4 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array4 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array4 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array4];
				break;
			}
			case 5:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal2]];
				NSMutableArray *array5 = [NSMutableArray array];
				[array5 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array5 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array5 addObjectsFromArray:[self arrayByAddingExternal1]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array5];
				break;
			}
			case 6:
			{
				NSMutableArray *array6 = [NSMutableArray array];
				[array6 addObjectsFromArray:[self arrayByAddingExternal1]];
				[array6 addObjectsFromArray:[self arrayByAddingExternal2]];
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:array6];
				NSMutableArray *array7 = [NSMutableArray array];
				[array7 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array7 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array7];
				break;
			}
		}
		[self saveSettings];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self.tableView reloadData];
	} else
		[super actionSheet:popup clickedButtonAtIndex:buttonIndex];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	for (UIView *viewThree in cell.subviews) {
		if ([[[viewThree class] description] isEqualToString:@"UITableViewCellScrollView"]) {
			for (UIView *viewFour in viewThree.subviews) {
				if ([[[viewFour class] description] isEqualToString:@"UITableViewCellReorderControl"]) {
					for (UIImageView *viewFive in viewFour.subviews) {
						UIImage *defaultIcon = viewFive.image;
						viewFive.image = [defaultIcon _flatImageWithColor:[UIColor blackColor]];
					}
				}
			}
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.tableView setAllowsSelectionDuringEditing:YES];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EffectCell"];
	[self.tableView setEditing:YES];
	//[self changeReorderColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 0 ? _enabledEffects.count : _disabledEffects.count;
}

- (BOOL)tableView:(UITableView *)view shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)view shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Enabled Filters";
		case 1: return @"Disabled Filters";
	}
	return nil;
}

- (void)saveSettings
{
	NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
	if (prefDict == nil)
		prefDict = [NSMutableDictionary dictionary];
	prefDict[ENABLED_EFFECT] = _enabledEffects.array;
	prefDict[DISABLED_EFFECT] = _disabledEffects.array;
	[prefDict.copy writeToFile:PREF_PATH atomically:YES];
	notify_post(PreferencesChangedNotification);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row == toIndexPath.row && fromIndexPath.section == toIndexPath.section)
		return;
	if (fromIndexPath.section == 0 && toIndexPath.section == 0) {
		NSObject *o = [_enabledEffects[fromIndexPath.row] retain];
    	[_enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_enabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 1) {
		NSObject *o = [_disabledEffects[fromIndexPath.row] retain];
    	[_disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_disabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 0 && toIndexPath.section == 1) {
		NSObject *o = [_enabledEffects[fromIndexPath.row] retain];
    	[_enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_disabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 0) {
		NSObject *o = [_disabledEffects[fromIndexPath.row] retain];
    	[_disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_enabledEffects insertObject:o atIndex:toIndexPath.row];
    }
	[self saveSettings];
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateFilterNameColor];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		UIBarButtonItem *toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
			((UINavigationItem *)[super navigationItem]).rightBarButtonItem = toggleBtn;
		
		NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
		
		_enabledEffects = prefDict[ENABLED_EFFECT] != nil ?
							[NSMutableOrderedSet orderedSetWithArray:prefDict[ENABLED_EFFECT]] :
							[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]];
		_disabledEffects = prefDict[DISABLED_EFFECT] != nil ?
							[NSMutableOrderedSet orderedSetWithArray:prefDict[DISABLED_EFFECT]] :
							[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]];

		[self saveSettings];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self.tableView reloadData];
	}
	return self;
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.autoresizingMask = 1;
	self.view = tableView;
}

- (void)updateFilterNameColor
{
	NSMutableArray *enabledIndexArray = [NSMutableArray array];
	NSUInteger enabledIndexCount = [self.tableView numberOfRowsInSection:0];
	for (NSUInteger i = 0; i < enabledIndexCount; i++) {
		NSIndexPath *enabledIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
		[enabledIndexArray addObject:enabledIndexPath];
		UITableViewCell *enabledCell = [self.tableView cellForRowAtIndexPath:enabledIndexPath];
		enabledCell.textLabel.textColor = enabledIndexCount == 9 ? fitColor : [UIColor blackColor];
	}
	NSMutableArray *disabledIndexArray = [NSMutableArray array];
	NSUInteger disabledIndexCount =  [self.tableView numberOfRowsInSection:1];
	for (NSUInteger i = 0; i < disabledIndexCount; i++) {
		NSIndexPath *disabledIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
		[disabledIndexArray addObject:disabledIndexPath];
		UITableViewCell *disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
		disabledCell.textLabel.textColor = [UIColor blackColor];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *const CellIdentifier = [NSString stringWithFormat:@"eff %ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UIColor *stockColor = [UIColor colorWithRed:.8 green:.9 blue:.9 alpha:1];
	UIColor *pbColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	NSArray *pbArray = [self arrayByAddingPhotoBooths];
	NSBundle *plBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"];
	UIImage *FilterOn = [UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle];
	UIImage *Filter = [UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle];
	UIImage *PB = [UIImage imageNamed:@"PB" inBundle:epBundle()];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		[cell.textLabel setNumberOfLines:1];
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
		cell.textLabel.textColor = [UIColor blackColor];
	}

	BOOL index0 = indexPath.section == 0;
	NSMutableOrderedSet *effectDict = index0 ? _enabledEffects : _disabledEffects;
	NSUInteger filterCount = effectDict.count;
	cell.textLabel.textColor = _enabledEffects.count == 9 && index0 ? fitColor : [UIColor blackColor];
	if (filterCount - 1 >= indexPath.row) {
		NSString *effectName = [effectDict objectAtIndex:indexPath.row];
		[cell.textLabel setText:displayNameFromCIFilterName(effectName)];
		if ([effectName hasPrefix:@"CIPhotoEffect"]) {
			[cell setBackgroundColor:stockColor];
			[[cell imageView] setImage:FilterOn];
		} else {
			BOOL pb = NO;
			for (NSString *name in pbArray) {
				if ([name isEqualToString:effectName]) {
					pb = YES;
					break;
				}
			}
			if (pb) {
				[[cell imageView] setImage:PB];
				[cell setBackgroundColor:pbColor];
			} else {
				[[cell imageView] setImage:Filter];
				[cell setBackgroundColor:[UIColor clearColor]];
			}
		}
	}
    return cell;
}

@end

@interface EffectsPlusFiltersSettingsController : PSListController
@end

@implementation EffectsPlusFiltersSettingsController

- (void)hideKeyboard
{
	[[super view] endEditing:YES];
}

- (id)init
{
	if (self == [super init])
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"⏬" style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)] autorelease];
	return self;
}

- (void)setInput:(id)value forSpecifier:(PSSpecifier *)spec
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	if ([formatter numberFromString:(NSString *)value] != nil) {
		float floatValue = [value floatValue];
		if (floatValue < 0)
			value = @0;
	} else
		value = @0;
	[formatter release];
	[self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self reloadSpecifier:spec animated:NO];
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"FiltersSettings" target:self]] retain];			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

@end

@interface EffectsPlusPrefController : PSListController
@end

@implementation EffectsPlusPrefController

- (void)donate:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:PS_DONATE_URL]];
}

- (void)twitter:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:PS_TWITTER_URL]];
}

- (void)love
{
	SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
	[twitter setInitialText:@"#EffectsPlus by @PoomSmart is awesome!"];
	if (twitter != nil)
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
}

- (id)init
{
	if (self == [super init]) {
		UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
		[heart setImage:[UIImage imageNamed:@"Heart" inBundle:epBundle()] forState:UIControlStateNormal];
		[heart sizeToFit];
		[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
	}
	return self;
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"EffectsPlusPref" target:self]] retain];			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

@end
