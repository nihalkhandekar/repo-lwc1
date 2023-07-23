import { LightningElement } from 'lwc';
import getAllAccountDetails from '@salesforce/apex/SearchAccClass.getAllAccountDetails';
export default class ApexExecution extends LightningElement {
    getAccounts(event){
        let accName=event.target.value + '%';
        getAllAccountDetails({'accName' :accName}).then(x=> {
            console.log(JSON.stringify(x));
        }).catch(e=>{
            console.log(JSON.stringify(e));
        })
    }
}