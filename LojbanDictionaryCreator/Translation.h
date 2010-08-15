//
//  Translation.h
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface Translation :  NSObject  
{
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * sense;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * targetLojbanWordName;

@end



