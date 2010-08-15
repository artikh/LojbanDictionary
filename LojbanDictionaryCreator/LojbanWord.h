//
//  LojbanWord.h
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LojbanWord :  NSObject

@property (nonatomic, retain) NSString * spelling;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * wordType;
@property (nonatomic, retain) NSString * subtype;
@property (nonatomic, retain) NSString * definition;

@end



