#import "../Common.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

#include <objc/runtime.h>
#include <sys/sysctl.h>

@interface PSViewController (EffectsPlus)
- (void)setView:(id)view;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end

@interface UITableViewCell (EffectsPlus)
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;
@end

@interface PSTableCell (EffectsPlus)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier;
@end

@interface EffectsPlusFiltersSelectionController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
}
@property (nonatomic, retain) NSMutableArray *enabledEffects;
@property (nonatomic, retain) NSMutableArray *disabledEffects;
@property (nonatomic, retain) UIBarButtonItem *toggleBtn;
@end

@implementation EffectsPlusFiltersSelectionController

- (NSString *)title
{
	return @"Select Filters";
}

- (id)table
{
	return nil;
}

- (id)view
{
	return _tableView;
}

- (void)effectAddDefaults:(NSMutableArray *)effects
{
	[effects addObject:@"CIPhotoEffectMono"]; [effects addObject:@"CIPhotoEffectNoir"];
	[effects addObject:@"CIPhotoEffectFade"]; [effects addObject:@"CIPhotoEffectChrome"];
	[effects addObject:@"CIPhotoEffectProcess"]; [effects addObject:@"CIPhotoEffectTransfer"];
	[effects addObject:@"CIPhotoEffectInstant"]; [effects addObject:@"CIPhotoEffectTonal"];
}

- (void)effectAddExtras:(NSMutableArray *)effects
{
	[effects addObject:@"CISepiaTone"];	[effects addObject:@"CIVibrance"];
	[effects addObject:@"CIColorMonochrome"]; [effects addObject:@"CIColorPosterize"];
	[effects addObject:@"CIGloom"]; [effects addObject:@"CIBloom"];
	[effects addObject:@"CISharpenLuminance"]; [effects addObject:@"CILinearToSRGBToneCurve"];
	[effects addObject:@"CIPixellate"]; [effects addObject:@"CIGaussianBlur"];
	[effects addObject:@"CIFalseColor"]; [effects addObject:@"CIWrapMirror"];
	
	[effects addObject:@"CIColorInvert"]; [effects addObject:@"CITwirlDistortion"];
	[effects addObject:@"CIStretch"]; [effects addObject:@"CIMirror"];
	[effects addObject:@"CITriangleKaleidoscope"]; [effects addObject:@"CIPinchDistortion"];
	[effects addObject:@"CIThermal"]; [effects addObject:@"CILightTunnel"];
}

- (void)initEnabledEffects
{
	self.enabledEffects = [NSMutableArray array];
	[self effectAddDefaults:self.enabledEffects];
}

- (void)toggleFiltersArray
{
	NSString *title = self.toggleBtn.title;
	if ([title isEqualToString:@"Reset"]) {
		self.enabledEffects = [NSMutableArray array];
		[self effectAddDefaults:self.enabledEffects];
		self.disabledEffects = [NSMutableArray array];
		[self effectAddExtras:self.disabledEffects];
	}
	else if ([title isEqualToString:@"Enable All"]) {
		[self.enabledEffects addObjectsFromArray:self.disabledEffects];
		self.disabledEffects = [NSMutableArray array];
	}
	else if ([title isEqualToString:@"Disable All"]) {
		[self.disabledEffects addObjectsFromArray:self.enabledEffects];
		self.enabledEffects = [NSMutableArray array];
	}
	[self saveSettings];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[_tableView reloadData];
	[self setToggleTitle];
}

- (void)setToggleTitle
{
	NSString *title = @"Reset";
	NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (prefDict != nil) {
		if ([self.disabledEffects count] == 0)
			title = @"Disable All";
		if ([self.enabledEffects count] == 0)
			title = @"Enable All";
	}
	[self.toggleBtn release];
	self.toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:title style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
	((UINavigationItem *)[super navigationItem]).rightBarButtonItem = self.toggleBtn;
}

