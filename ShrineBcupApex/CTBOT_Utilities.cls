public with sharing class CTBOT_Utilities {
  public static String buildArticleQuery(String whereClause) {
    Id CTBOTKnowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName()
      .get('FAQ')
      .getRecordTypeId();
    String baseQuery = 'SELECT Id, Title, ArticleBody__c FROM Knowledge__kav ';
    if (whereClause.contains('DialogTag__c')) {
      return baseQuery +
        whereClause +
        'AND PublishStatus = \'Online\' AND RecordTypeID = \'' +
        CTBOTKnowledgeRecordTypeId +
        '\'';
    } else {
      return baseQuery +
        whereClause +
        'AND PublishStatus = \'Online\' AND RecordTypeID = \'' +
        CTBOTKnowledgeRecordTypeId +
        '\' UPDATE VIEWSTAT';
    }
  }
}