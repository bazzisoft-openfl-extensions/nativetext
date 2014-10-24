#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include "NativeTextIPhone.h"
#include "ExtensionKit.h"
#include "ExtensionKitIPhone.h"

using namespace nativetext;


//-------------------------------------
// Container View for UITextFields
//-------------------------------------

@interface NativeTextFieldContainerView : UIView<UITextFieldDelegate>
{
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end


@implementation NativeTextFieldContainerView
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [super touchesCancelled:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    extensionkit::DispatchEventToHaxeInstance(
        textField.tag,
        "nativetext.event.NativeTextEvent",
        extensionkit::CSTRING, "nativetext_focus_in",
        extensionkit::CEND);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    extensionkit::DispatchEventToHaxeInstance(
        textField.tag,
        "nativetext.event.NativeTextEvent",
        extensionkit::CSTRING, "nativetext_focus_out",
        extensionkit::CEND);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    extensionkit::DispatchEventToHaxeInstance(
        textField.tag,
        "nativetext.event.NativeTextEvent",
        extensionkit::CSTRING, "nativetext_change",
        extensionkit::CEND);

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (UIReturnKeyNext == textField.returnKeyType)
    {
        int viewIndex = [self.subviews indexOfObject:textField];
        
        for (int i = viewIndex + 1; i < self.subviews.count; i++)
        {
            UIView* currentSubview = [self.subviews objectAtIndex:i];			
            if (!currentSubview.hidden)
            {
                [currentSubview becomeFirstResponder];
                break;
            }
        }
    }
    
    extensionkit::DispatchEventToHaxeInstance(
        textField.tag,
        "nativetext.event.NativeTextEvent",
        extensionkit::CSTRING, "nativetext_return_key_pressed",
        extensionkit::CEND);
    
    return NO;
}

@end


//--------------------------------------
// UITextField Subclass with Extra State
//--------------------------------------

@interface NativeTextField : UITextField
{
}
- (id)initWithFrame:(CGRect)aRect;
- (void)configure:(const NativeTextFieldConfig&)config;
- (void)setPositionAndSizeFromConfig:(const NativeTextFieldConfig&)config withScale:(double)scale;
- (void)setTextAlignmentFromConfig:(const NativeTextFieldConfig&)config;
- (void)setKeyboardTypeFromConfig:(const NativeTextFieldConfig&)config;
- (void)setReturnKeyTypeFromConfig:(const NativeTextFieldConfig&)config;
@end


@implementation NativeTextField
{
    BOOL m_autosizeWidth;
    BOOL m_autosizeHeight;
}

- (id)initWithFrame:(CGRect)aRect;
{
    self = [super initWithFrame:aRect];
    if (self) 
    {
        self->m_autosizeWidth = YES;
        self->m_autosizeHeight = YES;
    }
    return self;
}

- (void)configure:(const NativeTextFieldConfig&)config
{
    double scale = [[UIScreen mainScreen] scale];
    
    if (config.fontColor.IsSet())
    {
        self.textColor = extensionkit::iphone::UIColorFromRGB(config.fontColor.Value());
    }
    
    if (config.fontSize.IsSet())
    {
        self.font = [self.font fontWithSize:config.fontSize.Value() / scale];
        //self.font = [UIFont systemFontOfSize:config.fontSize.Value() / scale];
    }
    
    [self setPositionAndSizeFromConfig:config withScale:scale];
    
    if (config.visible.IsSet())
    {
        self.hidden = (config.visible.Value() ? NO : YES);
    }
    
    if (config.enabled.IsSet())
    {
        self.enabled = (config.enabled.Value() ? YES : NO);
    }
    
    if (config.placeholder.IsSet())
    {
        self.placeholder = [NSString stringWithUTF8String:config.placeholder.Value().c_str()];
    }
    
    [self setTextAlignmentFromConfig:config];
    [self setKeyboardTypeFromConfig:config];
    [self setReturnKeyTypeFromConfig:config];
}

- (void)setPositionAndSizeFromConfig:(const NativeTextFieldConfig&)config withScale:(double)scale
{
    CGRect frame = self.frame;
    
    if (config.x.IsSet())
    {
        frame.origin.x = config.x.Value() / scale;
    }

    if (config.y.IsSet())
    {
        frame.origin.y = config.y.Value() / scale;
    }
    
    if (config.width.IsSet())
    {
        self->m_autosizeWidth = (config.width.Value() <= 0.0);
        
        if (config.width.Value() > 0.0)
        {
            frame.size.width = config.width.Value() / scale;
        }
    }
    
    if (config.height.IsSet())
    {
        self->m_autosizeHeight = (config.height.Value() <= 0.0);
        
        if (config.height.Value() > 0.0)
        {
            frame.size.height = config.height.Value() / scale;
        }
    }
    
    if (self->m_autosizeWidth)
    {
        frame.size.width = self.intrinsicContentSize.width;
    }

    if (self->m_autosizeHeight)
    {
        frame.size.height = self.intrinsicContentSize.height;
    }
    
    [self setFrame:frame];
}

- (void)setTextAlignmentFromConfig:(const NativeTextFieldConfig&)config
{
    if (!config.textAlignment.IsSet())
    {
        return;
    }
    
    switch (config.textAlignment.Value())
    {
        case NativeTextFieldConfig::TAL_NATURAL:
            self.textAlignment = NSTextAlignmentNatural;
            break;

        case NativeTextFieldConfig::TAL_LEFT:
            self.textAlignment = NSTextAlignmentLeft;
            break;

        case NativeTextFieldConfig::TAL_CENTER:
            self.textAlignment = NSTextAlignmentCenter;
            break;

        case NativeTextFieldConfig::TAL_RIGHT:
            self.textAlignment = NSTextAlignmentRight;
            break;
    }
}

- (void)setKeyboardTypeFromConfig:(const NativeTextFieldConfig&)config
{
    if (!config.keyboardType.IsSet())
    {
        return;
    }
    
    self.secureTextEntry = NO;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    
    switch (config.keyboardType.Value())
    {
        case NativeTextFieldConfig::KB_DEFAULT:
            self.keyboardType = UIKeyboardTypeDefault;
            self.spellCheckingType = UITextSpellCheckingTypeDefault;
            self.autocorrectionType = UITextAutocorrectionTypeDefault;
            break;

        case NativeTextFieldConfig::KB_PASSWORD:
            self.keyboardType = UIKeyboardTypeDefault;
            self.secureTextEntry = YES;
            break;

        case NativeTextFieldConfig::KB_DECIMAL:
            self.keyboardType = UIKeyboardTypeDecimalPad;
            break;

        case NativeTextFieldConfig::KB_NAME:
            self.keyboardType = UIKeyboardTypeDefault;
            self.autocapitalizationType = UITextAutocapitalizationTypeWords;
            break;

        case NativeTextFieldConfig::KB_EMAIL:
            self.keyboardType = UIKeyboardTypeEmailAddress;
            break;

        case NativeTextFieldConfig::KB_PHONE:
            self.keyboardType = UIKeyboardTypePhonePad;
            break;

        case NativeTextFieldConfig::KB_URL:        
            self.keyboardType = UIKeyboardTypeURL;
            break;
    }    
}

- (void)setReturnKeyTypeFromConfig:(const NativeTextFieldConfig&)config
{
    if (!config.returnKeyType.IsSet())
    {
        return;
    }
    
    switch (config.returnKeyType.Value())
    {
        case NativeTextFieldConfig::RK_DEFAULT:
            self.returnKeyType = UIReturnKeyDefault;
            break;
            
        case NativeTextFieldConfig::RK_GO:
            self.returnKeyType = UIReturnKeyGo;
            break;
            
        case NativeTextFieldConfig::RK_NEXT:
            self.returnKeyType = UIReturnKeyNext;
            break;
            
        case NativeTextFieldConfig::RK_SEARCH:
            self.returnKeyType = UIReturnKeySearch;
            break;
            
        case NativeTextFieldConfig::RK_SEND:
            self.returnKeyType = UIReturnKeySend;
            break;
            
        case NativeTextFieldConfig::RK_DONE:
            self.returnKeyType = UIReturnKeyDone;
            break;
    }
}

@end


//-------------------------------------
// External Interface
//-------------------------------------

static NativeTextFieldContainerView* g_textFieldContainerView = NULL;


namespace nativetext
{
    namespace iphone
    {
        //-----------------------------
        // Private Functions
        //-----------------------------
        
