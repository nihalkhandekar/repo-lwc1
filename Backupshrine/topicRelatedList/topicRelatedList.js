import { LightningElement, api } from 'lwc';

export default class TopicRelatedList extends LightningElement {
    @api 
    record;
    @api 
    fieldname;
    @api 
    iconname;

    handleRecordSelection() {
        this.dispatchEvent(new CustomEvent("select", { detail : this.record.Id }));
    }
}