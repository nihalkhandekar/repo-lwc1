import { LightningElement, track } from 'lwc';
//Import our Apex method
import paymentProcess from "@salesforce/apex/AuthorizationNetPOC.paymentProcess";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
 
export default class AuthorizationIO extends LightningElement {
    monthOptions = [
                    {
                        value: "01",
                        label: "January"
                    },
                    {
                        value: "02",
                        label: "February"
                    },
                    {
                        value: "03",
                        label: "March"
                    },
                    {
                        value: "04",
                        label: "April"
                    },
                    {
                        value: "05",
                        label: "May"
                    },
                    {
                        value: "06",
                        label: "June"
                    },
                    {
                        value: "07",
                        label: "July"
                    },
                    {
                        value: "08",
                        label: "August"
                    },
                     {
                        value: "09",
                        label: "September"
                    },
                    {
                        value: "10",
                        label: "October"
                    },
                    {
                        value: "11",
                        label: "November"
                    },
                    {
                        value: "12",
                        label: "December"
                    }
    ];
    yearOptions = [
                    {
                        value: "2023",
                        label: "2023"
                    },
                    {
                        value: "2024",
                        label: "2024"
                    },
                    {
                        value: "2025",
                        label: "2025"
                    },
                    {
                        value: "2026",
                        label: "2026"
                    },
                    {
                        value: "2027",
                        label: "2027"
                    },
                    {
                        value: "2028",
                        label: "2028"
                    },
                     {
                        value: "2029",
                        label: "2029"
                    },
                    {
                        value: "2030",
                        label: "2030"
                    }
                    
    ];
 
    countries = [
            {
                value: "India",
                label: "India"
            },
            {
                value: "USA",
                label: "USA"
            },
            {
                value: "United Kingdom",
                label: "United Kingdom"
            },
    ];
 
    @track creditCardOwnerDetails = {};
    @track showSpinner = false;
     
    handleChange(event) {
        console.log('OUTPUT : ',event.target.name +' ==> '+event.target.value);
        this.creditCardOwnerDetails[event.target.name] = event.target.value;
    }

    handlePayment(){

        if(!this.validateInputDetails()){
            return;
        }

        this.handleSpinner();
       
       
        paymentProcess({paymentString : JSON.stringify(this.creditCardOwnerDetails)})
        .then(res=>{
            let title = res;
            this.ShowToast('Success!', title, 'success', 'dismissable');
        }).catch(err=>{
            this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
        }).finally(() => {
            this.handleSpinner();
        })
    }

    handleValidation(event){
        let inputField = event.target.name;
        this.template.querySelector("lightning-input[data-input="+inputField+"]")?.reportValidity();
    }

    handleValidationForCombobox(event){
        let inputField = event.target.name;
        this.template.querySelector("lightning-combobox[data-input="+inputField+"]")?.reportValidity();
    }

    validateInputDetails(){
        let isVal = true;

        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
            isVal = isVal && element.reportValidity();
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            element.reportValidity();
            isVal = isVal && element.reportValidity();
        });

        return isVal;
    }
 
    handleSpinner(){
        this.showSpinner = !this.showSpinner;
    }
 
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}