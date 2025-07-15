import { LightningElement } from 'lwc';
export default class TestSignInTray extends LightningElement {

    connectedCallback(){
        getCookie(name);
    }
    
}

 function getCookie(name){
    console.log('testing here');
    var cookieString = "; " + document.cookie;
        var parts = cookieString.split('; ' + name + '=');
    console.log('sign-in-tray cookie: ' + cookieString);
    console.log('parts here' + parts);
}