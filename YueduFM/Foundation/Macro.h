//
//  Macro.h
//  YueduFM
//
//  Created by StarNet on 9/19/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#include <objc/runtime.h>

#pragma mark --------------category property------------------

#define CATEGORY_PROPERTY_GET(type, property) - (type) property { return objc_getAssociatedObject(self, @selector(property)); }
#define CATEGORY_PROPERTY_SET(type, property, setter) - (void) setter (type) property { objc_setAssociatedObject(self, @selector(property), property, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
#define CATEGORY_PROPERTY_GET_SET(type, property, setter) CATEGORY_PROPERTY_GET(type, property) CATEGORY_PROPERTY_SET(type, property, setter)

#define CATEGORY_PROPERTY_GET_NSNUMBER_PRIMITIVE(type, property, valueSelector) - (type) property { return [objc_getAssociatedObject(self, @selector(property)) valueSelector]; }
#define CATEGORY_PROPERTY_SET_NSNUMBER_PRIMITIVE(type, property, setter, numberSelector) - (void) setter (type) property { objc_setAssociatedObject(self, @selector(property), [NSNumber numberSelector: property], OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

#define CATEGORY_PROPERTY_GET_UINT(property) CATEGORY_PROPERTY_GET_NSNUMBER_PRIMITIVE(unsigned int, property, unsignedIntValue)
#define CATEGORY_PROPERTY_SET_UINT(property, setter) CATEGORY_PROPERTY_SET_NSNUMBER_PRIMITIVE(unsigned int, property, setter, numberWithUnsignedInt)
#define CATEGORY_PROPERTY_GET_SET_UINT(property, setter) CATEGORY_PROPERTY_GET_UINT(property) CATEGORY_PROPERTY_SET_UINT(property, setter)

#define CATEGORY_PROPERTY_GET_INT(type, property) CATEGORY_PROPERTY_GET_NSNUMBER_PRIMITIVE(type, property, intValue)
#define CATEGORY_PROPERTY_SET_INT(type, property, setter) CATEGORY_PROPERTY_SET_NSNUMBER_PRIMITIVE(type, property, setter, numberWithInt)
#define CATEGORY_PROPERTY_GET_SET_INT(type, property, setter) CATEGORY_PROPERTY_GET_INT(type, property) CATEGORY_PROPERTY_SET_INT(type, property, setter)

#define CATEGORY_PROPERTY_GET_BOOL(type, property) CATEGORY_PROPERTY_GET_NSNUMBER_PRIMITIVE(type, property, boolValue)
#define CATEGORY_PROPERTY_SET_BOOL(type, property, setter) CATEGORY_PROPERTY_SET_NSNUMBER_PRIMITIVE(type, property, setter, numberWithBool)
#define CATEGORY_PROPERTY_GET_SET_BOOL(type, property, setter) CATEGORY_PROPERTY_GET_INT(type, property) CATEGORY_PROPERTY_SET_INT(type, property, setter)

#define keypath(__path) # __path

#define RGBA(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
//格式: FF00FF, 0xFF00FF, #FF00FF
#define RGBHex(RGB) [UIColor colorWithHexString:RGB]


#define kThemeColor RGBHex(@"#00BDEE")
