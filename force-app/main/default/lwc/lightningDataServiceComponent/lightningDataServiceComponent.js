import { LightningElement, api, wire } from 'lwc';
import { getRecord, createRecord } from 'lightning/uiRecordApi'; //this is the ui package// 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fieldsArray = ['Account.Name', 'Account.Phone']; //for fields that you wanna show declare a string array // 
export default class LightningDataServiceComponent extends LightningElement {

    @api
    recordId;

    Name;
    Phone;

    @wire(getRecord, {recordId: '$recordId', fields: fieldsArray})  
    // wire method will work when the page loads.. Yha getRecord inbuilt function hai jisme id and fields pass kro to data return krta hai//
    accountRecord;

    connectedCallback(){
        console.log('RecordId---'+this.recordId);
        console.log('accountRecord---'+JSON.stringify(this.accountRecord));
    }
    get retrieveAccountName(){
        if(this.accountRecord.data){
            //console.log('accountRecord---'+JSON.stringify(this.accountRecord));
            return this.accountRecord.data.fields.Name.value;
        }  
        return;
    }
    get retrieveAccountPhone(){ 
        if(this.accountRecord.data){
            return this.accountRecord.data.fields.Phone.value;
        }
        return;
    }

    updateName(event){
        this.Name = event.target.value;
    }
    updatePhone(event){
        this.Phone = event.target.value;
    }
    SaveNewRecord(event){
        let dataFields = {'Name':this.Name , 'Phone': this.Phone};
        let recordDetails = {'apiName':'Account', 'fields':dataFields};

        createRecord(recordDetails).then(x=>{
            console.log(JSON.stringify(x));
            this.recordId=x.id;
            const eventNotif = new ShowToastEvent({
                title :'Success!!!',
                message:'Record Saved Successfully!!',
                variant: 'success'
            });
            this.dispatchEvent(eventNotif);
        }).catch(err =>{
            console.log(JSON.stringify(err))
        })

    }
}