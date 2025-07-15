import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import baseUrl from '@salesforce/label/c.Robin_Base_URL';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/User.LastName';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';

//Get authstatus and Id from session context
import contextUserId from '@salesforce/user/Id';

export default class Bos_chatbot extends LightningElement {
    checkAuthTimer;

    @api get ctsessionlanguage() {
        let queryString = window.location.search;
        let urlParams = new URLSearchParams(queryString);
        return urlParams.get('language');
    }

    @api get originationUrl() {
        return location.hostname + location.pathname;
    }
    
    userDetails = {
        contextUserId: '',
        contactId: '',
        origin: this.originationUrl,
        firstName: '',
        lastName: '',
        forgerockAuthenticated: false,
        pendingAuthStatusChange: false,
        forgerockGUID: '',
    }
    
    @track getContextUserRecordResponse;

    @wire(getRecord, { 
        recordId: contextUserId, 
        fields: [FIRST_NAME_FIELD, LAST_NAME_FIELD, CONTACT_ID_FIELD]})
    wiredUserDetails(response){
        this.getContextUserRecordResponse = response;
        if(response.error){
        //Bot was loaded outside a user context.  ignore this.
        }else if(response.data){
            let userData = response.data.fields;
            this.userDetails.firstName = userData.FirstName.value;
            this.userDetails.lastName = userData.LastName.value;
            this.userDetails.contextUserId = contextUserId;
            this.userDetails.contactId = userData.ContactId.value;
        }
    };

    connectedCallback() {
        this.navigateTo = `${baseUrl}/chat/apex/CommunityChat1?language=${this.ctsessionlanguage}&url=${this.originationUrl}${window.location.search}`;
        window.addEventListener('message', this.resizeIframe.bind(this));
    }

    //Need to do this after render because @wi  re isn't garunteed to be done until then.
    renderedCallback(){
        this.checkAuthTimer = setInterval(() => {
            this.checkAuthStatus();
        }, 1000);
    }

    //Cleanup activities
    disconnectedCallback(){
        //Clears the interval timer used to poll context user state.
        clearInterval(this.checkAuthTimer);
    }

    resizeIframe(e) {
        if (e.data.hasOwnProperty("frameHeight")) {
            let chatFrame = this.template.querySelector('iframe');
            chatFrame.style.minHeight = 0;
            chatFrame.style.height = e.data.frameHeight + 20 + "px";
            chatFrame.style.width = e.data.frameWidth + 20 + "px";
        }
    }

    //Checks if the user's auth state has changed.  Fires a message to the chatframe if it has with new information.
    checkAuthStatus(){
        
        //Make note when forgerock has removed the cookie that tells us the user is logged in.  Cannot use to authenticate.  Only infer auth status
        let cookie = this.getAuthCookie();

        this.userDetails.pendingAuthStatusChange = ((cookie && !this.userDetails.forgerockAuthenticated) || (!cookie && this.userDetails.forgerockAuthenticated));
        this.userDetails.forgerockAuthenticated = (cookie != null) ? true : false;
        
        
        if(!cookie){
            this.userDetails.contactId = '';
            this.userDetails.firstName = '';
            this.userDetails.lastName = '';
            this.userDetails.contextUserId = '';
            this.userDetails.forgerockGUID = '';
        }else if(cookie){
            this.userDetails.contextUserId = contextUserId; //will be replaced with GUID
            //this.userDetails.forgerockGUID = 'A GUID'; For when we have this
        }        
        this.postUserDetailsUpdate(this.userDetails);        
    }

    //Posts a message to the chatframe with updated context user info.
    postUserDetailsUpdate(userDetails){
        let chatFrame = this.template.querySelector('iframe');
        chatFrame.contentWindow.postMessage(userDetails, "*");

        this.userDetails.pendingAuthStatusChange = false;
    }

    setAuthCookie() {
        document.cookie = `ctsignintray=value`;
    }
    
    deleteAuthCookie() {
        document.cookie = ctsignintray +'=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    }

    getAuthCookie(){
        return document.cookie.match(new RegExp('(^| )ctsignintray=([^;]+)'));
    }
}