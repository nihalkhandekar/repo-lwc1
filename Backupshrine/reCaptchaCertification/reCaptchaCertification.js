import { LightningElement,api,track,wire } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/reCaptcha';
import pageUrlSpanish from '@salesforce/resourceUrl/reCaptcha_Spanish';
export default class ReCaptchaCertification extends LightningElement { 
    @track cptchMessgVar = 'No Captcha';
    @track navigateTo; 
    @track data;    
    @track
    languageValue;
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    listenMessage(msg){
        window.data = msg.data;
        this.cptchMessgVar = msg.data;
    }
   @api
   getValue(){
        return window.data;
   }
   connectedCallback(){    
    const param='language';
    const paramValue = this.getUrlParamValue(window.location.href, param);
    this.languageValue = paramValue;   
    window.data = '';
    if(this.languageValue === 'en_US'){
        this.navigateTo = pageUrl;
    }
    else{
        this.navigateTo = pageUrlSpanish;
    }
    if(window.addEventListener){
        window.addEventListener("message",this.listenMessage,false);            
    }
    else{
        window.attachEvent("onmessage",this.listenMessage);
    }
   }
}