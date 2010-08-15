//
//  XmlParser.h
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class LojbanWord;
@class Translation;

@interface LojbanDictionaryXmlParser : NSObject<NSXMLParserDelegate> {
	NSXMLParser* xmlParser;
	
	BOOL captureContent;
	NSMutableString* currentContent;
	
	LojbanWord* currentLojbanWord;
	NSMutableSet* lojbanWords;
	NSMutableSet* translations;
}

-(id) initWithXmlAt: (NSString*) path;
-(void) parse;
@property (readonly) NSSet* lojbanWords;
@property (readonly) NSSet* translations;

@end
