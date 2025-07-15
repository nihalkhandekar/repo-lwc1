import { LightningElement } from 'lwc';

export default class ApostillePrintSubmissionDocument extends LightningElement {
    // Hardcoded values for the documents
    workOrderNumber = 'WO12345';
    customerName = 'John Smith';
    
    documentsRequested = [
        { type: 'Vital Record', destinationCountry: 'Australia', personName: 'Charlie Puth', hagueStatus: 'Yes', fee: '$20.00 (+ $50.00)' },
        { type: 'Personal Document (POA etc)', destinationCountry: 'Canada', personName: 'William Smith', hagueStatus: 'Yes', fee: '$40.00 (+ $50.00)' },
        { type: 'Apostille - Regular', destinationCountry: 'Canada', personName: 'Juliana Watson', hagueStatus: 'Yes', fee: '$40.00 (+ $50.00)' },
        { type: 'Court Records', destinationCountry: 'United States of America', personName: 'John Thompson', hagueStatus: 'Yes', fee: '$40.00 (+ $50.00)' },
        { type: 'School Record', destinationCountry: 'United States of America', personName: 'William Robertson', hagueStatus: 'Yes', fee: '$40.00 (+ $50.00)' },
        { type: 'Apostille - Expedite', destinationCountry: 'United States of America', personName: 'Clara William', hagueStatus: 'Yes', fee: '$40.00 (+ $50.00)' },
    ];

    totalFee = '$520.00';
    expediteFee = '$300.00';

    // Mailing information
    mailingInfo = {
        preferredMethod: {
            method: 'Hand delivery of original document(s), or send via FedEx, UPS, or DHL:',
            address: 'Secretary of the State, Authentications and Apostille Unit, 165 Capital Avenue Suite 1000, Hartford, CT 06106'
        },
        firstClass: {
            method: 'First Class or Priority Mail through the US Postal Service:',
            address: 'Secretary of the State, Authentications and Apostille Unit, P.O. Box 150470, Hartford, CT 06115-0470'
        }
    };
}