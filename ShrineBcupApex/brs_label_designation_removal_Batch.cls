Public without sharing class brs_label_designation_removal_Batch implements Database.Batchable<sObject> {
    public String query;
        
    public brs_label_designation_removal_Batch()
    {
        
        query='select id,Org_Name__c,Individual_Salutation__c,Org_Name_Indexed__c,CreatedDate from UCC_Related_Info__c where Org_Name__c!=null and Org_Name_Indexed__c like \'%Partnership\'';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
 }
     public void execute(Database.BatchableContext BC, List < UCC_Related_Info__c > UCCdata){
         List<UCC_Related_Info__c> ucclistdata=new List<UCC_Related_Info__c>();
for(UCC_Related_Info__c acc:UCCdata)
{
    
String searchString= acc.Org_Name__c;
List<Legal_Designation__mdt> listOfDesignators =[
              SELECT Label 
              FROM Legal_Designation__mdt];
                  List<Business_Name_Noisewords__mdt> listOfNoiseWords = [SELECT Label 
              FROM Business_Name_Noisewords__mdt];
          searchString = ' ' + (searchString).normalizeSpace() + ' ';
                  for(Business_Name_Noisewords__mdt noiseWrd : listOfNoiseWords) {
                      if((searchString != '' || searchString != null) && noiseWrd.Label!='.' && (searchString.containsIgnoreCase(noiseWrd.Label))){
                          if(!(noiseWrd.Label).isAlpha()){
                              searchString = ' ' + (((searchString).toUpperCase()).replace((noiseWrd.Label).toUpperCase(), ' ').normalizeSpace()) + ' ';
                          }
                          else{
                              searchString = ' ' + (((searchString).toUpperCase()).replace((' '+noiseWrd.Label+' ').toUpperCase(), '  ')) + ' ';//.normalizeSpace()
                          }
                      }
                  }
                  for(Legal_Designation__mdt desgn : listOfDesignators) {                    
                      if((' '+searchString+' ').containsIgnoreCase(' '+desgn.Label+' ')){
                          Integer matchCount = (searchString.toUpperCase()).countMatches((desgn.Label).toUpperCase());
                          if(matchCount >= 1){
                              for(Integer i=0; i<matchCount; i++){
                                  searchString= ' ' + (((searchString).toUpperCase()).replace(((' '+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                              }
                          }
                      }
                      if((' '+searchString+' ').containsIgnoreCase('.'+desgn.Label+' ')){
                          searchString= ' ' + (((searchString).toUpperCase()).replace((('.'+desgn.Label+' ').toUpperCase()), ' ').normalizeSpace()) + ' ';
                      }
                      if((' '+searchString+' ').containsIgnoreCase(' '+desgn.Label+'.')){
                          searchString= ' ' + (((searchString).toUpperCase()).replace(((' '+desgn.Label+'.').toUpperCase()), ' ').normalizeSpace()) + ' ';
                      }
                  } 
                  searchString = Accents.removeDiacritics(searchString);
                  searchString = ((searchString).remove('.').toUpperCase().normalizeSpace()).deleteWhitespace();
          acc.Org_Name_Indexed__c=searchString;
          acc.Individual_Salutation__c='';
          ucclistdata.add(acc);
}
Update ucclistdata;
  }
     public void finish(Database.BatchableContext BC){
     
 }
  }