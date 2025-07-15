import { LightningElement, api, track } from 'lwc';

export default class GenericTable extends LightningElement {
    @api tablecolumns;
    @api tabledata;
    @api customtable;

    handleRowAction(event){
        const selectedEvent = new CustomEvent("tablerowaction", {
            detail: event.detail
          });
          this.dispatchEvent(selectedEvent);
    }
}