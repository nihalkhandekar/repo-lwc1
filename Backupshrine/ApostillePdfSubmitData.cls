public class ApostillePdfSubmitData {
    @AuraEnabled
    public static IndividualApplication getData(){
        try {
            return [SELECT Id, Name FROM IndividualApplication LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}