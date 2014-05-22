//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

#import "AppHelper.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>
FREContext AppHelperCtx = nil;


@implementation AppHelper

#pragma mark - Singleton

static AppHelper *sharedInstance = nil;

+ (AppHelper *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }

    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}

@end


#pragma mark - C interface

/* This is a TEST function that is being included as part of this template. 
 *
 * Users of this template are expected to change this and add similar functions 
 * to be able to call the native functions in the ANE from their ActionScript code
 */
DEFINE_ANE_FUNCTION(IsSupported)
{
    NSLog(@"Entering IsSupported()");

    FREObject fo;

    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        //things are fine
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        //aResult could be FRE_INVALID_ARGUMENT or FRE_WRONG_THREAD, take appropriate action.
        NSLog(@"Result = %d", aResult);
    }
    
    NSLog(@"Exiting IsSupported()");
    
    return fo;
}

static void AirLowMemoryWarningSuppressor_didReceiveMemoryWarning(id self, SEL _cmd, UIApplication* application)
{
    NSLog(@"application did receive memory warning.");
}

static void AirLowMemoryWarningSuppressor_injectDelegates(id delegate)
{
    Class objectClass = object_getClass(delegate);
    
    NSString *newClassName = [NSString stringWithFormat:@"CustomLowMemory_%@", NSStringFromClass(objectClass)];
    Class modDelegate = NSClassFromString(newClassName);
    if (modDelegate == nil) {
        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
        SEL selectorToOverride = @selector(applicationDidReceiveMemoryWarning:);
        Method m = class_getInstanceMethod(objectClass, selectorToOverride);
        class_addMethod(modDelegate, selectorToOverride, (IMP)AirLowMemoryWarningSuppressor_didReceiveMemoryWarning, method_getTypeEncoding(m));
        objc_registerClassPair(modDelegate);
    }
    object_setClass(delegate, modDelegate);
}


#pragma mark - ANE setup

/* AppHelperExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
 */
void AppHelperExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) 
{
    NSLog(@"Entering AppHelperExtInitializer()");

    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;

    NSLog(@"Exiting AppHelperExtInitializer()");
}

/* AppHelperExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
 */
void AppHelperExtFinalizer(void* extData) 
{
    NSLog(@"Entering AppHelperExtFinalizer()");

    // Nothing to clean up.
    NSLog(@"Exiting AppHelperExtFinalizer()");
    return;
}

DEFINE_ANE_FUNCTION(fireMemoryWarning)
{
    NSLog(@"Entering fireMemoryWarning()");
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationMemoryWarningNotification" object:[UIApplication sharedApplication]];
    
    FREObject fo;
    return FRENewObjectFromBool(YES, &fo);
}

DEFINE_ANE_FUNCTION(doWorkaround)
{
    NSLog(@"Entering doWorkaround()");
    
    AirLowMemoryWarningSuppressor_injectDelegates([[UIApplication sharedApplication] delegate]);

    FREObject fo;
    return FRENewObjectFromBool(YES, &fo);
}


/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSLog(@"Entering ContextInitializer()");

    
    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     * As a sample, the function isSupported is being provided.
     */
    *numFunctionsToTest = 3;

    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &IsSupported;

    func[1].name = (const uint8_t*) "fireMemoryWarning";
    func[1].functionData = NULL;
    func[1].function = &fireMemoryWarning;
    
    func[2].name = (const uint8_t*) "doWorkaround";
    func[2].functionData = NULL;
    func[2].function = &doWorkaround;
    
    *functionsToSet = func;

    AppHelperCtx = ctx;

    NSLog(@"Exiting ContextInitializer()");
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void ContextFinalizer(FREContext ctx) 
{
    NSLog(@"Entering ContextFinalizer()");

    // Nothing to clean up.
    NSLog(@"Exiting ContextFinalizer()");
    return;
}