- (void)addToggle
{
	if (self.toggleBtn == nil) {
		self.toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:@"" style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
		((UINavigationItem *)[super navigationItem]).rightBarButtonItem = self.toggleBtn;
		[self setToggleTitle];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self addToggle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (prefDict == nil)
		return section == 0 ? NORMAL_EFFECT_COUNT : EXTRA_EFFECT_COUNT;
	switch (section) {
		case 0: {
			if (self.enabledEffects == nil)
				return NORMAL_EFFECT_COUNT;
			return [self.enabledEffects count];
		}
		case 1: {
			if (self.disabledEffects == nil)
				return EXTRA_EFFECT_COUNT;
			return [self.disabledEffects count];
		}
	}
	return 1;
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
	[prefDict setObject:self.enabledEffects forKey:@"EnabledEffects"];
	[prefDict setObject:self.disabledEffects forKey:@"DisabledEffects"];
	[prefDict writeToFile:PREF_PATH atomically:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row == toIndexPath.row && fromIndexPath.section == toIndexPath.section)
		return;
	if (fromIndexPath.section == 0 && toIndexPath.section == 0) {
		NSString *stringToMove = [[self.enabledEffects objectAtIndex:fromIndexPath.row] retain];
    	[self.enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.enabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 1) {
		NSString *stringToMove = [[self.disabledEffects objectAtIndex:fromIndexPath.row] retain];
    	[self.disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.disabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 0 && toIndexPath.section == 1) {
		NSString *stringToMove = [[self.enabledEffects objectAtIndex:fromIndexPath.row] retain];
    	[self.enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.disabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 0) {
		NSString *stringToMove = [[self.disabledEffects objectAtIndex:fromIndexPath.row] retain];
    	[self.disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.enabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
	[self saveSettings];
	[self setToggleTitle];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]) != nil) {		
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setAutoresizingMask:1];
		[_tableView setEditing:YES];
		//[_tableView setAllowsSelectionDuringEditing:YES];
		if ([self respondsToSelector:@selector(setView:)])
			[self setView:_tableView];
		if (self.enabledEffects == nil)
			[self initEnabledEffects];
		if (self.disabledEffects == nil) {
			self.disabledEffects = [NSMutableArray array];
			[self effectAddExtras:self.disabledEffects];
			//[self.disabledEffects addObject:@"CIBloom_CIThermal"];
		}
		NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
		if (prefDict != nil) {
			if ([prefDict objectForKey:@"EnabledEffects"] != nil) {
				self.enabledEffects = [[prefDict objectForKey:@"EnabledEffects"] mutableCopy];
				if ([self.enabledEffects count] == 0)
					self.enabledEffects = [NSMutableArray array];
			}
			if ([prefDict objectForKey:@"DisabledEffects"] != nil) {
				self.disabledEffects = [[prefDict objectForKey:@"DisabledEffects"] mutableCopy];
				if ([self.disabledEffects count] == 0)
					self.disabledEffects = [NSMutableArray array];
			}
		}
	}
	return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"effect"];
	UIColor *stockColor = [UIColor colorWithRed:.8 green:.9 blue:.9 alpha:1];
	UIColor *pbColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	NSArray *pbArray = @[@"CIColorInvert", @"CITwirlDistortion", @"CIStretch", @"CIMirror", @"CITriangleKaleidoscope", @"CIPinchDistortion", @"CIThermal", @"CILightTunnel"];
	NSBundle *plBundle = [NSBundle bundleWithIdentifier:@"com.apple.PhotoLibrary"];
	NSBundle *mainBundle = [NSBundle bundleWithIdentifier:@"com.PS.EffectsPlusPref"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"effect"] autorelease];
		[cell.textLabel setNumberOfLines:0];
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
		[cell.textLabel setFont:[UIFont systemFontOfSize:kFontSize]];
	}
	if (indexPath.section == 0) {
		if ([self.enabledEffects count] - 1 >= indexPath.row) {
			NSString *enabledName = [self.enabledEffects objectAtIndex:indexPath.row];
    		[cell.textLabel setText:displayNameFromCIFilterName(enabledName)];
    		if ([enabledName hasPrefix:@"CIPhotoEffect"]) {
				[cell setBackgroundColor:stockColor];
				[[cell imageView] setImage:[UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle]];
			}
    		else {
    			int i = 0;
    			for (NSString *name in pbArray) {
    				if ([name isEqualToString:enabledName])
    					i++;
    			}
    			if (i > 0) {
    				[[cell imageView] setImage:[UIImage imageNamed:@"PB" inBundle:mainBundle]];
    				[cell setBackgroundColor:pbColor];
    			}
    			else {
    				[[cell imageView] setImage:[UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle]];
    				[cell setBackgroundColor:[UIColor clearColor]];
    			}
    		}
    	}
    }
    else if (indexPath.section == 1) {
    	if ([self.disabledEffects count] - 1 >= indexPath.row) {
    		NSString *disabledName = [self.disabledEffects objectAtIndex:indexPath.row];
    		[cell.textLabel setText:displayNameFromCIFilterName(disabledName)];
    		if ([disabledName hasPrefix:@"CIPhotoEffect"]) {
				[cell setBackgroundColor:stockColor];
				[[cell imageView] setImage:[UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle]];
			}
    		else {
				int i = 0;
    			for (NSString *name in pbArray) {
    				if ([name isEqualToString:disabledName])
    					i++;
    			}
    			if (i > 0) {
    				[[cell imageView] setImage:[UIImage imageNamed:@"PB" inBundle:mainBundle]];
    				[cell setBackgroundColor:pbColor];
    			}
    			else {
    				[[cell imageView] setImage:[UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle]];
    				[cell setBackgroundColor:[UIColor clearColor]];
    			}
			}
    	}
    }
    return cell;
}

- (void)dealloc
{
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	[_tableView release];
	[self.toggleBtn release];
	[super dealloc];
}

@end

@interface EffectsPlusFiltersSettingsController : PSListController
@end

@implementation EffectsPlusFiltersSettingsController

- (void)hideKeyboard
{
	[[super view] endEditing:YES];
}

- (void)addBtn
{
	UIBarButtonItem *hideKBBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"Hide KB" style:UIBarButtonItemStyleBordered
        target:self action:@selector(hideKeyboard)];
	((UINavigationItem *)[super navigationItem]).rightBarButtonItem = hideKBBtn;
	[hideKBBtn release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self addBtn];
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
	[self reloadSpecifier:spec animated:YES];
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"FiltersSettings" target:self]];			
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
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GBQGZL8EFMM86"]];
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"EffectsPlusPref" target:self]];			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

@end


#define EffectsPlusAddMethod(_class, _sel, _imp, _type) \
    if (![[_class class] instancesRespondToSelector:@selector(_sel)]) \
        class_addMethod([_class class], @selector(_sel), (IMP)_imp, _type)
        
id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGRect contentSize) {
	return [self init];
}
        
static __attribute__((constructor)) void __EffectsPlusInit() {
	EffectsPlusAddMethod(PSViewController, initForContentSize:, $PSViewController$initForContentSize$, "@@:{ff}");
}
