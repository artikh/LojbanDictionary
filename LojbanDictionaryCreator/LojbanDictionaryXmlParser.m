//
//  XmlParser.m
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LojbanWord.h"
#import "Translation.h"
#import "LojbanDictionaryXmlParser.h"

// Private methods empty category - pretty ugly...
@interface LojbanDictionaryXmlParser()


@end



@implementation LojbanDictionaryXmlParser
	-(id) initWithXmlAt: (NSString*) path {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:path] == NO) {
			@throw [NSException exceptionWithName:@"LojbanDictionaryGeneration" reason:@"AHTUNG! There is no xml source file!" userInfo:nil];
		}
		
		lojbanWords = [[NSMutableSet alloc] initWithCapacity:6000];
		translations = [[NSMutableSet alloc] initWithCapacity:8000];
		
		xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath: path]];
		xmlParser.delegate = self;
		xmlParser.shouldResolveExternalEntities = NO;
		
		return self;
	}

	-(void) parse {		
		[xmlParser parse];
	}

	-(NSSet*) lojbanWords {
		return lojbanWords;
	}

	-(NSSet*) translations {
		return translations;
	}

	-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
		
		if([elementName isEqualToString: @"valsi"]) {			
			[currentLojbanWord release];
			currentLojbanWord = [[LojbanWord alloc] init];
			currentLojbanWord.spelling = [attributeDict objectForKey:@"word"];
			currentLojbanWord.wordType = [attributeDict objectForKey:@"type"];	
		}
		else if([elementName isEqualToString: @"nlword"]){
			Translation  *translation = [[Translation alloc] init];
			translation.text = [attributeDict objectForKey:@"word"];
			translation.sense = [attributeDict objectForKey: @"sense"];
			translation.targetLojbanWordName = [attributeDict objectForKey: @"valsi"];
			translation.language = @"en";			
			[translations addObject: translation];
		} 
		else if([elementName isEqualToString: @"definition"] ||	[elementName isEqualToString: @"notes"])
			captureContent = YES;		
	}
	
	-(void) parser: (NSXMLParser *)parser foundCharacters: (NSString *)characters {
		if (!captureContent) return;
		
		if (currentContent == nil)
			currentContent = [NSMutableString stringWithString: characters];
		else
			[currentContent appendString: characters];
	}
		   
	-(void) parser: (NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
		
		if([elementName isEqualToString: @"valsi"]){
			[lojbanWords addObject: currentLojbanWord];
			[currentLojbanWord release];
			currentLojbanWord = nil;			
		}
		else if([elementName isEqualToString: @"definition"]) {
			if ([currentContent length]) {
				currentLojbanWord.definition = [currentContent copy];
				[currentContent release];
				currentContent = nil;				
			}
		}
		else if([elementName isEqualToString: @"notes"]) {
			if ([currentContent length]) {
				currentLojbanWord.notes = [currentContent copy];
				[currentContent release];
				currentContent = nil;			
			}			
		}
		
		[currentContent release];
		currentContent = nil;
		captureContent = NO;
	}	 
@end
