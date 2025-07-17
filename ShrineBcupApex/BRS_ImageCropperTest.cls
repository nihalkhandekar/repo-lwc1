@isTest
public class BRS_ImageCropperTest {
    @testsetup
    public static void testdata(){
        Mark__c mrk = BRS_TestDataFactory.createMark();
        Mark_Filing__c mrkfiling = BRS_TestDataFactory.createMarkFiling(mrk.id);
        Id MarkRecordTypeId = Schema.SObjectType.Mark_Filing__c.getRecordTypeInfosByName().get('Assignment').getRecordTypeId();
        Mark_Filing__c mrkfiling2 = BRS_TestDataFactory.createMarkFiling1(mrk.id,MarkRecordTypeId,'Assignment');
    }
	@isTest
    public static void saveFileForRegistration() {
        Test.startTest();
        String inputdata = 'jhghgfg.fggfhf,hfg';
        Mark__c objmark = [SELECT id, Name, Image_Path__c FROM Mark__c LIMIT 1];
        Mark_Filing__c objmarkfiling = [SELECT id, Name, Sdoc_Filing_Number__c, Image_Path__c, Filing_Type__c, Mark__c FROM Mark_Filing__c WHERE Filing_Type__c='Registration' LIMIT 1];
        String resp = BRS_ImageCropper.saveFile(inputdata, String.valueOf(objmarkfiling.id));
        System.assertEquals('Success', resp);
        Mark_Filing__c objmarkfiling2 = [SELECT id, Name, Sdoc_Filing_Number__c, Image_Path__c, Filing_Type__c, Mark__c FROM Mark_Filing__c WHERE Filing_Type__c='Assignment' LIMIT 1];
        String resp2 = BRS_ImageCropper.saveFile(inputdata, String.valueOf(objmarkfiling2.id));
        System.assertEquals('Success', resp2);
        Test.stopTest();
    }
    @isTest
    public static void saveFileForAssignment() {
        Test.startTest();
        blob propFileBody;
        string propFileName;
        string propContentType;
        String inputdata = 'jhghgfg.fggfhf,hfg';
        String inputdata2send = 'jhghgfg.fggfhf,hfg';
        Mark__c objmark = [SELECT id, Name, Image_Path__c FROM Mark__c LIMIT 1];
        objmark.Image_Path__c = 'image_path';
        update objmark;
        Mark_Filing__c objmarkfiling = [SELECT id, Name, Sdoc_Filing_Number__c, Image_Path__c, Filing_Type__c, Mark__c FROM Mark_Filing__c WHERE Filing_Type__c='Registration' LIMIT 1];
        List<String> datalist = inputdata.split(',');
                System.debug('datalist -> '+datalist);
                if(datalist.size()>0)
                {
                    propContentType=datalist[0].split(';')[0];
                    propContentType=propContentType.removeStart('data:');
                    inputdata=datalist[1].trim();
                }
                System.debug('basebob -> '+inputdata);
                propFileBody=EncodingUtil.base64Decode(inputdata);                
                
        ContentVersion fileVersion = new ContentVersion(
                ContentLocation = 'S',
                PathOnClient = objmarkfiling.Sdoc_Filing_Number__c + ' - Mark Image' + '.png', 
                Title = objmarkfiling.Sdoc_Filing_Number__c + ' - Mark Image',
                VersionData = propFileBody
            );
        insert fileVersion;
        List<ContentVersion> listFileVersions = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :fileVersion.Id
            ];
        ContentDocumentLink contentDocLinkMark = new ContentDocumentLink(
                ContentDocumentId = listFileVersions.get(0).ContentDocumentId,
                LinkedEntityId = objmark.Id
            );
        insert contentDocLinkMark;
        Mark_Filing__c objmarkfiling2 = [SELECT id, Name, Sdoc_Filing_Number__c, Image_Path__c, Filing_Type__c, Mark__c FROM Mark_Filing__c WHERE Filing_Type__c='Assignment' LIMIT 1];
        String resp2 = BRS_ImageCropper.saveFile(inputdata2send, String.valueOf(objmarkfiling2.id));
        System.assertEquals('Success', resp2);
        Test.stopTest();
    }
}