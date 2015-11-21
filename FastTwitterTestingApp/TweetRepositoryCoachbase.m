
#import "TweetRepositoryCoachbase.h"

@interface TweetRepositoryCoachbase()
@property (nonatomic, strong) CBLDatabase *database;
@property (nonatomic, strong) CBLManager *manager;
@end

@implementation TweetRepositoryCoachbase
- (id)init {
    self = [super init];
    if (self) {
        NSError *error;
        self.manager = [CBLManager sharedInstance];
        if (!self.manager) {
            NSLog(@"Cannot create shared instance of CBLManager");
            return nil;
        }
        self.database = [self.manager databaseNamed:@"couchbaseevents" error:&error];
        if (!self.database) {
            NSLog(@"Cannot create database. Error message: %@", error.localizedDescription);
            return nil;
        }
    }
    return self;
}


- (NSString *)createDocument:(NSDictionary *)dictionary{
    NSError *error;
    
    CBLDocument *doc = [self.database createDocument];
    NSString *docID = doc.documentID;
    CBLRevision *newRevision = [doc putProperties: dictionary error:&error];
    if (newRevision) {
        NSLog(@"Document created and written to database, ID = %@", docID);
    }
    return docID;
}

- (CBLDocument *)getDocumentById:(NSString *)documentId{
     return [self.database documentWithID: documentId];
}
@end
