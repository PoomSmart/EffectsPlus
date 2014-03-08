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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
	if (prefDict == nil)
		return section == 0 ? 19 : 0;
	switch (section) {
		case 0: {
			NSMutableArray *effects = [[prefDict objectForKey:@"EnabledEffects"] mutableCopy];
			if (effects == nil)
				return 19;
			return [effects count];
		}
		case 1: {
			NSMutableArray *effects = [[prefDict objectForKey:@"DisabledEffects"] mutableCopy];
			if (effects == nil)
				return 0;
			return [effects count];
		}
	}
	return 0;
}

- (BOOL)tableView:(UITableView *)view shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
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
	[prefDict setObject:self.enabledEffects forKey:@"EnabledEffects"];
	[prefDict setObject:self.disabledEffects forKey:@"DisabledEffects"];
	[prefDict writeToFile:PREF_PATH atomically:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.section == 0 && toIndexPath.section == 0) {
		NSString *stringToMove = [self.enabledEffects objectAtIndex:fromIndexPath.row];
    	[self.enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.enabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 1) {
		NSString *stringToMove = [self.disabledEffects objectAtIndex:fromIndexPath.row];
    	[self.disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.disabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 0 && toIndexPath.section == 1) {
		NSString *stringToMove = [self.enabledEffects objectAtIndex:fromIndexPath.row];
    	[self.enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.disabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 0) {
		NSString *stringToMove = [self.disabledEffects objectAtIndex:fromIndexPath.row];
    	[self.disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[self.enabledEffects insertObject:stringToMove atIndex:toIndexPath.row];
    }
    [self saveSettings];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]) != nil) {		
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setAutoresizingMask:1];
		[_tableView setEditing:YES];
		[_tableView setAllowsSelectionDuringEditing:YES];
		if ([self respondsToSelector:@selector(setView:)])
			[self setView:_tableView];
		if (self.enabledEffects == nil) {
			self.enabledEffects = [NSMutableArray array];
			[self.enabledEffects addObject:@"CISepiaTone"]; [self.enabledEffects addObject:@"CIVibrance"];
			[self.enabledEffects addObject:@"CIColorInvert"]; [self.enabledEffects addObject:@"CIColorMonochrome"];
			[self.enabledEffects addObject:@"CIColorPosterize"]; [self.enabledEffects addObject:@"CIGloom"];
			[self.enabledEffects addObject:@"CIBloom"]; [self.enabledEffects addObject:@"CISharpenLuminance"];
			[self.enabledEffects addObject:@"CILinearToSRGBToneCurve"]; [self.enabledEffects addObject:@"CIPixellate"];
			[self.enabledEffects addObject:@"CIGaussianBlur"]; [self.enabledEffects addObject:@"CIFalseColor"];
			[self.enabledEffects addObject:@"CITwirlDistortion"]; [self.enabledEffects addObject:@"CIWrapMirror"];
			[self.enabledEffects addObject:@"CIStretch"]; [self.enabledEffects addObject:@"CIMirror"];
			[self.enabledEffects addObject:@"CITriangleKaleidoscope"]; [self.enabledEffects addObject:@"CIPinchDistortion"];
			[self.enabledEffects addObject:@"CIThermal"];
		}
		NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
		if (prefDict != nil) {
			if ([prefDict objectForKey:@"EnabledEffects"] != nil)
				self.enabledEffects = [[prefDict objectForKey:@"EnabledEffects"] mutableCopy];
			if ([prefDict objectForKey:@"DisabledEffects"] != nil)
				self.disabledEffects = [[prefDict objectForKey:@"DisabledEffects"] mutableCopy];
			else
				self.disabledEffects = [NSMutableArray array];
		}
	}
	return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"effect"];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"effect"] autorelease];
		[cell.textLabel setNumberOfLines:1];
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
		[cell.textLabel setFont:[UIFont systemFontOfSize:kFontSize]];
	}
	if (indexPath.section == 0) {
		if ([self.enabledEffects count] - 1 >= indexPath.row)
    		[cell.textLabel setText:displayNameFromCIFilterName([self.enabledEffects objectAtIndex:indexPath.row])];
    }
    else if (indexPath.section == 1) {
    	if ([self.disabledEffects count] - 1 >= indexPath.row)
    		[cell.textLabel setText:displayNameFromCIFilterName([self.disabledEffects objectAtIndex:indexPath.row])];
    }
    return cell;
}

- (void)dealloc
{
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	[_tableView release];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [super tableView:tableView numberOfRowsInSection:section];
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
