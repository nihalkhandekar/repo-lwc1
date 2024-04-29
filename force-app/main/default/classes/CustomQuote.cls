public class CustomQuote {
Public Account acc {get; set;}
Public Contact con {get; set;}
Public Opportunity_Custom__c opp {get; set;}
Public Quote_Custom__c qtt {get; set;}
Public List<Opportunity_Line_Item_Custom__c> OPLCList {get; set;}
Public List<QuotelineItem_Custom__c> QLCList {get; set;}
Public Id OppID {get; set;}

// ====Constructor=====//
public CustomQuote() {
acc = new Account(); 
con = new Contact(); 
opp = new Opportunity_Custom__c(); 
qtt = new Quote_Custom__c(); 
OPLCList = new List<Opportunity_Line_Item_Custom__c>(); 
QLCList = new List<QuotelineItem_Custom__c>(); 

OppID = ApexPages.currentPage().getParameters().get('Id');
system.debug(OppID);// to check in developer console in debug list weather id is generating or not//

//Jisse records niklege un objects ki query//
opp = [select id, name, Account__c, Contact__c, Closed_Date__c, Expected_Revenue__c, Lead_Source__c, Stage__c, Type__c  from Opportunity_Custom__c where id =: OppID  ]; //yha se single record niklega//
OPLCList = [select id, name, Date__c, List_Price__c, Product_Custom__c, Quantity__c, Sales_Price__c, Total_price__c, Opportunity_Custom__c from Opportunity_Line_Item_Custom__c where Opportunity_Custom__c =: OppID]; //yha se multiple records niklege//
system.debug(OPLCList);
//====Ab Mapping Karenge===//
//====Jha se fetch krna(opportunity) hai vo RHS and Jha feed krna(quote) hai to LHS===//
qtt.Opportunity_Custom__c = opp.id; 
qtt.Account__c= opp.Account__c;
qtt.Contact__c= opp.Contact__c;

//====Multiple OppLineItems ko multiple qttlineItems me dalna hai bari bari usk liye for each loop lgaege===//
for(Opportunity_Line_Item_Custom__c opl : OPLCList){          // loop me dono obj k instance variable bnege fields add krne k liye// 
QuotelineItem_Custom__c qli = new QuotelineItem_Custom__c(); // local instance to store single instance values// 
qli.Name = opl.Name;                    //yha local instance of opp line item se local instance of quote line item me data daal rhe hai//
qli.Sales_Price__c = opl.Sales_Price__c;                    //yha local instance of opp line item se local instance of quote line item me data daal rhe hai//
qli.Quantity__c = opl.Quantity__c ;
qli.Product_Custom__c =opl.Product_Custom__c;
// yha quote obj abhi insert nhi hua hai to uski id map nhi ho skti// 
QLCList.add(qli); //yha pr khali quoteline item ki list me new quote line item ka variable add kiya hai jisme values map ki hi// 
  }        
 } 
   //=============Buttons==============//
  
    public PageReference SaveRecord() {
    insert qtt;  //phle qtt ko insert kiya taki uski id(qtt.id) generate ho aur quotelineitem me daal ske//
    //par quotelineitem to multiple hai so again for loop lgega//
    for(QuotelineItem_Custom__c ql : QLCList ){ //ab QLCList me data present hai// 
    ql.Quote_Custom__c = qtt.id;  //quote line item k andr jo master detail api hoga quote ka usko quote ki id se map krna hai//
     }
    //ab insert kro quote line item ki list//
    insert  QLCList;
    PageReference Pnext = new PageReference('/'+OppId);
    return Pnext;
   }
        //=========Cancel Method============//        
    public PageReference CancelRecord() {
    PageReference Pnext = new PageReference('/'+OppId);
    pNext.setRedirect(true);
    return Pnext;
    }
}