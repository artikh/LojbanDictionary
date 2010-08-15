// 
//  LojbanWord.m
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LojbanWord.h"


@implementation LojbanWord 

@synthesize spelling;
@synthesize notes;
@synthesize wordType;
@synthesize subtype;
@synthesize definition;

-(NSString*) description {
	return [NSString stringWithFormat: @"%@[%@]: %@", spelling, wordType, definition];
}

@end
