import { LightningElement, track,wire } from 'lwc';
import getAllCarDeatils from '@salesforce/apex/carDetailsSearch.getAllCarDeatils';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Model', fieldName: 'Model__c' },
    { label: 'Price', fieldName: 'Price__c' },

];
export default class SearchCarDetails extends NavigationMixin (LightningElement) {

    availableCars;
    error;
    columns = columns;
    searchString;
    initialCarRecords;

    @wire (getAllCarDeatils)
    wiredCar ( {error,data} ) {
        
        if(data){
            this.availableCars = data;
            this.initialCarRecords = data;
            this.error=undefined;
        }else if (error){
            this.error = error;
            this.availableCars = undefined;
        }
    }
    
    handleSearch(event){
        const searchKey = event.target.value.toLowerCase();
        console.log('Search String is'+ searchKey);

        if(searchKey){
            this.availableCars = this.initialCarRecords;
            console.log('Car Records are'+ JSON.stringify(this.availableCars));

            if(this.availableCars){
                let recs = [];
                
                for(let rec of this.availableCars){
                    console.log('Rec is:' + JSON.stringify(rec));
                    let valuesArray = Object.values(rec);
                    console.log('valuesArray is: ' + JSON.stringify(valuesArray));

                    for (let val of valuesArray){
                        console.log('val is:'+ val);
                        let strVal = String (val);
                       
                        if(strVal){
                            if(strVal.toLowerCase().includes(searchKey)){
                                recs.push(rec);
                                break;  
                            }
                        }
                    }
                }

                console.log('Matched Cars are:' + JSON.stringify(recs));
                this.availableCars = recs;
            }
        }else {
            this.availableCars = this.initialCarRecords;
        }
    }
}