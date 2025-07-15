import { LightningElement, track,api,wire } from 'lwc';
import {loadStyle } from 'lightning/platformResourceLoader'; 
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';

export default class FinsysReportCoreCT extends LightningElement {

    @track recordCount = 5;
    @track recordCountMoneyOrder = 2;

    connectedCallback() {
        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('First CSS file (stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));
    }

    paginatedResultMoneyOrder = [
        {
            Id: '1',
            speedType: '1',
            activityDescription: 'Notary Public',
            activityCode: 'A123',
            amount: '$120.00',
            transactionDate: '2024-10-15',
            DepositDate: '2024-10-16',
            Action: ''
        },
        {
            Id: '2',
            speedType: '2',
            activityDescription: 'Notary Public',
            activityCode: 'B456',
            amount: '$80.00',
            transactionDate: '2024-10-17',
            DepositDate: '2024-10-18',
            Action: ''
        }
    ];

    paginatedResult = [
        {
            Id: '1',
            speedType: '1',
            activityDescription: 'Notary Public',
            activityCode: 'A123',
            amount: '$120.00',
            transactionDate: '2024-10-15',
            DepositDate: '2024-10-16',
            Action: ''
        },
        {
            Id: '2',
            speedType: '2',
            activityDescription: 'Notary Public',
            activityCode: 'B456',
            amount: '$80.00',
            transactionDate: '2024-10-17',
            DepositDate: '2024-10-18',
            Action: ''
        },
        {
            Id: '3',
            speedType: '3',
            activityDescription: 'Authentication/Apostille',
            activityCode: 'C789',
            amount: '$150.00',
            transactionDate: '2024-10-20',
            DepositDate: '2024-10-21',
                 Action: ''
        },
        {
            Id: '4',
            speedType: '4',
            activityDescription: 'Authentication/Apostille',
            activityCode: 'D012',
            amount: '$200.00',
            transactionDate: '2024-10-22',
            DepositDate: '2024-10-23',
                 Action: ''
        },
        {
            Id: '5',
            speedType: '5',
            activityDescription: 'Authentication/Apostille',
            activityCode: 'E345',
            amount: '$250.00',
            transactionDate: '2024-10-25',
            DepositDate: '2024-10-26',
                 Action: ''
        }
    ];
    
    

    recordCountValueoney() {
        return `${this.recordCountMoneyOrder} Found`;
    }


    get recordCountValue() {
        return `${this.recordCount} Found`;
    }


}