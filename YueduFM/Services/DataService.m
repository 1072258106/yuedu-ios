//
//  DataService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "DataService.h"

@implementation ServiceCenter (DataService)

- (PPSqliteORMManager* )dataManager {
    static PPSqliteORMManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PPSqliteORMManager alloc] initWithDBFilename:@"database.sqlite"];
    });
    
    return manager;
}

@end

@implementation DataService
- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
    }
    return self;
}
@end
