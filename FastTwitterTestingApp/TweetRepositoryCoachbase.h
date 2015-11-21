#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface TweetRepositoryCoachbase : NSObject
- (NSString *)createDocument: (NSDictionary *)dictionary;
- (CBLDocument *)getDocumentById:(NSString *)documentId;
@end
