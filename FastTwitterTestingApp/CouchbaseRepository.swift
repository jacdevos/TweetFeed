
import Foundation
enum CouchbaseRepositoryError: ErrorType {
    case DatabaseCouldNotBeCreated
}
class CouchbaseRepository {
    private var database : CBLDatabase? = nil
    private let manager : CBLManager
    
    init(dbName : String) throws {
        self.manager = CBLManager.sharedInstance()

        do {
             try self.database = self.manager.databaseNamed(dbName)
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
            //print("Document created and written to database, ID = \(docID)")
            return docID;
         }catch let error as NSError {
            print("domain: \(error._domain) code:\(error._code)")
            return nil
        }
    }
    
    func getDocumentById(documentId : String)->NSDictionary?{
        return database!.documentWithID(documentId)?.properties
    }
    
    func getAllDocuments()->[NSDictionary]{
        let query = database!.createAllDocumentsQuery()
        let result = try! query.run()
        var documentDictionaries = [NSDictionary]()
        while let row = result.nextRow() {
            documentDictionaries.append((row.document?.properties)!)
        }
        return documentDictionaries
    }
    
    func deleteAll(){
        try! database!.deleteDatabase()
    }
}
