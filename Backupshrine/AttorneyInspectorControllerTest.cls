@isTest
public class AttorneyInspectorControllerTest {
    
    private static Contact createAttorneyContact(String firstName, String lastName, String middleName, String phone) {
        RecordType attorneyInspectorRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Attorney_Inspector' LIMIT 1];
        Contact contact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            MiddleName = middleName,
            Phone = phone,
            RecordTypeId = attorneyInspectorRecordType.Id,
            MailingCity = 'Sample City',
            MailingCountry = 'Sample Country',
            MailingStreet = '456 Sample St',
            MailingPostalCode = '67890'
        );
        insert contact;
        return contact;
    }

    private static void verifyGetAttorneyRecord(String description, String firstName, String lastName, Date transactionFromDate, Date transactionToDate) {
        Map<String, Object> params = new Map<String, Object>{
            'lastname' => lastName,
            'firstname' => firstName,
            'middlename' => '',
            'phonenumber' => '',
            'offsetVal' => 0,
            'pageSize' => 10,
            'sortBy' => 'LastModifiedDate',
            'sortDirection' => 'ASC',
            'transactionFromDate' => transactionFromDate,
            'transactionToDate' => transactionToDate
        };
        String paramsJson = JSON.serialize(params);
		List<Map<String, Object>> results = AttorneyInspectorController.getAttorneyRecord(paramsJson);

        System.assert(!results.isEmpty(), 'Should return at least one attorney record for ' + description);
        System.assertEquals(firstName, results[0].get('FirstName'), 'First name should match for ' + description);
        System.assertEquals(lastName, results[0].get('LastName'), 'Last name should match for ' + description);
    }

    @isTest
    static void testGetAttorneyRecord() {
        createAttorneyContact('Jane', 'Smith', 'B', '0987654321');
        createAttorneyContact('Alice', 'Johnson', 'C', '1122334455');

        Test.startTest();

        // Test case 1: Same transaction dates
        verifyGetAttorneyRecord('Same transaction dates', 'Jane', 'Smith', Date.today(), Date.today());

        // Test case 2: Different transaction dates
        verifyGetAttorneyRecord('Different transaction dates', 'Alice', 'Johnson', Date.today().addDays(-1), Date.today().addDays(1));

        try {
            Map<String, Object> invalidParams = new Map<String, Object>{
                'lastname' => 'NonExistentLastName',
                'firstname' => 'NonExistentFirstName',
                'transactionFromDate' => Date.today().addDays(10),
                'transactionToDate' => Date.today().addDays(20),
                'offsetVal' => -1,
                'pageSize' => 10,
                'sortBy' => 'LastModifiedDate',
                'sortDirection' => 'ASC'
            };
            String invalidParamsJson = JSON.serialize(invalidParams);
            AttorneyInspectorController.getAttorneyRecord(invalidParamsJson);
            System.assert(false, 'Expected an exception for invalid parameters.');
        } catch (Exception e) {
            System.assert(true, 'An exception occurred as expected for invalid parameters.');
        }
        
        String blankInput = '';
		String result = AttorneyInspectorController.capitalizeFirstLetter(blankInput);
		System.assertEquals('', result, 'The result should be an empty string for blank input.');

        Test.stopTest();
    }

    @isTest
    static void testGetAttorneyRecordCount() {
        createAttorneyContact('Jane', 'Smith', 'B', '0987654321');

        Map<String, Object> params = new Map<String, Object>{
            'lastname' => 'Smith',
            'firstname' => 'Jane',
            'middlename' => 'B',
            'phonenumber' => '0987654321',
            'termstart' => null,
            'termend' => null,
            'transactionFromDate' => null,
            'transactionToDate' => null
        };
        String paramsJson = JSON.serialize(params);

        Test.startTest();
        Integer count = AttorneyInspectorController.getAttorneyRecordCount(paramsJson);
        Test.stopTest();

        System.assertEquals(1, count, 'Should return a count of 1 for attorney records');
    }

    @isTest
    static void testGetAttorneyRecordWithNoResults() {
        Map<String, Object> params = new Map<String, Object>{
            'lastname' => 'NonExistent',
            'firstname' => 'No',
            'middlename' => 'Name',
            'phonenumber' => '0000000000',
            'offsetVal' => 0,
            'pageSize' => 10,
            'sortBy' => 'LastModifiedDate',
            'sortDirection' => 'ASC',
            'transactionFromDate' => null,
            'transactionToDate' => null
        };
        String paramsJson = JSON.serialize(params);

        Test.startTest();
        List<Map<String, Object>> results = AttorneyInspectorController.getAttorneyRecord(paramsJson);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return 0 attorney records for non-existent search criteria');
    }

    @isTest
    static void testGetAttorneyRecordCountWithNoResults() {
        Test.startTest();

        // Scenario 1: transactionFromDate = transactionToDate
        Map<String, Object> params1 = new Map<String, Object>{
            'lastname' => 'NonExistent',
            'firstname' => 'No',
            'middlename' => 'Name',
            'phonenumber' => '0000000000',
            'termstart' => Date.today(),
            'termend' => Date.today(),
            'transactionFromDate' => Date.today(),
            'transactionToDate' => Date.today()
        };
        System.assertEquals(0, AttorneyInspectorController.getAttorneyRecordCount(JSON.serialize(params1)),
            'Should return a count of 0 with same transaction dates');

        // Scenario 2: transactionFromDate < transactionToDate
        Map<String, Object> params2 = new Map<String, Object>{
            'lastname' => 'NonExistent',
            'firstname' => 'No',
            'middlename' => 'Name',
            'phonenumber' => '0000000000',
            'termstart' => Date.today(),
            'termend' => Date.today(),
            'transactionFromDate' => Date.today().addDays(-1),
            'transactionToDate' => Date.today()
        };
        System.assertEquals(0, AttorneyInspectorController.getAttorneyRecordCount(JSON.serialize(params2)),
            'Should return a count of 0 with different transaction dates');

        Test.stopTest();
    }
}