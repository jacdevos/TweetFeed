
import Foundation
enum CouchbaseRepositoryError: ErrorType {
    case DatabaseCouldNotBeCreated
}
class CouchbaseRepository {
    private var database : CBLDatabase? = nil
    private let manager : CBLManager
    
    init() throws {
        self.manager = CBLManager.sharedInstance()

        do {
             try self.database = self.manager.databaseNamed("couchbaseevents")
        } catch let error as NSError {
            print("domain: \(error._domain) code:\(error._code)")
            throw CouchbaseRepositoryError.DatabaseCouldNotBeCreated
        }

    }
    
    func createDocument(dictionary : NSDictionary) -> String?{
        let doc = database!.createDocument()
        let docID = doc.documentID
         do {
            try doc.putProperties(dictionary as! [String : AnyObject])
            print("Document created and written to database, ID = \(docID)")
            return docID;
         }catch let error as NSError {
            print("domain: \(error._domain) code:\(error._code)")
            return nil
        }
    }
    
    func getDocumentById(documentId : String)->CBLDocument?{
        return database!.documentWithID(documentId)
    }
    
    /*
    func getAllDocuments(->[CBLDocument]{
        if let db = database{
            return db.documentWithID(documentId)
        }
        
        return nil
    }*/
}
