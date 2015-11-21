import XCTest

class CoachbaseTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCreateDocument() {
        let repo = TweetRepositoryCoachbase()
        let dic = ["name": "Big Party","location":"My House"]
        let documentId = repo.createDocument(dic);
        let document = repo.getDocumentById(documentId);
        
        XCTAssertEqual(document["name"] as! String, "Big Party")
        XCTAssertEqual(document["location"] as! String, "My House")
    }



}
