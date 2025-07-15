import { LightningElement, track } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class DocumentTable extends LightningElement {
    @track documents = [];
    @track total = 0;

    documentTypes = [
        { label: 'Vital Record', value: 'Vital Record' },
        { label: 'Personal Document (POA etc)', value: 'Personal Document (POA etc)' },
        { label: 'Apostille - Regular', value: 'Apostille - Regular' },
        { label: 'Court Records', value: 'Court Records' },
        { label: 'School Record', value: 'School Record' },
        { label: 'Apostille - Expedite', value: 'Apostille - Expedite' },
    ];

    countries = [
        { label: 'Australia', value: 'Australia' },
        { label: 'Canada', value: 'Canada' },
        { label: 'United States of America', value: 'United States of America' },
    ];

    hagueStatuses = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];

    handleAddDocument() {
        this.documents = [...this.documents, {
            id: `${Date.now()}-${Math.random()}`, // Unique ID
            type: '',
            country: '',
            name: '',
            hagueStatus: '',
            fee: 0
        }];
        this.calculateTotal();
    }

    handleRemoveDocument(event) {
        const index = event.currentTarget.dataset.index;
        this.documents = this.documents.filter((_, i) => i != index);
        this.calculateTotal();
    }

    handleInputChange(event) {
        console.log('inside handle input change method');
        const index = event.target.dataset.index;
        const field = event.target.name;
        const value = event.target.value;
    
        console.log(`Index: ${index}, Field: ${field}, Value: ${value}`);
    
        this.documents = this.documents.map((doc, i) => {
            if (i === parseInt(index, 10)) {
                return { ...doc, [field]: value };
            }
            return doc;
        });
    
        console.log('Updated Documents:', this.documents);
    
        this.calculateTotal();
    
        const attributeChangeEvent = new FlowAttributeChangeEvent('documents', this.documents);
        this.dispatchEvent(attributeChangeEvent);
    }
    

    calculateTotal() {
        this.total = this.documents.reduce((acc, doc) => acc + (doc.fee || 0), 0).toFixed(2);
    }
}