/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZIMSqlDropViewStatement.h"

@implementation ZIMSqlDropViewStatement

- (id) initWithXmlSchema: (NSData *)xml error: (NSError **)error {
	if ((self = [super init])) {
		_view = nil;
		_exists = NO;
        //_depth = 0;
        _counter = 0;
        _error = error;
        if (xml != nil) {
			NSXMLParser *parser = [[NSXMLParser alloc] initWithData: xml];
			[parser setDelegate: self];
			[parser parse];
			[parser release];
		}
	}
	return self;
}

- (id) init {
    NSError *error;
    return [self initWithXmlSchema: nil error: &error];
}

- (void) dealloc {
	[super dealloc];
}

- (void) view: (NSString *)view {
	[self view: view exists: NO];
}

- (void) view: (NSString *)view exists: (BOOL)exists {
	_view = [ZIMSqlExpression prepareIdentifier: view];
	_exists = exists;
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendString: @"DROP VIEW "];
	
	if (_exists) {
		[sql appendString: @"IF EXISTS "];
	}
	
	[sql appendString: _view];
	
	[sql appendString: @";"];
	
	return sql;
}

- (void) parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
    if (_counter < 1) {
        if ([element isEqualToString: @"view"]) {
            [self view: [attributes objectForKey: @"name"]];
        }
    }
}

- (void) parser: (NSXMLParser *)parser didEndElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    if ([element isEqualToString: @"view"]) {
		_counter++;
	}
}

- (void) parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)error {
    if (_error) {
        *_error = error;
    }
}

@end
