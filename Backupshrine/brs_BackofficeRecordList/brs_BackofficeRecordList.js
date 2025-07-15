import { LightningElement,api,track } from 'lwc';
import {
    isUndefinedOrNull
  } from "c/appUtility";

export default class Brs_BackofficeRecordList extends LightningElement {
   
 @api record;
  @api fieldname;
   @api iconname; 
    handleSelect(event){ 
       event.preventDefault(); 
        const selectedRecord = new CustomEvent( "selectrecord",  { detail : this.record.Id 
    } 
    ); /* eslint-disable no-console */ //console.log( this.record.Id); /* fire the event to be handled on the Parent Component x/
     this.dispatchEvent(selectedRecord); 
    
}
}