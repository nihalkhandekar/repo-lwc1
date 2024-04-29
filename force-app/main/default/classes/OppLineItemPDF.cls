public class OppLineItemPDF {
Public Opportunity_Custom__c opp {get; set;}
Public List<Opportunity_Line_Item_Custom__c> OPLCList {get; set;}
Public id OppID {get; set;}
// ====Constructor=====//
public OppLineItemPDF() {
opp = new Opportunity_Custom__c(); 
OPLCList = new List<Opportunity_Line_Item_Custom__c>(); 
OppID = ApexPages.currentPage().getParameters().get('Id');
opp = [select id, name, Account__c, Contact__c, Closed_Date__c, Expected_Revenue__c, Lead_Source__c, Stage__c, Type__c  from Opportunity_Custom__c where id =: OppID];
OPLCList = [select id, name, Date__c, List_Price__c, Product_Custom__c, Quantity__c, Sales_Price__c, Total_price__c, Opportunity_Custom__c from Opportunity_Line_Item_Custom__c where Opportunity_Custom__c =: OppID]; //yha se multiple records niklege//
for(Opportunity_Line_Item_Custom__c opL :OPLCList){
system.debug(opL);
 }
    }
}