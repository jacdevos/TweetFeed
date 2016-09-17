import XCTest

class CoachbaseTests: XCTestCase {

    override func setUp() {
        let repo = try! CouchbaseRepository(dbName: "test")
        repo.deleteAll()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCreateDocument() {
        do {
            let repo = try CouchbaseRepository(dbName: "test")

            let dic = ["name": "Big Party","location":"My House"]
            let documentId = repo.createDocument(dic as NSDictionary)
            let document = repo.getDocumentById(documentId!)
        
            XCTAssertEqual(document!["name"] as? String, "Big Party")
            XCTAssertEqual(document!["location"] as? String, "My House")
        } catch {
            XCTAssertTrue(false,"repo could not be created")
        }
    }
    
    func testReadAllDocuments() {
        do {
            let repo = try CouchbaseRepository(dbName: "test")
            let dic = ["name": "Big Party","location":"My House"]
            repo.createDocument(dic as NSDictionary);
            let dic2 = ["name": "Big Party2","location":"My House"]
            repo.createDocument(dic2 as NSDictionary);
            let all = repo.getAllDocuments()
            
        
            XCTAssertEqual(2, all.count)
           
            XCTAssertEqual(1,  all.filter{$0["name"] as? String == "Big Party"}.count)
            XCTAssertEqual(1,  all.filter{$0["name"] as? String == "Big Party2"}.count)
        } catch {
            XCTAssertTrue(false,"repo could not be created")
        }
    }



}
