import { LightningElement, api } from 'lwc';

export default class CustomActionButtons extends LightningElement {
    @api recordId;

    handlePdfClick() {
        console.log('pdf id : '+this.recordId);
        const pdfEvent = new CustomEvent('pdfclick', {
            detail: { recordId: this.recordId }       
         });
        this.dispatchEvent(pdfEvent);
    }

    handleExcelClick() {
        console.log('Excel id : '+this.recordId);
        const excelEvent = new CustomEvent('excelclick', {
            detail: this.recordId
        });
        this.dispatchEvent(excelEvent);
    }
}