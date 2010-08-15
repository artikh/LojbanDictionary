//
//  LojbanDictionaryCreator.m
//  LojbanDictionaryCreator
//
//  Created by Artem Tikhomirov on 8/6/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import <objc/objc-auto.h>
#import <sqlite3.h>
#import "LojbanWord.h"
#import "Translation.h"
#import "LojbanDictionaryXmlParser.h"

const char* prepareDbFile();
void createDbScheme(sqlite3* database);
NSDictionary* insertLojbanWords(sqlite3* database, NSSet* lojbanWords);
void insertTranslations(sqlite3* database, NSSet* translations, NSDictionary* lojbanPks);


int main (int argc, const char * argv[]) {
	
    objc_startCollectorThread();
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *sourceFilePath = [[fileManager currentDirectoryPath] stringByAppendingPathComponent: @"lojbanWordList.xml"];
	LojbanDictionaryXmlParser *parser = [[LojbanDictionaryXmlParser alloc] initWithXmlAt: sourceFilePath];
	[parser parse];
		
	
	
    sqlite3 *database;
	const char * dbFileName = prepareDbFile();
	
	if (sqlite3_open(dbFileName, &database) == SQLITE_OK) {		
		createDbScheme(database);
		NSDictionary* lojbanPks = insertLojbanWords(database, parser.lojbanWords);
		insertTranslations(database, parser.translations, lojbanPks);				
	} else {
		// Даже в случае ошибки открытия базы закрываем ее для корректного освобождения памяти
		sqlite3_close(database);
		NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}	
    return 0;
}


NSDictionary* insertLojbanWords(sqlite3* database, NSSet* lojbanWords){
	NSMutableDictionary * lojbanWordPrimaryKeys = [[NSMutableDictionary alloc] initWithCapacity: lojbanWords.count];
	sqlite3_stmt *lojbanWordInsertStatement;
	const char *sql = "INSERT INTO lojban_words(spelling, type, definition, notes) VALUES(?, ?, ?, ?)";
	if (sqlite3_prepare_v2(database, sql, -1, &lojbanWordInsertStatement, NULL) != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		exit(1);
	}
	
	for(LojbanWord* word in lojbanWords){			
		sqlite3_bind_text(lojbanWordInsertStatement, 1, word.spelling.UTF8String, -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(lojbanWordInsertStatement, 2, word.wordType.UTF8String, -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(lojbanWordInsertStatement, 3, word.definition.UTF8String, -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(lojbanWordInsertStatement, 4, word.notes.UTF8String, -1, SQLITE_TRANSIENT);
		
		if (sqlite3_step(lojbanWordInsertStatement) != SQLITE_DONE) {
			NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
			exit(2);
		} else {
			int primaryKey = sqlite3_last_insert_rowid(database);
			[lojbanWordPrimaryKeys setObject: [NSNumber numberWithInteger: primaryKey] forKey: word.spelling]; 
		}
		
		sqlite3_reset(lojbanWordInsertStatement);
	}
	
	sqlite3_finalize(lojbanWordInsertStatement);
	return lojbanWordPrimaryKeys;
}

void insertTranslations(sqlite3* database, NSSet* translations, NSDictionary* lojbanPks){
	sqlite3_stmt *translationInsertStatement;
	const char *sql = "INSERT INTO translations(language, text, sense, lojban_word_id) VALUES(?, ?, ?, ?)";
	if (sqlite3_prepare_v2(database, sql, -1, &translationInsertStatement, NULL) != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		exit(3);
	}
	
	for(Translation* translation in translations){			
		NSNumber * fk = [lojbanPks objectForKey: translation.targetLojbanWordName];
		if (fk) {
			sqlite3_bind_text(translationInsertStatement, 1, translation.language.UTF8String, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(translationInsertStatement, 2, translation.text.UTF8String, -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(translationInsertStatement, 3, translation.sense.UTF8String, -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(translationInsertStatement, 4, fk.integerValue);
			
			if (sqlite3_step(translationInsertStatement) != SQLITE_DONE) {
				NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
				exit(4);
			}
			
			sqlite3_reset(translationInsertStatement);
		} else {
			NSLog(@"Found translation word '%@' referencing unknow lojban word '$@'", translation.text, translation.targetLojbanWordName);
		}

	}
	
	sqlite3_finalize(translationInsertStatement);
	
}

void createDbScheme(sqlite3* database) {
	NSString *ddl =
		@"CREATE TABLE lojban_words("
			"id INTEGER PRIMARY KEY,"
			"spelling TEXT UNIQUE NOT NULL,"
			"type TEXT NOT NULL,"
			"definition TEXT NOT NULL,"
			"notes TEXT);"
		"CREATE UNIQUE INDEX lojban_words_spelling_idx ON lojban_words (spelling);"
		"CREATE TABLE translations("
			"id INTEGER PRIMARY KEY,"
			"language TEXT NOT NULL,"
			"text TEXT NOT NULL,"
			"sense TEXT,"
			"lojban_word_id INTEGER,"
			"CONSTRAINT fk FOREIGN KEY (lojban_word_id) REFERENCES lojban_words(id));"
		"CREATE INDEX translations_text_idx ON translations(text);";
	char *errorMessage;
	if(sqlite3_exec(database, [ddl UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
		NSLog(@"Failed to create DB scheme: %s", errorMessage);
}

const char* prepareDbFile() {	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *dbFilePath = [[fileManager currentDirectoryPath] stringByAppendingPathComponent: @"lojbanDictionary.sqlite"];
	if([fileManager fileExistsAtPath: dbFilePath])
		[fileManager removeItemAtPath:dbFilePath error: nil];
	return [dbFilePath UTF8String];
}

