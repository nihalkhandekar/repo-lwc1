import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getContactDetails from '@salesforce/apex/HighlightPanelCtrl.getContactDetails';

// Chat Transcript Fields
import TRANSCRIPT_CONTACT_MOBILE from '@salesforce/schema/Contact.MobilePhone';
import TRANSCRIPT_CONTACT_PHONE from '@salesforce/schema/Contact.Phone';
import TRANSCRIPT_CONTACT_WAIT_TIME from '@salesforce/schema/LiveChatTranscript.WaitTime';
import TRANSCRIPT_CONTACTID from '@salesforce/schema/LiveChatTranscript.ContactId';

const selectedTranscriptFields = [TRANSCRIPT_CONTACTID, TRANSCRIPT_CONTACT_WAIT_TIME];
const selectedTranscriptContactFields = [TRANSCRIPT_CONTACT_MOBILE, TRANSCRIPT_CONTACT_PHONE];
const chatIcon = 'standard:live_chat';

export default class TranscriptHighlightsPanel extends LightningElement {
    @api recordId;
    @api contactRecordId;
    @api objectApiName;
    @api iconName;
    @track fields = [];
    contactDetails;
    selectedSessionFields;
    error;
    areDetailsVisible = false;

    connectedCallback() { 
        this.selectedSessionFields = selectedTranscriptFields;
        this.selectedContactFields = selectedTranscriptContactFields;
        this.fields = selectedTranscriptContactFields
        this.iconName = chatIcon;
    }

    getContactDetails() {
        getContactDetails({ sessionId: this.recordId, objectApiName: this.objectApiName })
        .then(result => {
            console.log(JSON.stringify(result));
            this.contactRecordId = result.Id;
        })
        .catch(error => {
            console.log('Handle error: ' + JSON.stringify(error));
            this.error = error;
            this.contactDetails = {};
        });
    }

    @wire(getRecord, {recordId: '$recordId', fields: '$selectedSessionFields'})
    searchMatches({error, data}) {
        if (data) {
            console.log('got data!! ' + JSON.stringify(data));
            this.getContactDetails();
        } else if (error) {
            console.log('searchMatches error: ' + JSON.stringify(error));
        }
    }

    handleTranscriptSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Session udpated",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.getContactDetails();
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            '.contact-fields'
        );
        console.log('inputFields: ' + JSON.stringify(inputFields));
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = '';
            });
        }
    }
}