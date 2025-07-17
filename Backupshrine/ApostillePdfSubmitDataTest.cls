@isTest(SeeAllData=false)
public class ApostillePdfSubmitDataTest {

    @isTest(SeeAllData=false)
    public static void testGetDataSuccess()
    {
		RegulatoryAuthorizationType regAuthType = new RegulatoryAuthorizationType(
		Name = 'TestRegulatoryAuthorizationType'
        );
		insert regAuthType;

        IndividualApplication testApplication = new IndividualApplication(
		LicenseTypeId = regAuthType.Id,
        Category = 'License'
        );
        insert testApplication;
        
	    Test.startTest();
        IndividualApplication result = ApostillePdfSubmitData.getData();
        Test.stopTest();   
    }

	@isTest(SeeAllData=false)
    public static void testGetDataException()
    {
        Test.startTest();
            try {
                ApostillePdfSubmitData.getData();
                System.assert(false, 'Exception should have been thrown');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('No such column'), 'Exception message should indicate an invalid column name');
            }
        Test.stopTest();
    }
}