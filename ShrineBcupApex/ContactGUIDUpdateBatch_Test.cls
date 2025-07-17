@isTest
private class ContactGUIDUpdateBatch_Test {
	@isTest
    private static void testContactGUIDUpdateBatch(){
        Test.startTest();
        ContactGUIDUpdateBatch batch = new ContactGUIDUpdateBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}