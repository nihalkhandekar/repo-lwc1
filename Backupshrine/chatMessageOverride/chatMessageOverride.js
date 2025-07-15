import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track, wire } from 'lwc';
import getDetails from '@salesforce/apex/InterOrgTransferHelper.getDetails';
import checkForContact from '@salesforce/apexContinuation/InterOrgTransferHelper.checkForContact';
import sendTranscript from '@salesforce/apex/InterOrgTransferHelper.sendTranscript';
import submitFeedback from '@salesforce/apex/CTBOT_ArticleLevelFeedback.submitFeedback';
import getMainMenuIds from '@salesforce/apex/CTBOT_ArticleLevelFeedback.getMainMenuIds';
import feedbackMaxValue from '@salesforce/label/c.CTBOT_Feedback_Count';

const DEFAULT_MESSAGE_PREFIX = 'PLAIN_TEXT';
const RICHTEXT_MESSAGE_PREFIX = 'RICH_TEXT';
const LONGTEXT_MESSAGE_PREFIX = 'LONG_TEXT';
const YOUTUBE_MESSAGE_PREFIX = 'YOUTUBE';
const IMAGE_MESSAGE_PREFIX = 'IMAGE';
const URL_MESSAGE_PREFIX = 'URL';
const KNOWLEDGE_TABS = 'KNOWLEDGE_TAB';
const CAROUSEL_MESSAGE_PREFIX = 'CAROUSEL';
const ID_END = '~ID_END~';
const MAP_MESSAGE_PREFIX = 'MAP';
const TRANSCRIPTID_MESSAGE_PREFIX = 'TRANSCRIPT';
const SITE_MESSAGE_PREFIX = '{"[CUST-SIGNIN-STATUS]":';
const HIDE_QUESTION_PREFIX = 'HIDE_QUESTION';
const SNIPPET_NOTIF_PREFIX = 'SNIPPET_NOTIF';
const REDIRECT_DIALOG_PREFIX = '{"[REDIR-DLOG-MSG]":';
const HIDE_MESSAGE_INPUT_PREFIX = 'HIDE_MESSAGE_INPUT';
const SHOW_MESSAGE_INPUT_PREFIX = 'SHOW_MESSAGE_INPUT';
const SUPPORTED_MESSAGE_PREFIX = [DEFAULT_MESSAGE_PREFIX, RICHTEXT_MESSAGE_PREFIX, LONGTEXT_MESSAGE_PREFIX, YOUTUBE_MESSAGE_PREFIX, IMAGE_MESSAGE_PREFIX, URL_MESSAGE_PREFIX,KNOWLEDGE_TABS, CAROUSEL_MESSAGE_PREFIX, MAP_MESSAGE_PREFIX, HIDE_QUESTION_PREFIX, TRANSCRIPTID_MESSAGE_PREFIX, SNIPPET_NOTIF_PREFIX, REDIRECT_DIALOG_PREFIX, HIDE_MESSAGE_INPUT_PREFIX, SHOW_MESSAGE_INPUT_PREFIX];

const AVAILABLE_ORGS = ['ctpl', 'dcp', 'bos'];

