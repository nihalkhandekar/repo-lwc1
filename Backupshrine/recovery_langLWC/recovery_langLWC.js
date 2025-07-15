import { LightningElement,track } from 'lwc';
import label_bttnText from '@salesforce/label/c.Recovery_Language_Label';
export default class Recovery_langLWC extends LightningElement {
    @track
    showPill;

    @track
    setLanguage;

    label={
        label_bttnText
    };

    connectedCallback(){
        const param = 'language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        if(paramValue==='en_US'){
            this.showPill = true;
        }
        else{
            this.showPill = false;
        }
        
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    handleClick() {
        const param = 'language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        
        var urlParam = window.location.href;
        
        if(paramValue === 'en_US'){
            urlParam = urlParam.replace('en_US', 'es');            
        }
        else{
            urlParam = urlParam.replace('language='+paramValue, 'language=en_US');
        }
       
        location.href=urlParam;
    }
}