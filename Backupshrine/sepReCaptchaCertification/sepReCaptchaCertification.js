import { LightningElement,api,track } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/sepRecaptcha';
import pageUrlSpanish from '@salesforce/resourceUrl/sepRecaptcha_Spanish';
export default class SepReCaptchaCertification extends LightningElement { 
    @api variationTwo;
    @track cptchMessgVar = 'No Captcha';
    @track navigateTo; 
    @track data;    
    @track isCaptchSuccess = false;
    @track captchaToken = '';
    @track isMobile = false;
    @track
    languageValue;
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

   listenMessage(msg) {
        const ele = this.template.querySelector('iframe');
        window.data = msg.data;
        this.cptchMessgVar = msg.data;
        if (typeof (msg.data) === 'object') {
            if (msg.data.type === 'captcha success') {
                this.isCaptchSuccess = true;
                this.captchaToken = msg.data.data;
                ele.height = 100;
                this.dispatchEvent(new CustomEvent('captchasuccess', {
                    detail: {
                        token: msg.data.data
                    }
                }));
            } else if (msg.data.type === 'captcha failed') {
                this.isCaptchSuccess = false;
                ele.height = 100;
                this.dispatchEvent(new CustomEvent('captchafailed', {
                    detail: {
                        token: msg.data.data
                    }
                }));
            }
        } else {
            if (msg.data === 'captchaVisible') {
                ele.height = 500;
            } else if (msg.data === 'captchaVisibleClose') {
                ele.height = 100;
            } else if (msg.data === 'captcha expired') {
                //captch expired
                this.isCaptchSuccess = false;
                this.dispatchEvent(new CustomEvent('captchaexpired'));
            } else if (msg.data === 'captcha success') {
                this.isCaptchSuccess = true;
                ele.height = 100;
                this.dispatchEvent(new CustomEvent('captchasuccess'));
            } else if (msg.data === 'captcha failed') {
                this.isCaptchSuccess = false;
                ele.height = 100;
                this.dispatchEvent(new CustomEvent('captchafailed'));
            }
        }
    }

    @api
    getValue() {
        return this.isCaptchSuccess;
    }

    connectedCallback() {
        if (window.screen.width < 1024) {
            this.isMobile = true;
        }
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
        window.data = '';
        this.navigateTo = pageUrl;
        if(window.addEventListener) {
        window.addEventListener("message", this.listenMessage.bind(this), false);   
        }
        else{
        window.attachEvent("onmessage", this.listenMessage.bind(this), false);
        }
    }

    @api
    getToken() {
        return this.captchaToken;
    }

    @api
    resetCaptcha() {
        let iframe = this.template.querySelector('iframe');
        if (iframe) {
            iframe.contentWindow.postMessage('captchareset', location.origin);
            this.isCaptchSuccess = false;
        }
    }
}