import { LightningElement } from 'lwc';
import {countryCodeList} from 'c/countryCodeList'
import currencyConverterAssets from '@salesforce/resourceUrl/currencyConverterAssets'

export default class CurrencyConverterApp extends LightningElement {
    currencyImage = currencyConverterAssets + '/currencyConverterAssets/currency.svg'
    countryList = countryCodeList
    countryFrom = "USD"
    countryTo = "INR"
    amount 
    result
    error

    handleChange(event){
        const{name, value} = event.target

        console.log("name", name)
        console.log("value", value)

        this[name] = value
        this.result = ''
        this.error = ''
    }
    
    submitHandler(event){
        event.preventDefault();
        this.convert();
    }

    async convert(){

        //const API_URL = `https://api.exchangerate.host/convert?from=${this.countryFrom}&to=${this.countryTo}`;
        const API_KEY = '672fbb7bbcb758f45678263a'
        const API_URL = `https://v6.exchangerate-api.com/v6/${API_KEY}/pair/${this.countryFrom}/${this.countryTo}`
        try{
            const data = await fetch(API_URL); //API always returns the binary stream so need to convert it to JSON data
            const jsonData = await data.json();
            console.log('jsonData-->', jsonData);
            this.result = (Number(this.amount) * jsonData.conversion_rate).toFixed(2);
            console.log("this.result-->>", this.result);

        }catch(error){
            console.log("error-->"+ error);
            this.error = "An Error occured. Please try again...."
        }
    }
}