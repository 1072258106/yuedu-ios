//
//  DataService.m
//  YueduFM
//
//  Created by StarNet on 9/17/15.
//  Copyright (c) 2015 StarNet. All rights reserved.
//

#import "DataService.h"

@implementation BaseService (DataService)

- (PPSqliteORMManager* )dataManager {
    return [SRV(DataService) manager];
}

@end

@implementation DataService

+ (ServiceLevel)level {
    return ServiceLevelHigh;
}

- (id)initWithServiceCenter:(ServiceCenter*)serviceCenter
{
    self = [super initWithServiceCenter:serviceCenter];
    if (self) {
        _manager = [[PPSqliteORMManager alloc] initWithDBFilename:@"db.sqlite"];
    }
    return self;
}

@end
