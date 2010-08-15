// 
//  Translation.m
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Translation.h"


@implementation Translation 
@synthesize text; 
@synthesize sense;
@synthesize language;
@synthesize targetLojbanWordName;

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ (%@) in %@ is lojban valsi '%@'", text, sense, language, targetLojbanWordName]; 
}
@end
