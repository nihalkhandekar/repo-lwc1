import { LightningElement, api } from 'lwc';

export default class TransactionActionLinks extends LightningElement {
    @api rowId;

    handleView() {
        const viewEvent = new CustomEvent('view', {
            detail: { rowId: this.rowId }
        });
        this.dispatchEvent(viewEvent);
    }

    handleRefund() {
        const refundEvent = new CustomEvent('refund', {
            detail: { rowId: this.rowId }
        });
        this.dispatchEvent(refundEvent);
    }
}