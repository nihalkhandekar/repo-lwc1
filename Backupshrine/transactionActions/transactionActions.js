import { LightningElement, api } from 'lwc';

export default class TransactionActions extends LightningElement {

    @api recordId;
    @api customerId;

    // connectedCallback() {
    //     console.log('@ recordId',this.recordId);
    // }

    handleViewClick(){
        try {
            console.log('view button is clicked & record Id is :'+ this.recordId);
            console.log('CustomerId is: ' + this.customerId);

            this.dispatchEvent(new CustomEvent('view', {
                detail: {
                    id: this.recordId,
                    customerId: this.customerId
                 },
                bubbles: true,
                composed: true
            }));
    
        } catch (error) {
            console.log(error);
        }
    }

    handlePrintClick(){
        try {
            console.log('print button is clicked & record Id is :'+ this.recordId);
            const customEvent = new CustomEvent('print',{
                detail : {id : this.recordId},
                bubbles : true,
                composed : true
            });
    
            this.dispatchEvent(customEvent);

        } catch (error) {
            console.log(error);
        }
    }


    handleRefundClick(){
        try {
            console.log('Refund button is clicked & record Id is :'+ this.recordId);
            const customEvent = new CustomEvent('refund',{
                detail : {id : this.recordId},
                bubbles : true,
                composed : true
            });
    
            this.dispatchEvent(customEvent);

        } catch (error) {
            console.log(error);
        }
    }

    

}