        void EnsureTextFieldContainerViewHasBeenCreated()
        {
            if (g_textFieldContainerView == NULL)
            {
                UIView* topView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
                
                g_textFieldContainerView = [[[NativeTextFieldContainerView alloc] initWithFrame:topView.bounds] autorelease];
                
                g_textFieldContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                g_textFieldContainerView.opaque = NO;
                g_textFieldContainerView.userInteractionEnabled = YES;
                
                [topView addSubview:g_textFieldContainerView];
            }
        }
        
        NativeTextField* FindTextFieldById(int eventDispatcherId, bool suppressWarning = false)
        {
            NativeTextField* textField = (NativeTextField*) [g_textFieldContainerView viewWithTag:eventDispatcherId];
            
            if (!suppressWarning && !textField)
            {
                printf("[ERROR] NativeText: Unable to find UITextField with ID=%d.\n", eventDispatcherId);
            }
            
            return textField;
        }        
        
        //-----------------------------
        // Public API
        //-----------------------------

        void InitializeIPhone()
        {
        }
                
        void CreateTextField(int eventDispatcherId)
        {
            EnsureTextFieldContainerViewHasBeenCreated();
            
            if (FindTextFieldById(eventDispatcherId, true))
            {
                printf("[ERROR] NativeText: Trying to create a new EditText with a previously used ID (%d), skipping.", eventDispatcherId);
                return;
            }
            
            CGRect frame = CGRectMake(0, 0, 0, 0);			
            NativeTextField* textField = [[[NativeTextField alloc] initWithFrame:frame] autorelease];
            textField.tag = eventDispatcherId;
            textField.delegate = g_textFieldContainerView;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            frame.size = textField.intrinsicContentSize;
            [textField setFrame:frame];			

            [g_textFieldContainerView addSubview:textField];
        }
        
        void DestroyTextField(int eventDispatcherId)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField)
            {
                [textField removeFromSuperview];
            }
        }
        
        void ConfigureTextField(int eventDispatcherId, const NativeTextFieldConfig& config)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField)
            {
                [textField configure:config];
            }			
        }

        const char* GetText(int eventDispatcherId)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField)
            {
                return [textField.text UTF8String];
            }
            
            return NULL;
        }
        
        void SetText(int eventDispatcherId, const char* text)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField)
            {
                textField.text = [NSString stringWithUTF8String:text];
            }
        }
        
        bool IsFocused(int eventDispatcherId)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField)
            {
                return (YES == textField.isFirstResponder);
            }
            else
            {
                return false;
            }
        }
        
        void SetFocus(int eventDispatcherId)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField && !textField.isFirstResponder)
            {
                [textField becomeFirstResponder];
            }
        }

        void ClearFocus(int eventDispatcherId)
        {
            NativeTextField* textField = FindTextFieldById(eventDispatcherId);
            if (textField && textField.isFirstResponder)
            {
                [textField resignFirstResponder];
            }
        }		
    }
}