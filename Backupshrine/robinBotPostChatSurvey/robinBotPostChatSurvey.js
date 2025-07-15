import { api, LightningElement } from 'lwc';
import surveyLink from '@salesforce/label/c.Robin_Bot_Post_Chat_Survey_Link'
import submitSurveyResults from '@salesforce/apex/RobinBot_PostChatSurveyCtrl.submitSurveyResults';

export default class IibotChatSurvey extends LightningElement {
    @api chatKey;
    displaySurvey = true;
    displayThankYouMessage = false;
    displayError = false;
    loading = false;
    languageParam;
    pageUrl;

    constructor() {
        super();

        // Listener for event from roundtrip started in connectedCallback
        window.addEventListener('message', e => {
            this.languageParam = e.data.detail.language;
            this.pageUrl = e.data.detail.url;
        });
    }

    connectedCallback() {
        // Send event to RobinScripts to fetch language + parent url
        window.parent.postMessage({detail: 'ctsessionlanguage'}, '*');
    }

    get surveyLink() {
        return surveyLink
                + '?Chatbot=true&Language=' + this.languageParam
                + '&DeviceType=' + this.getDeviceType()
                + '&SourcePage=' + encodeURIComponent(this.pageUrl);
    }

    getDeviceType() {
        const ua = navigator.userAgent;
        if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(ua)) {
            return "tablet";
        }
        else if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/.test(ua)) {
            return "mobile";
        }
        return "desktop";
    }

    submitResponse(e) {
        this.loading = true;
        let response = e.detail.rating;
        let input = {
            chatKey: this.chatKey,
            userResponse: response
        };

        submitSurveyResults({ input: input })
            .then(() => {
                this.loading = false;
                this.displaySurvey = false;
                this.displayThankYouMessage = true;
            })
            .catch((e) => {
                console.log('error: ' + e.body.message);
                this.loading = false;
                this.displaySurvey = false;
                this.displayError = true;
            });
    }
}