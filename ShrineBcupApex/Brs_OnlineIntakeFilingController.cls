global without sharing class Brs_OnlineIntakeFilingController {
    global with sharing class Requests {
        @InvocableVariable
        global string recordid;
        @InvocableVariable
        global string workorderid;
        @InvocableVariable
        global string businesstype;
        @InvocableVariable
        global string citizenship;
        @InvocableVariable
        global string legalStructure;
        @InvocableVariable
        global string category;
        @InvocableVariable
        global string Customer;
        
        @InvocableVariable
        global string accountId;
        
        @InvocableVariable
        global Decimal totalStock;
        
        @InvocableVariable
        global string businessSubtype;
        @InvocableVariable
        global Decimal FranchiseTax;
        @InvocableVariable
        global string selectedaccountID;
        @InvocableVariable
        global DateTime wrkOrderReceivedDate;
        
    } 
    global with sharing class Results {
        @InvocableVariable
        global string recordid;
        @InvocableVariable
        global string workorderid;
    }
    
    
    @InvocableMethod
    public static List<Results> createWorkorderandBusinessFiling(List<Requests> requestparams) {
        
        String filingId = requestparams[0].recordid;
        String workorderId = requestparams[0].workorderid;
        String businessType = requestparams[0].businesstype;
        String businessSubType = requestparams[0].businessSubtype; //
        String citizenship = requestparams[0].citizenship;
        String legalstructure = requestparams[0].legalStructure;
        String category = requestparams[0].category;
        String customer = requestparams[0].Customer;
        String accountID = requestparams[0].accountId;
        Decimal totalStock = requestparams[0].totalStock;
        
        List<Results> lstResults = new List<Results>();
        Results r = new Results();

        Decimal FranchiseTax=requestparams[0].FranchiseTax;
        String selectedaccountID = requestparams[0].selectedaccountID;
        Work_Order__c order = new Work_Order__c();
        
        if(String.isNotBlank(workorderId)){
            order.id = workorderId;
        }
        order.Type__c = 'Business';
        order.Source__c = 'Digital Mail';
        order.Status__c = 'In-Progress';
        order.Customer__c = customer;
       
        Datetime receivedDateTime = requestparams[0].wrkOrderReceivedDate;

        // Integer offset = UserInfo.getTimezone().getOffset(receivedDateTime);
        
        // Datetime convertedDateTime = receivedDateTime.addSeconds(offset/1000);
        
        // Date receivedDate = Date.valueOf(convertedDateTime);
      
        
        Datetime convertedDateTime = receivedDateTime;
        
        Date receivedDate = Date.valueOf(convertedDateTime);


order.Received_Date__c =convertedDateTime;

        System.debug('order ### 1'+order);

        System.debug('System.today() ### 1'+System.today());
        Business_Filing__c filing = new Business_Filing__c();
        if(String.isNotBlank(filingId)){
            filing.id = filingId;
        }
        if(String.isNotBlank(category) && category.equalsIgnoreCase('Register a business')){
            order.Last_In_Progress_Flow__c = 'Back_Office_New_Business';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.RecordTypeId = storeRecordTypeId;
            if(String.isNotBlank(businessType) && businessType == 'Domestic'){
                filing.Type__c = 'Business Formation';
            }else{
                filing.Type__c = 'Business Registration';
            }
            filing.Citizenship__c = businessType;
            filing.Business_Type__c = legalstructure;
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            filing.Effective_Time__c = convertedDateTime.time();
            
            if(filing.Business_Type__c!=null && ((filing.Business_Type__c == 'Stock'
            ||filing.Business_Type__c == 'B Corp'
            ||filing.Business_Type__c == 'Cooperative Association'
            ||filing.Business_Type__c == 'Bank Stock'
            ||filing.Business_Type__c == 'Credit Union Stock'
            ||filing.Business_Type__c == 'Insurance Stock'
            ))){
                if(totalStock!=null){
                    filing.Total_Authorized_Shares__c = totalStock;
                }
                else{
                    filing.Total_Authorized_Shares__c = 1;
                }                
               
            }
            if(businessType == 'Domestic'){
                if( legalstructure=='Limited Partnership'){filing.Filing_Type__c='Certificate of Limited Partnership';}
                if( legalstructure=='Statutory Trust'){filing.Filing_Type__c='Certificate of Trust';}
                if( legalstructure=='General Partnership'){filing.Filing_Type__c='Statement of Partnership Authority';}
                if( legalstructure=='Limited Liability Company'){filing.Filing_Type__c='Certificate of Organization';}
                if( legalstructure=='Limited Partnership'){filing.Filing_Type__c='Certificate of Limited Partnership';}
                if( legalstructure=='Limited Liability Partnership'){filing.Filing_Type__c='Certificate of Limited Liability Partnership';}
                if( (legalstructure=='Bank Stock'|| legalstructure=='Bank Non-Stock'|| legalstructure=='Insurance Stock'|| legalstructure=='Insurance Non-Stock'|| legalstructure=='Credit Union Stock'|| legalstructure=='Credit Union Non-Stock'|| legalstructure=='Non-Stock Corporation'|| legalstructure=='Stock Corporation'|| legalstructure=='Benefit Corporation')){filing.Filing_Type__c='Certificate of Incorporation';}
            }
            if(businessType == 'Foreign'){
                if((legalstructure=='Non-Stock Corporation'|| legalstructure=='Stock Corporation'|| legalstructure=='Cemetary' || legalstructure=='Limited Liability Partnership')){filing.Filing_Type__c='Certificate of Authority';}
                if( (legalstructure=='Statutory Trust'|| legalstructure=='Limited Partnership')){filing.Filing_Type__c='Certificate of Registration';}
                if( legalstructure=='Limited Liability Company'){filing.Filing_Type__c='Foreign Registration Statement';}
            }
           
        }
        else if(String.isNotBlank(category) && (category.equalsIgnoreCase('Update business information')|| 
                                                category.equalsIgnoreCase('Update agent information')  )){
                                                    order.Last_In_Progress_Flow__c = 'Back_Office_Maintenance_Flow';
                                                    ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
                                                    filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
                                                    filing.RecordTypeId = storeRecordTypeId;
                                                    system.debug('businessType >> '+ businessType);
                                                    if(businessType=='Business Address Change'){
                                                        filing.Type__c = 'Change of Business Address';
                                                    }
                                                    else{
                                                        filing.Type__c = businessType;
                                                    }
                                                    if(category.equalsIgnoreCase('Update agent information')|| filing.Type__c!='Amendment'){
                                                        if(businessType=='Change of Agent Address'){
                                                            filing.Filing_Type__c =  'Agent Address Change'; 
                                                        }
                                                        else if(businessType=='Change of Agent'){
                                                            filing.Filing_Type__c =  'Agent Change'; 
                                                        }
                                                        else{ 
                                                        	 filing.Filing_Type__c =  businessType;
                                                        }
                                                      
                                                    }
                                                    
                                 filing.Effective_Date__c = receivedDate;
                                 filing.Effective_Date_Time__c = convertedDateTime;
                                 filing.Effective_Time__c = convertedDateTime.time();
                                                    if(String.isNotBlank(accountID)){
                                                        filing.Account__c = accountID;
                                                        if(filing.Type__c=='Amendment'){
                                                            if(filing.Account__r.Citizenship__c=='Domestic'){
                                                                filing.Filing_Type__c='Certificate of Amendment';
                                                            }
                                                            else{
                                                                if(legalstructure=='Limited Liability Partnership'){
                                                                    filing.Filing_Type__c='Certificate of Amendment';
                                                                }
                                                                else if(legalstructure=='Limited Liability Company'){
                                                                    filing.Filing_Type__c='Amendment of Foreign Registration Statement';
                                                                }
                                                                else if(legalstructure=='Stock Corporation' || legalstructure=='Non-Stock Corporation'){
                                                                    filing.Filing_Type__c='Amended Certificate of Authority';
                                                                }
                                                            }
                                                        }
                                                    }
                                                    filing.Status__c = 'In-Progress';
                                                    filing.Source__c = 'Digital Mail';
                                                }
        else if(String.isNotBlank(category) && category.equalsIgnoreCase('Close or reinstate your business')){
            order.Last_In_Progress_Flow__c = 'Back_Office_Dissolution_Reinstate';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Close / Reinstate').getRecordTypeId();
            filing.RecordTypeId = storeRecordTypeId;
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            if(businessType == 'Domestic' || businessType == 'Foreign')
            {
                filing.Citizenship__c=businessType;
            }
            else
            {
                filing.Type__c = businessType;
            }
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            if(String.isNotBlank(accountID)){
                filing.Account__c = accountID;
                }
                filing.Effective_Time__c = convertedDateTime.time();
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            order.Received_Date__c = convertedDateTime;
if(String.isBlank(businessSubType)){
businessSubType = '';
}
            String unescapeString = businessSubtype.unescapeHtml4();

            filing.Sub_Type__c = unescapeString;
            if(filing.Type__c=='Cancellation'){
                if(businessType=='Domestic'){
                    filing.Filing_Type__c =  'Certificate of Cancellation'; 
                }
                else{
                    filing.Filing_Type__c =  'Cancellation of Registration'; 
                }
            }
            if(filing.Type__c=='Dissolution'){                
                    filing.Filing_Type__c =  'Certificate of Dissolution';                
            }
            if(filing.Type__c=='Reinstatement'){                
                    filing.Filing_Type__c =  'Certificate of Reinstatement';                
            }
            if(filing.Type__c=='Renunciation of Status'){                
                    filing.Filing_Type__c =  'Renunciation of Status Report';                
            }
            if(filing.Type__c=='Revocation of Dissolution'){                
                    filing.Filing_Type__c =  'Revocation of Dissolution';                
            }
            if(filing.Type__c=='Withdrawal'){                
                    filing.Filing_Type__c =  'Statement of Withdrawal Registration';                
            }
        }
        else if(String.isNotBlank(category) && category.equalsIgnoreCase('Other')){
            // order.Last_In_Progress_Flow__c = 'Back_Office_Dissolution_Reinstate';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Other Business Filings').getRecordTypeId();
            filing.RecordTypeId = storeRecordTypeId;
            // filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.Type__c = businessType;
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            if(String.isNotBlank(accountID)){
                filing.Account__c = accountID;
                }
                filing.Effective_Time__c = convertedDateTime.time();
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            filing.Filing_Type__c =  businessType; 
        }
        else if(String.isNotBlank(category) && category.equalsIgnoreCase('Merger')){
            order.Last_In_Progress_Flow__c = 'BRS_Business_Merger_Filing';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
            filing.RecordTypeId = storeRecordTypeId;
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.Type__c = 'Merger';
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            filing.Effective_Time__c = convertedDateTime.time();
            filing.Citizenship__c = businessType;
            filing.Business_Type__c = legalstructure;
            filing.Type_of_Merger__c = citizenship;
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            if(filing.Business_Type__c!=null && filing.Business_Type__c != 'General Partnerships'){
                filing.Filing_Type__c = 'Certificate of Merger'; 
            }else if(filing.Business_Type__c!=null && filing.Business_Type__c == 'General Partnerships'){
                filing.Filing_Type__c = 'Statement of Merger';
            }

       /*   if( filing.Business_Type__c!=null &&  (filing.Business_Type__c == 'Stock'
            ||filing.Business_Type__c == 'B Corp'
            ||filing.Business_Type__c == 'Cooperative Association'
            ||filing.Business_Type__c == 'Bank Stock'
            ||filing.Business_Type__c == 'Credit Union Stock'
            ||filing.Business_Type__c == 'Insurance Stock'
            ))
{

            filing.Total_Authorized_Shares__c = 1;
}
     */       
        }else if(String.isNotBlank(category) && category.equalsIgnoreCase('Conversion')){
            order.Last_In_Progress_Flow__c = 'BRS_Business_Conversions';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
            filing.RecordTypeId = storeRecordTypeId;
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.Type__c = 'Conversion';
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            filing.Effective_Time__c = convertedDateTime.time();
            filing.Citizenship__c = businessType;
            filing.Business_Type__c = legalstructure;
            filing.Converting_Citizenship_Type__c = citizenship;
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            if(filing.Business_Type__c!=null && filing.Business_Type__c != 'General Partnerships'){
                filing.Filing_Type__c = 'Certificate of Conversion'; 
            }else if(filing.Business_Type__c!=null && filing.Business_Type__c == 'General Partnerships'){
                filing.Filing_Type__c = 'Statement of Conversion';
            }


          if(filing.Business_Type__c!=null && ((filing.Business_Type__c == 'Stock'
            ||filing.Business_Type__c == 'B Corp'))){
                if(totalStock!=null){
                    filing.Total_Authorized_Shares__c = totalStock;
                }
                else{
                    filing.Total_Authorized_Shares__c = 1;
                }                
               
            }

        }
        else if(String.isNotBlank(category) && category.equalsIgnoreCase('Domestication')){
            if(legalstructure == 'Stock' && businessType == 'Foreign')
            {
                filing.Total_Authorized_Shares__c=totalStock;
                filing.Franchise_Tax__c=FranchiseTax;
            }
            order.Last_In_Progress_Flow__c = 'BRS_Business_Domestication';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Mergers / Conversions / Domestications').getRecordTypeId();
            filing.RecordTypeId = storeRecordTypeId;
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.Type__c = 'Domestication';
            if(String.isNotBlank(accountID)){
                filing.Account__c = accountID;
                }
            filing.Citizenship__c = businessType;
            filing.Business_Type__c = legalstructure;
            filing.Effective_Date__c = receivedDate;
            filing.Effective_Date_Time__c = convertedDateTime;
            filing.Effective_Time__c = convertedDateTime.time();
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            if(filing.Business_Type__c!=null && filing.Business_Type__c != 'General Partnerships'){
                filing.Filing_Type__c = 'Certificate of Domestication'; 
            }else if(filing.Business_Type__c!=null && filing.Business_Type__c == 'General Partnerships'){
                filing.Filing_Type__c = 'Statement of Domestication';
            }
        /*    if( filing.Business_Type__c!=null &&  (filing.Business_Type__c == 'Stock'
            ||filing.Business_Type__c == 'B Corp'
            ||filing.Business_Type__c == 'Cooperative Association'
            ||filing.Business_Type__c == 'Bank Stock'
            ||filing.Business_Type__c == 'Credit Union Stock'
            ||filing.Business_Type__c == 'Insurance Stock'
            ))
{

            filing.Total_Authorized_Shares__c = 1;
} */
        }
        else if(String.isNotBlank(category) && category.equalsIgnoreCase('NameReservation')){
            order.Last_In_Progress_Flow__c = 'Back_Office_Name_Reservation';
            ID storeRecordTypeId = Schema.SObjectType.Business_Filing__c.getRecordTypeInfosByName().get('Name Reservation').getRecordTypeId();
            filing.FlowNameToProcess__c = order.Last_In_Progress_Flow__c;
            filing.RecordTypeId = storeRecordTypeId;
            // if(String.isNotBlank(businessType) && businessType == 'Domestic'){
            //     filing.Type__c = 'Business Formation';
            // }else{
            //     filing.Type__c = 'Business Registration';
            // }
            // filing.Citizenship__c = businessType;
            // filing.Business_Type__c = legalstructure;
            filing.Status__c = 'In-Progress';
            filing.Source__c = 'Digital Mail';
            filing.Type__c = businessType;
            
        }
        
        
        
        
            
            Boolean bAccessCheck = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{order}, 'upsert');
            if(bAccessCheck){
                upsert order;
                filing.Filing_Date__c = System.today();
                filing.Work_Order__c= order.id;
                if(String.isNotBlank(selectedaccountID)){
                    filing.Account__c = selectedaccountID;
                }
            }
        
            Boolean bAccessCheck1 = BRS_SecurityUtility.checkDMLAccess(new List<SObject>{filing}, 'upsert');
            if(bAccessCheck1){
                upsert filing;
            
                r.workorderid =order.id;
                r.recordid =filing.id;
                lstResults.add(r);
            }
        
        return lstResults;
    }
}