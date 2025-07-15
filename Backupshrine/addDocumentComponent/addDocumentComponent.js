import { LightningElement,track } from 'lwc';

export default class AddDocumentComponent extends LightningElement {
    @track documentRows = []; 

    // Options for Type of Document picklist
    documentTypeOptions = [
        { label: 'Vital Record', value: 'Vital Record' },
        { label: 'Apostille Regular', value: 'Apostille Regular' },
        { label: 'School Record', value: 'School Record' },
    ];

    // Options for Title of Officially Signing picklist
    signingTitleOptions = [
        { label: 'State Registrar', value: 'State Registrar' },
        { label: 'Notary Public', value: 'Notary Public' },
        { label: 'Judge', value: 'Judge' },
    ];

     // Handler for Add Document Button
     handleAddRow() {
        const newRow = {
            id: Date.now(), // Unique ID for each row
            documentType: '',
            personName: '',
            signingTitle: '',
            notaryName: '',
            fee: null
        };
        this.documentRows = [...this.documentRows, newRow];
    }

     // Handler for Input Change
     handleInputChange(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.name;
        const fieldValue = event.target.value;

        this.documentRows = this.documentRows.map(row => {
            if (row.id == rowId) {
                return { ...row, [fieldName]: fieldValue };
            }
            return row;
        });
        console.log('row values are '+JSON.stringify(this.documentRows));
        
    }

    // Handler for Delete Row
    handleDeleteRow(event) {
        const rowId = event.target.dataset.id;
        this.documentRows = this.documentRows.filter(row => row.id != rowId);
    }

}