import { LightningElement,api,track } from 'lwc';
     import findRecords from '@salesforce/apex/CustomLookupController.findRecords'; 
     import getRecords from '@salesforce/apex/CustomLookupController.getRecords'; 

     
     export default class Brs_CustomLookup extends LightningElement {
          @track records;
           @track error;
           @track showMergerError = false;
           @track showBusinessAndCitiVal = false;
            @track selectedRecord;
             @api index; 
             @api selectedRecordId;
             @api relationshipfield;
              @api iconname = "standard:account";
               @api objectName = 'Account';
                @api searchfield = 'Name'; 
                @api isNameReservation;
                @api isMergerFlow;
                @api businessFilingRecord;
                @api businessFilingRecordNew;
                @api isValid = false;
                @api isValidData = false;
    /*constructor(){ super(); this.iconname = "standard:account"; this.objectName = 'Account'; this.searchField = 'Name'; }*/ 
  
  
  
  connectedCallback(){
      if(this.selectedRecordId!=null && this.selectedRecordId!=null ){
        getRecords(
            {  objectName : this.objectName, searchField : this.searchfield,sid:this.selectedRecordId }
            ) .then(result => {
                 
                 if(result!=null && result!=undefined && result.length >0){
                     this.selectedRecord = result[0];
                 }

    }).catch(error => {
             this.error = error; 
             this.records = undefined;  });
    
    
        
      }
  }
  
  
  
    handleOnchange(event){
        //event.preventDefault();
         const searchKey = event.detail;
          //this.records = null;
           /* eslint-disable no-console */ 
           //console.log(searchKey); 
    /* Call the Salesforce Apex class method to find the Records */ 
    if(searchKey.length >=3)
    {
    findRecords(
        { searchKey : searchKey, objectName : this.objectName, searchField : this.searchfield,isNameReservation:this.isNameReservation }
        ) .then(result => {
             var newrecords = result; 
    //          for(let i=0; i < newrecords.length; i++)
    //          { 
    //              const rec =JSON.parse(JSON.stringify( newrecords[i])); 
    //              newrecords[i].Name = rec[this.searchfield]; 
              
    // } 
    this.records =newrecords;
    this.error = null;
}).catch(error => {
         this.error = error; 
         this.records = undefined;  });


    }



         } 
         







         handleselect(event)
         {
             this.selectedRecordId = event.detail;
               /* eslint-disable no-console*/ 
               this.selectedRecord = this.records.find( record => record.Id === this.selectedRecordId);
                /* fire the event with the value of Recordld for the Selected Recordld */ 
                if(this.isMergerFlow == 'MERGER' && ((this.selectedRecord.btype!='General Partnerships' && this.selectedRecord.status!='Active') || (this.selectedRecord.btype=='General Partnerships' && this.selectedRecord.status!='Recorded'))){
                    this.showMergerError = true;
                }
                if(this.isMergerFlow == 'MERGER' &&( (this.selectedRecord.btype != this.businessFilingRecordNew['Business_Type__c']) || (this.selectedRecord.citizenship != this.businessFilingRecordNew['Citizenship__c']))){
                    this.showBusinessAndCitiVal = true;
                }
                if(this.showMergerError  || this.showBusinessAndCitiVal){
                    this.isValidData = true;
                }
                const selectedRecordEvent = new CustomEvent( "selectedrec", { 
                    //detail : selectedRecordId 
                    detail : { recordld : this.selectedRecordId, 
                        index : this.index, 
                        relationshipfield : this.relationshipfield} });
                         this.dispatchEvent(selectedRecordEvent); 
                        } 





        handleRemove(event){ 
            event. preventDefault(); 
            this.selectedRecord = undefined; 
            this.selectedRecordId = undefined; 
            this.records = undefined; 
            this.error = undefined; 
            this.showMergerError = false;
            this.showBusinessAndCitiVal = false;
            /* fire the event with the value of undefined for the Selected Recordld */ 
            const selectedRecordEvent = new CustomEvent( "selectedrec", 
        { 
        detail : { recordld : undefined, 
            index : this.index, 
            relationshipfield : this.relationshipfield} } );
             this.dispatchEvent(selectedRecordEvent); 
        } 
        



}