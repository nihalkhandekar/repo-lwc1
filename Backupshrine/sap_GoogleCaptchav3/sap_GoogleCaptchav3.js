import { api, LightningElement, track } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/Goolge_reCAPTCHAv3';

export default class Sap_GoogleCaptchav3 extends LightningElement {
    @track navigateTo;
    @track iFrameHeight = '500px';

    constructor(){
        super();
        this.navigateTo = pageUrl;
        window.addEventListener("message", (message) => {
            console.log('message :: ', message.data);
            if(message.data === 'validationImage'){
                this.iFrameHeight = '500px';
                const evt = new CustomEvent(
                    'enabledisablesubmit', {
                        detail: {enableSubmit: false}
                    }
                );
                this.dispatchEvent(evt);
            }

            else if(message.data === 'error' || message.data === 'expired'){
            
                this.iFrameHeight = '100px';
                const evt = new CustomEvent(
                    'enabledisablesubmit', {
                        detail: {enableSubmit: false}
                    }
                );
                this.dispatchEvent(evt);
            }else if(message.data === 'success'){
                this.iFrameHeight = '100px';
                const evt = new CustomEvent(
                    'enabledisablesubmit', {
                        detail: {enableSubmit: true}
                    }
                );
                this.dispatchEvent(evt);
            }
        });
    }

    captchaLoaded(event){
        if(event.target.getAttribute('src') == pageUrl){
            console.log('Google reCAPTCHA is loaded.');
        } 
    }

    connectedCallback(){
        this.navigateTo = pageUrl;
        window.addEventListener("message", this.listenForMessage);//add event listener for message that we post in our recaptchaV2 static resource html file.
    }

    listenForMessage(message){

    }

}