export default class ChatMessageDefaultUI extends BaseChatMessage {
    @track
    mapMarkers = [];

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.detail.selectedMarkerValue;
    }

    messageType = DEFAULT_MESSAGE_PREFIX;

    // TRACKED
    content = '';
    @track ogpMeta = {};
    tab1Label;
    tab1Content;
    tab2Label;
    tab2Content;
    tab3Label;
    tab3Content;
    isSingleTabContent;
    longTextContent;
    hasRendered = false;
    feedbackRequired = false;
    feedbackSelected = false;
    mainMenuIds;
    loading = false;

    // This is called only once even though there are multiple instances of the component because of cacheable=true
    @wire(getMainMenuIds)
    wiredIds({ error, data }) {
        if (data) {
            this.mainMenuIds = data;
        } else if (error) {
            console.error('Error retrieving Sitecore main menu IDs: ' + JSON.stringify(error));
        }
    }

    connectedCallback() {
        window.dispatchEvent(new CustomEvent('beginCheckAuthentication'));
        if (!window.sessionStorage.getItem('chatKeyListenerAdded')) {
            window.addEventListener('chatKey', e => {
                window.sessionStorage.setItem('chatKey', e.detail);
            });
            window.dispatchEvent(new CustomEvent('getChatKey'));
            window.sessionStorage.setItem('chatKeyListenerAdded', true);
        }
        if (!window.sessionStorage.getItem('beginCustomerTransferListenerAdded')) {
            window.addEventListener('beginCustomerTransfer', e => {
                window.sessionStorage.setItem('org', e.detail.data);
                this.handleOrgTransfer();
            });
            window.sessionStorage.setItem('beginCustomerTransferListenerAdded', true);
        }
        if (!this.isAgent) {
            if (window.sessionStorage.getItem('transferInitiated') === 'true' && 
                AVAILABLE_ORGS.includes(this.messageContent.value.toLowerCase())) {
                window.sessionStorage.setItem('org', this.messageContent.value);
            }
        }
        const messageTypePrefixPosition = SUPPORTED_MESSAGE_PREFIX.indexOf(this.messageContent.value.split('~')[0]);
        if (messageTypePrefixPosition > -1) {
            this.messageType = SUPPORTED_MESSAGE_PREFIX[messageTypePrefixPosition];
        }
        let contentValue = (this.messageContent.value.split(this.messageType + '~').length === 1) ? this.messageContent.value : this.messageContent.value.split(this.messageType + '~')[1];

        if (contentValue.split(ID_END).length > 1) {
            this.sitecoreContentId = contentValue.split(ID_END)[0];
            contentValue = contentValue.split(ID_END)[1];
        }

        //Check if the message input should be shown or hidden
        if(this.isHideMessageInput){
            var event = new CustomEvent(
                "hide-message-input"
            );
            window.dispatchEvent(event);
        } else if(this.isShowMessageInput){
            var event = new CustomEvent(
                "show-message-input"
            );
            window.dispatchEvent(event);
        }

        if (this.isPlainText) {
            //console.log(window.sessionStorage.getItem('chatKey'));
            let chatKey = window.sessionStorage.getItem('chatKey');
            if (chatKey && sessionStorage.getItem('chatKey').split('-').length !== 5) {
                // reset chat key if key-value pairs are misaligned
                for (i = 0; i < sessionStorage.length; i++) {
                    if (sessionStorage.getItem(sessionStorage.key(i)) && sessionStorage.getItem(sessionStorage.key(i)).split('-').length === 5) {
                        window.sessionStorage.setItem('chatKey', sessionStorage.getItem(sessionStorage.key(i)));
                    }
                }
            }
            let initiation = 'I see you came here from ';
            let transferEvent = 'Transferring you now';
            let interOrgTransferToSource = 'Okay, let&#x27;s get you transferred to an agent from ';
            if (contentValue.includes(initiation)) {
                window.sessionStorage.setItem('transferInitiated', true);
            } else if (contentValue.includes(transferEvent)) {
                this.handleOrgTransfer();
            } else if (contentValue.includes(interOrgTransferToSource)) {
                window.sessionStorage.setItem('org',
                    contentValue.split(interOrgTransferToSource)[1].replace(/\./, '').trim());
            }
            this.content = contentValue;
        } else if (this.isYoutube) {
            this.content = 'https://www.youtube.com/embed/' + contentValue 
        } else if (this.isImage) {
            window.clearTimeout(this.delayTimeout);
            this.content = this.extractOriginalString(contentValue);
        } else if (this.isRichText) {
            let maxValue = parseInt(feedbackMaxValue);
            let feedbackCount = parseInt(window.sessionStorage.getItem('chatbotFeedbackCount'))
            if (feedbackCount && feedbackCount < maxValue) {
                window.sessionStorage.setItem('chatbotFeedbackCount', feedbackCount + 1);
            } else if (feedbackCount && feedbackCount === maxValue) {
                if (this.mainMenuIds && !this.mainMenuIds.includes(this.sitecoreContentId)) {
                    this.feedbackRequired = true;
                    window.sessionStorage.setItem('chatbotFeedbackCount', 1);
                }
            } else window.sessionStorage.setItem('chatbotFeedbackCount', 1);
            this.content = this.formatHtml(contentValue);
        } else if(this.isKnowledge) {
            this.buildTabContent(contentValue.replace(/&quot;/g, '"'));
            this.content = contentValue;
        } else if (this.isUrl) {
            var linkWithLabel = this.extractOriginalString(contentValue);
            this.content = linkWithLabel;
        } else if (this.isCarousel) {
            this.content = JSON.parse(contentValue.replace(/&quot;/g, '"')
                                                  .replace(/&#x27;/g, '\'')
                                                  .replace(/(<([^>]+)>)/ig, ""));
        } else if (this.isMap) {
            var unescapedContentValue = contentValue.replaceAll('&quot;','"');
            var jsonStringToObj = JSON.parse(unescapedContentValue);
            var i;
            var markerObj = {};
            for (i = 0; i < jsonStringToObj.length; i++) {
                markerObj = {
                    value: jsonStringToObj[i].name,
                    location: {
                        Latitude: jsonStringToObj[i].lat,
                        Longitude: jsonStringToObj[i].lon
                    },
                    title: jsonStringToObj[i].name,
                    description: jsonStringToObj[i].formatted_phone_number
                }
                this.mapMarkers.push(markerObj);
            }
        } else if (this.isSnippetNotification) {
            console.log('snippet notification evt: ' + contentValue);
            window.dispatchEvent(new CustomEvent('snippetNotification', {
                detail: contentValue
            }));
        }
        else {
            // Replace character entities with special characters
            // Replace <ol> tags with <ul> tags for indent spacing
            // Replace <li> tags with a hyphen and line break 
            
            this.content = this.formatHtml(contentValue);
        }

    }

    formatHtml(message) {
        // console.log('message: ' + JSON.stringify(message));
        let x = message.replace(/&amp;quot;/g, '"')
                        .replace(/&amp;/g, '&')
                        .replace(/&amp;#39;/g, '\'')
                        .replace(/&lt;/g, '<')
                        .replace(/&gt;/g, '>')
                        .replace(/<ol>/g, '<ul>')
                        .replace(/<\/ol>/g, '</ul>')
                        .replace(/<li>/g, ' - ')
                        .replace(/<\/li>/g, '<br/>')
                        .replace(/<a href='/g, '')
                        .replace(/&quot;/g, '\"')
                        .replace(/' target='_blank'.*?<\/a>( +)/g, '$1')
                        .replace(/' target='_blank'.*?<\/a>.*?<\/a>/g, '');

                        // console.log('altered message: ' + x);
                        return x;
    }

    handleFeedbackSelection(e) {
        if (this.feedbackSelected) return;
        const feedback = {
            articleId: this.sitecoreContentId,
            chatKey: window.sessionStorage.getItem('chatKey'),
            feedbackValue: null
        }
        if (e.target.classList.contains('like')) {
            e.target.classList.add('select-feedback');
            const dislikeButton = this.template.querySelector('.dislike');
            dislikeButton.classList.add('disable-feedback');
            feedback.feedbackValue = 1;
        } else {
            e.target.classList.add('select-feedback');
            const likeButton = this.template.querySelector('.like');
            likeButton.classList.add('disable-feedback');
            feedback.feedbackValue = 0;
        }
        this.loading = true;
        window.dispatchEvent(new CustomEvent('submitFeedback', { detail: 'start' }));
        submitFeedback(feedback)
            .then(result => {
                this.loading = false;
                this.feedbackSelected = true;
                window.dispatchEvent(new CustomEvent('submitFeedback', { detail: 'stop' }));
            })
            .catch(error => {
                console.error('Error submitting feedback: ', JSON.stringify(error));
            });
    }

    buildTabContent(content) {
        let tabObj = JSON.parse(content);
        var hasTab1 = tabObj.hasOwnProperty("tab1Label");
        var hasTab2 = tabObj.hasOwnProperty("tab2Label");
        var hasTab3 = tabObj.hasOwnProperty("tab3Label");
        
        if(hasTab1 && (!hasTab2 && !hasTab3)){
            this.isSingleTabContent = true;
        }

        if(hasTab1){
            this.tab1Label = tabObj.tab1Label;
            if(!tabObj.tab1Content){
                this.isKnowledge = false;
                return;
            }else{
                this.tab1Content = tabObj.tab1Content;
            }
        }
        if(hasTab2){
            this.tab2Label = tabObj.tab2Label;
            this.tab2Content = tabObj.tab2Content;
        }
        if(hasTab3){
            this.tab3Label = tabObj.tab3Label;
            this.tab3Content = tabObj.tab3Content;
        }   
    }

    fallback(event) {
        event.target.onerror = null;
        event.target.style.display = 'none';
        event.target.style.height = 0;
    }

    handleOrgTransfer() {
        setTimeout(() => {
            // The event doesn't fire properly unless wrapped in a setTimeout method
            let org = window.sessionStorage.getItem('org');
            let chatKey = window.sessionStorage.getItem('chatKey');
            let endChatEvent = new CustomEvent('endChat');
            window.dispatchEvent(endChatEvent);
            console.log('org: ' + org);
            console.log('chatKey: ' + window.sessionStorage.getItem('chatKey'));
            setTimeout(() => {
                getDetails({ org: org, chatKey: chatKey })
                    .then(result => {
                        let details;

                        if (result.transcript.Contact) {
                            details = {
                                firstName: result.transcript.Contact.FirstName,
                                lastName: result.transcript.Contact.LastName,
                                email: result.transcript.Contact.Email,
                                JSONDetails: result
                            }
                        } else {
                            details = {
                                JSONDetails: result
                            }
                        }
  
                        this.makeCallout(details);
                        let event = new CustomEvent('transfer', { 
                            detail: result
                        });
                        window.dispatchEvent(event);
                    })
                    .catch(error => {
                        console.log('error: ' + JSON.stringify(error));
                    });

            /* --- N.B. This is the amount of time to wait until the chat has fully ended and transcript loaded in the org --- */
            }, 6000);
        }, 2000);
    }

    makeCallout(details) {
        if (details.firstName) {
            checkForContact({ firstName: details.firstName, lastName: details.lastName, 
                email: details.email, JSONDetails: JSON.stringify(details.JSONDetails) })
                .then(result => {
                    console.log('result from makeCallout (checkForContact): ' + JSON.stringify(result));
                })
                .catch(error => {
                    console.log('makeCallout error (checkForContact): ' + JSON.stringify(error));
                });
        } else {
            sendTranscript({ JSONDetails: JSON.stringify(details.JSONDetails), totalContacts: 0, foundContactId: null })
                .then(result => {
                    console.log('result from makeCallout (sendTranscript): ' + JSON.stringify(result));
                })
                .catch(error => {
                    console.log('makeCallout error (sendTranscript): ' + JSON.stringify(error));
                });
        }
    }

    get isAgent() {
        return this.userType === 'agent';
    }

    get isPlainText() {
        return this.messageType === DEFAULT_MESSAGE_PREFIX;
    }

    get isRichText() {
        return this.messageType === RICHTEXT_MESSAGE_PREFIX;
    }

    get isLongText() {
        return this.messageType === LONGTEXT_MESSAGE_PREFIX;
    }

    get isYoutube() {
        return this.messageType === YOUTUBE_MESSAGE_PREFIX;
    }

    get isImage() {
        return this.messageType === IMAGE_MESSAGE_PREFIX;
    }

    get isUrl() {
        return this.messageType === URL_MESSAGE_PREFIX;
    }

    get isSiteMessage() {
        return this.messageContent.value.replace(/&quot;/g, '"').startsWith(SITE_MESSAGE_PREFIX);
    }

    get hasOGPInfo() {
        return this.ogpMeta.title !== undefined;
    }

    get isKnowledge() {
        return this.messageType === KNOWLEDGE_TABS;
    }

    get isCarousel() {
        return this.messageType === CAROUSEL_MESSAGE_PREFIX;
    }

    get isMap() {
        return this.messageType === MAP_MESSAGE_PREFIX;
    }

    get isHideQuestion() {
        return this.messageType === HIDE_QUESTION_PREFIX;
    }

    get isSnippetNotification() {
        return this.messageType === SNIPPET_NOTIF_PREFIX;
    }

    get isRedirectDialog() {
        return this.messageContent.value.replace(/&quot;/g, '"').startsWith(REDIRECT_DIALOG_PREFIX);
    }

    get isShowMessage() {
        return !this.messageContent.value.replace(/&quot;/g, '"').startsWith(SITE_MESSAGE_PREFIX)
            && !this.messageContent.value.replace(/&quot;/g, '"').startsWith(REDIRECT_DIALOG_PREFIX);
    }

    get isHideMessageInput() {
        return this.messageType === HIDE_MESSAGE_INPUT_PREFIX;
    }

    get isShowMessageInput() {
        return this.messageType === SHOW_MESSAGE_INPUT_PREFIX;
    }
}