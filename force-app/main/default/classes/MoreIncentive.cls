public class MoreIncentive {
public Incentive__c inc {get; set;}
public Incentive__c incen {get; set;}
public List<Incentive__c> incList {get; set;}
public id incID {get; set;}
public integer num {get; set;}
//=====Constructor====//
public MoreIncentive() {
inc = new Incentive__c();
incen = new Incentive__c();
incList = new List<Incentive__c>();

//incID = apexPages.currentPage().getParameters().get('id');
//inc = [select id, name, Incentive_Amount__c, Type_of_Incentive__c, Date_of_Incentive__c, Month_Name__c, Related_Incentive__c from Incentive__c];
 }
 
  //============= Save Method==============// 

 public PageReference save(){
     insert inc;
 //============= for Yearly picklist==============// 
         if(inc.Type_of_Incentive__c=='Yearly'){
            incen.Related_Incentive__c = inc.id;
            incen.Incentive_Amount__c = inc.Incentive_Amount__c;
            incen.Type_of_Incentive__c = inc.Type_of_Incentive__c;
            incen.Date_of_Incentive__c = inc.Date_of_Incentive__c;
            incList.add(incen);
         } 
 //============= for Half Yearly picklist==============//
      integer b=0;    
      for(integer i=0; i<=1; i++){ 
       Incentive__c incen = new Incentive__c();
         if(inc.Type_of_Incentive__c=='Half Yearly'){
            incen.Related_Incentive__c = inc.id;
            incen.Incentive_Amount__c = inc.Incentive_Amount__c/2;
            incen.Type_of_Incentive__c = inc.Type_of_Incentive__c;
            incen.Date_of_Incentive__c = inc.Date_of_Incentive__c+b;
            incList.add(incen);
            b=b+180;
         }            
       }  
 //============= for Quarter picklist==============// 
     integer c=0;  
     for(integer i=0; i<=3; i++){
      Incentive__c incen = new Incentive__c();
         if(inc.Type_of_Incentive__c=='Quarterly'){
            incen.Related_Incentive__c = inc.id;
            incen.Incentive_Amount__c = inc.Incentive_Amount__c/4;
            incen.Type_of_Incentive__c = inc.Type_of_Incentive__c;
            incen.Date_of_Incentive__c = inc.Date_of_Incentive__c+c;
            incList.add(incen);
            c=c+90;
         }       
        }
 //============= for Monthly picklist==============//
     integer a=0;
     for(integer i=0; i<=11; i++){
      Incentive__c incen = new Incentive__c();
         if(inc.Type_of_Incentive__c=='Monthly'){
            incen.Related_Incentive__c = inc.id;
            incen.Incentive_Amount__c = inc.Incentive_Amount__c/12;
            incen.Type_of_Incentive__c = inc.Type_of_Incentive__c;
            incen.Date_of_Incentive__c = inc.Date_of_Incentive__c+a;
            incList.add(incen);
            a=a+30;
         }       
        }
        insert incList;  
        PageReference pNext = new PageReference('/'+inc.id);
        pNext.setRedirect(true);  
        return pNext;         
   }
     //============= Cancel Method==============// 

   public PageReference Cancel(){
      PageReference pNext = new PageReference('/a0J/o');
       pNext.setRedirect(true);
       return pNext; 
   } 
}