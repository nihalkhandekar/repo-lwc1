import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import updateBusinessDetail from "@salesforce/apex/BusinessSearchController.updateBusinessDetail";
import linkFindBiz_PageHeader from '@salesforce/label/c.linkFindBiz_PageHeader';
import linkFindBiz_FindCredential from '@salesforce/label/c.linkFindBiz_FindCredential';
import linkFindBiz_ConfirmSelection from '@salesforce/label/c.linkFindBiz_ConfirmSelection';
import businessProfile_linkCredentialsButton from '@salesforce/label/c.businessProfile_linkCredentialsButton';
import doCredentialContactSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialContactSearch";
import doCredentialAutoSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialAutoSearch";
import getLinkedBusiness from "@salesforce/apex/BusinessSearchController.getLinkedBusiness";
import linkFindBiz_Summary from '@salesforce/label/c.linkFindBiz_Summary';
import checkforBusinessVerification from '@salesforce/apex/BusinessSearchController.checkforBusinessVerification';
import updateCredCounter from '@salesforce/apex/Bos_VerificationController.updateCredCounter';
import checkCredentialVerificationSwitch from "@salesforce/apexContinuation/BusinessSearchController.checkCredentialVerificationSwitch";
import doupdateIdsInForgerock from "@salesforce/apexContinuation/BusinessSearchController.doupdateIdsInForgerock";
import verifyPreVeriedCredentials from "@salesforce/apex/Bos_VerificationController.verifyPreVeriedCredentials";
import business_creds from '@salesforce/label/c.business_creds';
import IsVerificationRequired from '@salesforce/label/c.IsVerificationRequired';
import bizDashboard_AddCredential from '@salesforce/label/c.bizDashboard_AddCredential';
import bizDashboard_MatchCreds from '@salesforce/label/c.bizDashboard_MatchCreds';
import linkFindBiz_IdentifyBusinesss from '@salesforce/label/c.linkFindBiz_IdentifyBusinesss';
import bizDashboard_redirectUrl from '@salesforce/label/c.bizDashboard_redirectUrl';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import isGuestUser from '@salesforce/user/isGuest';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import { insertRecord } from "c/genericAnalyticsRecord";
import { ComponentErrorLoging } from "c/formUtility";
export default class Link_business extends LightningElement {
    @track flowObj;
    @track currentObj;
    @api singleBusiness;
    @track bizList = [];
    @track verifiedBusinessIds = [];
    @track findyourbiz = true;
    @track bizconfirm = false;
    @track linkcred = false;
    @track sidenavobj;
    @track findyourcred = false;
    @track credconfirm = false;
    @track matchcred = false;
    @track bizrole = false;
    @track linkCredOption = null;
    @track backToCreds = false;
    @track acountID = '001r000000MCS3NAAX';
    @track summary = false;
    @track addAnotherBiz = null;
    @track showSuccessMsg = false;
    @track morecredrecom;
    @track linkBusinessComplete = false;
    @track showCancel = false;
    @track bizAdd = false;
    @track showFirstRecoms;
    @track showSecondRecoms;
    @track isCredFlow = true;
    @track credrecommends;
    @track showExceedCard = false;
    @track screenValidationPassed = false;
    @track previousAddedBiz;
    @track credVerification = false;
    @track testOpts = [{
            label: "Yes, let me search for my credentials",
            value: "Yes, let me search for my credentials"
        },
        {
            label: "No, not right now",
            value: "No, not right now"
        }
    ];
    @track searchEmptyError = false;
    @track errorMessage;
    @track selectedBusinessList = [];
    @track mainDataObj = {
        'bizList': [],
        'credsList': []
    };
    @track credpreverfied = [];
    @track selectedPrincipal = [];
    @track selectedAgent;
    @track manualSearch = false;
    @track bizRoleId;
    @track linkcredentials;
    @track showbizsummary;
    @track flowPercentage;
    @track language;
    @track param = 'language';
    @api link = "";
    @track credsearchterm;
    @track openModal;
    @track businessVerified = false;
    @track credsList = [];
    @track allCredsVerified = false;
    @track userDetails = [];
    @track verifylater = false;
    @track showSkipNow = false;
    @track comingFromParent = false;
	@track startTime;

    connectedCallback() {
        let state = Object.assign({}, history.state);
        state.page = 'linkBusiness';
        history.pushState(state, document.title, window.location.pathname);
        // NDS 01.07.21 disable back button for pushState-created entries
        // when navigating forward in this LWC, history.pushState is added
        // this onpopstate event fires when pushState is unloaded back button
        // per direction from Deloitte CT Account team, decision to disable back 
        // button inside of flows like Renewal
        window.onpopstate = (ev) => {
            setTimeout(() => {
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }, 0);       
            // get the state for the history entry the user is going to be on            
            let state = Object.assign({}, history.state);
            window.history.pushState(state, document.title, window.location.pathname);
        };
		this.startTime = new Date().getTime();
        Object.keys(sessionStorage).forEach((key) => {
            if (key !== "businessid") {
                sessionStorage.removeItem(key);
            }
        });
        window.pageName = 'linkbusiness';
        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        if ((window.location.href.indexOf('linkcredentials') > -1)) {
            if (sessionStorage.getItem("businessid")) {
                this.flowObj = {
                    "findyourcred": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "linkcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "findyourcred",
                        "compName": "c-link_find-your-cred"
                    },
                    "credconfirm": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "summary",
                        "compRef": "credconfirm",
                        "compName": "c-link_cred-confirm"
                    },
                    "summary": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "credconfirm",
                        "nextyes": null,
                        "nextno": null,
                        "next": "confirmation",
                        "compRef": "summary",
                        "compName": "c-link_summary"
                    },
                    "credsearch": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "credsearch",
                        "compName": "c-link_cred-manual-search"
                    },
                    "credmore": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "credmore",
                        "compName": "c-link_cred-recom-more"
                    }
                };
                this.sidenavobj = {
                    "sections": [{
                            "subSection": [{
                                "subSectionName": linkFindBiz_ConfirmSelection,
                                "subComponentName": "c-link_cred-confirm",
                                "status": "locked",
                                "pageNameRef": "credconfirm",
                                "show": true
                            }],
                            "sectionName": bizDashboard_AddCredential,
                            "componentName": "c-link_find-your-cred",
                            "status": "active",
                            "pageNameRef": "findyourcred"
                        },
                        {
                            "subSection": [],
                            "status": "locked",
                            "sectionName": linkFindBiz_Summary,
                            "pageNameRef": "summary",
                            "componentName": "c-link_summary"
                        }
                    ],
                    "flowName": "Driver's license renewal",
                    "firstName": ""
                };
            } else {
                this.flowObj = {
                    "findyourcred": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "linkcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "findyourcred",
                        "compName": "c-link_find-your-cred"
                    },
                    "credconfirm": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "matchcred",
                        "compRef": "credconfirm",
                        "compName": "c-link_cred-confirm"
                    },
                    "matchcred": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "credconfirm",
                        "nextyes": null,
                        "nextno": null,
                        "next": "summary",
                        "compRef": "matchcred",
                        "compName": "c-link_match-cred"
                    },
                    "summary": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "matchcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "confirmation",
                        "compRef": "summary",
                        "compName": "c-link_summary"
                    },
                    "credsearch": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "credsearch",
                        "compName": "c-link_cred-manual-search"
                    },
                    "credmore": {
                        "status": "locked",
                        "prevStatus": "",
                        "previous": "findyourcred",
                        "nextyes": null,
                        "nextno": null,
                        "next": "credconfirm",
                        "compRef": "credmore",
                        "compName": "c-link_cred-recom-more"
                    }
                };
                this.sidenavobj = {
                    "sections": [{
                            "subSection": [{
                                    "subSectionName": linkFindBiz_ConfirmSelection,
                                    "subComponentName": "c-link_cred-confirm",
                                    "status": "locked",
                                    "pageNameRef": "credconfirm",
                                    "show": true
                                },
                                {
                                    "subSectionName": bizDashboard_MatchCreds,
                                    "subComponentName": "c-link_match-cred",
                                    "status": "locked",
                                    "pageNameRef": "matchcred",
                                    "show": true
                                }
                            ],
                            "sectionName": bizDashboard_AddCredential,
                            "componentName": "c-link_find-your-cred",
                            "status": "active",
                            "pageNameRef": "findyourcred"
                        },
                        {
                            "subSection": [],
                            "status": "locked",
                            "sectionName": linkFindBiz_Summary,
                            "pageNameRef": "summary",
                            "componentName": "c-link_summary"
                        }
                    ],
                    "flowName": "Driver's license renewal",
                    "firstName": ""
                };
            }
            this.findyourbiz = false;
            var accountID;
            if (sessionStorage.getItem("businessid")) {
                accountID = sessionStorage.getItem("businessid");
                this.showbizsummary = true;
                //sessionStorage.removeItem("businessid");
            } else {
                accountID = null;
            }
            getLinkedBusiness({
                accountID: accountID
            })
            .then(result => {
                this.mainDataObj.bizList = result;
                this.linkcredentials = true;
                this.checkFirstRecoms();
            })
            .catch(error => {
                ComponentErrorLoging(this.compName, 'getLinkedBusiness', '', '', 'High', error.message);
            });
        } else {
            this.flowObj = {
                "findyourbiz": {
                    "status": "active",
                    "prevStatus": "",
                    "previous": null,
                    "nextyes": null,
                    "nextno": null,
                    "next": "bizrole",
                    "compRef": "findyourbiz",
                    "compName": "c-link_find-your-biz"
                },
                "bizrole": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "findyourbiz",
                    "nextyes": null,
                    "nextno": null,
                    "next": "bizconfirm",
                    "compRef": "bizrole",
                    "compName": "c-link_biz-role"
                },
                "bizconfirm": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "bizrole",
                    "nextyes": null,
                    "nextno": null,
                    "next": "linkcred",
                    "compRef": "bizconfirm",
                    "compName": "c-link_biz-confirm"
                },
                "linkcred": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "bizconfirm",
                    "nextyes": null,
                    "nextno": null,
                    "next": "findyourcred",
                    "compRef": "linkcred",
                    "compName": "c-link_cred-link"
                },
                "findyourcred": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "linkcred",
                    "nextyes": null,
                    "nextno": null,
                    "next": "credconfirm",
                    "compRef": "findyourcred",
                    "compName": "c-link_find-your-cred"
                },
                "credconfirm": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "findyourcred",
                    "nextyes": null,
                    "nextno": null,
                    "next": "matchcred",
                    "compRef": "credconfirm",
                    "compName": "c-link_cred-confirm"
                },
                "matchcred": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "credconfirm",
                    "nextyes": null,
                    "nextno": null,
                    "next": "summary",
                    "compRef": "matchcred",
                    "compName": "c-link_match-cred"
                },
                "summary": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "matchcred",
                    "nextyes": null,
                    "nextno": null,
                    "next": "confirmation",
                    "compRef": "summary",
                    "compName": "c-link_summary"
                },
                "credsearch": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "findyourcred",
                    "nextyes": null,
                    "nextno": null,
                    "next": "credconfirm",
                    "compRef": "credsearch",
                    "compName": "c-link_cred-manual-search"
                },
                "credmore": {
                    "status": "locked",
                    "prevStatus": "",
                    "previous": "findyourcred",
                    "nextyes": null,
                    "nextno": null,
                    "next": "credconfirm",
                    "compRef": "credmore",
                    "compName": "c-link_cred-recom-more"
                }
            };
            this.sidenavobj = {
                "sections": [{
                        "subSection": [{
                                "subSectionName": linkFindBiz_IdentifyBusinesss,
                                "subComponentName": "c-link_biz-role",
                                "status": "locked",
                                "pageNameRef": "bizrole",
                                "show": true
                            },
                            {
                                "subSectionName": linkFindBiz_ConfirmSelection,
                                "subComponentName": "c-link_biz-confirm",
                                "status": "locked",
                                "pageNameRef": "bizconfirm",
                                "show": true
                            }
                        ],
                        "status": "active",
                        "sectionName": linkFindBiz_PageHeader,
                        "pageNameRef": "findyourbiz",
                        "componentName": "c-link_find-your-biz"
                    },
                    {
                        "subSection": [{
                                "subSectionName": linkFindBiz_FindCredential,
                                "subComponentName": "c-link_find-your-cred",
                                "status": "locked",
                                "pageNameRef": "findyourcred",
                                "show": true
                            },
                            {
                                "subSectionName": linkFindBiz_ConfirmSelection,
                                "subComponentName": "c-link_cred-confirm",
                                "status": "locked",
                                "pageNameRef": "credconfirm",
                                "show": true
                            },
                            {
                                "subSectionName": bizDashboard_MatchCreds,
                                "subComponentName": "c-link_match-cred",
                                "status": "locked",
                                "pageNameRef": "matchcred",
                                "show": true
                            }

                        ],
                        "status": "locked",
                        "sectionName": business_creds,
                        "pageNameRef": "linkcred",
                        "componentName": "c-link_cred-link"
                    },
                    {
                        "subSection": [],
                        "status": "locked",
                        "sectionName": linkFindBiz_Summary,
                        "pageNameRef": "summary",
                        "componentName": "c-link_summary"
                    }
                ],
                "flowName": "Driver's license renewal",
                "firstName": ""
            };
            this.findyourbiz = true;
        }
        this.getCurrentObj();
        const labelName = metadataLabel;

        fetchInterfaceConfig({
                labelName
            })
            .then(result => {
                var parsedResult = JSON.parse(JSON.stringify(result));

                if (isGuestUser) {
                    var url_string = document.location.href;
                    this.current_url = url_string;
                    var url = new URL(url_string);

                    var arr = url_string.split("?");
                    if (url_string.length > 1 && arr[1] !== "") {
                        var URLParams = url.searchParams;
                        this.language = URLParams.get(this.param);
                    }
                    this.ForgeRock_End_URL = parsedResult.ForgeRock_End_URL__c
                    this.link = this.ForgeRock_End_URL;
                   // this.setCookies();
                } else {
                    this.link = parsedResult.End_URL__c;
                }
            })
        if (this.mainDataObj.bizList == null && this.mainDataObj.bizList.length == 0)
            this.selectedBusinessList = [];



    }

    verifyLater() {
        this.verifylater = true;
        this.manualSearch = true;
        this.closeModal();
        this.updateFlow();
    }

    updateCredSearch() {
        this.showSkipNow = true;        
        this.manualSearch = true;
        this.handleNextEvent();
    }

    getCurrentObj() {
        var flowObj = this.flowObj;
        var key;
        if (flowObj) {
            for (key in flowObj) {
                if (flowObj[key].status === "active") {
                    this.currentObj = flowObj[key];
                }
            }
        }
    }

    deSelectCreds(event) {
        var id1 = event.detail;
        this.mainDataObj.credsList.forEach((element, i) => {
            if (id1 == element.value) {
                this.mainDataObj.credsList.splice(i, 1);
            }
        });
    }

    handleRoleDeselect(event) {
        var bizid = event.detail;
    
        if (this.mainDataObj.bizList) {
            if (this.mainDataObj.bizList.length) {
                this.mainDataObj.bizList.forEach(element => {
                    if (element.principalDetails) {
                        if (element.principalDetails.length) {
                            element.principalDetails.forEach((el, i) => {
                                if (el.id === bizid) {
                                    element.principalDetails.splice(i, 1);
                                }
                            });
                        }
                    }
                });
            }
        }
    }

    updateCredSearchTerm(event) {
        this.credsearchterm = event.detail;
    }

    updateCreds(event) {
        var options = event.detail;
        var opts1 = options;
        var opts2 = this.mainDataObj.credsList;
        const opts1IDs = new Set(opts1.map(({
            eLicense_Credential_ID
        }) => eLicense_Credential_ID));
        const combined = [
            ...opts1,
            ...opts2.filter(({
                eLicense_Credential_ID
            }) => !opts1IDs.has(eLicense_Credential_ID))
        ];
        this.mainDataObj.credsList = combined;
        this.mainDataObj.credsList = JSON.parse(JSON.stringify(this.mainDataObj.credsList));
        if (sessionStorage.getItem("businessid")) {
            this.mainDataObj.credsList.forEach(element => {
                element.businessRecordID = this.mainDataObj.bizList[0].id;
                element.isContactCred = false;
            });
        }
    }

    pageRedirect(event) {
        let pageName = event.detail.pageName;
        if (event.detail.bizid) {
            this.bizRoleId = event.detail.bizid
            let temp;
            this.mainDataObj.bizList.forEach(element => {
                if (element.id == this.bizRoleId) {
                    temp = element;
                }
            });
            this.bizRoleId = temp;
            this.singleBusiness = this.bizRoleId;
            this.addAnotherBiz = 'back'
        }
        if (pageName === 'matchcred' && this.mainDataObj.credsList.length === 0) {
            this.backToCreds = true;
            this.summary = false;
            this.checkFirstRecoms();
            return;
        } else if(pageName === 'matchcred' && this.linkcredentials && sessionStorage.getItem("businessid")) {
            pageName = 'credconfirm';
        }
        if (pageName === 'bizconfirm') {
            this.addAnotherBiz = 'back'
        }
        var currObj = JSON.parse(JSON.stringify(this.currentObj));
        var flowObj = JSON.parse(JSON.stringify(this.flowObj));
        currObj.status = currObj.prevStatus;
        flowObj[currObj.compRef] = currObj;
        this.flowObj = flowObj;
        currObj = flowObj[pageName];
        currObj.prevStatus = currObj.status;
        currObj.status = 'active';
        this.currentObj = currObj;
        this.updateScreen(currObj.compRef);
    }

    handleCancelEvent() {
        this.addAnotherBiz = "No";
        this.updateFlow();
        this.isCredFlow = false;
    }

    handleBackEvent(event) {
        try {
            var currObj = JSON.parse(JSON.stringify(this.currentObj));
            var flowObj = JSON.parse(JSON.stringify(this.flowObj));
            let prevStatus = currObj.prevStatus;
            this.isCredFlow = false;
            this.bizAdd = false;
            if (this.linkcred || this.summary || this.findyourcred) {
                this.addAnotherBiz = 'back';
            }
            if (prevStatus) {
                currObj = JSON.parse(JSON.stringify(this.currentObj));
                currObj.prevStatus = currObj.status;
                currObj.status = prevStatus;
            } else {
                currObj.status = 'locked';
            }
            if ((currObj.previous === 'findyourcred' || currObj.previous === 'credsearch') && this.linkcredentials && flowObj[currObj.previous].previous === null) {
                this.isCredFlow = true;
            }
            flowObj[currObj.compRef] = currObj;
            this.flowObj = flowObj;
            this.updateSideNavStatus(currObj.compRef, currObj.status, currObj.prevStatus);
            currObj = flowObj[currObj.previous];
            currObj.prevStatus = currObj.status;
            currObj.status = "active";
            this.currentObj = currObj;
            this.updateSideNavStatus(currObj.compRef, currObj.status, currObj.prevStatus);
            this.updateScreen(this.currentObj.compRef);
            this.calculateProgress();
        } catch (error) {
            ComponentErrorLoging(this.compName, 'handleBackEvent', '', '', 'High', error.message);
        }
    }

    /**
     * @function showModal - method written to open business verification modal
     * @param {event} - event triggered
     */
    showModal() {
        this.openModal = true;
    }

    /**
     * @function closeModal - method written to close business verification modal
     * @param {event} - event triggered
     */
    closeModal() {
		let targetText = this.credVerification ? "Link Credential" : "Link Business";
        let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
        this.insertAnalyticsEvent(eventType,"Close Modal", "", targetText);
        this.openModal = false;
    }

    updatePreVerifiedBizPro(event) {
        this.updatePreVerifiedBiz(event);
    }
    updatePreVerifiedBiz(event) {
        var custid = event.detail.custid;
        var email = event.detail.email;
        var id = event.detail.id;
        if (this.singleBusiness) {
            var temp = {
                customerID: custid,
                email: email,
                id: id
            }
            this.userDetails.push(temp);
        }
    }

    moveToNext(_event) {
        this.closeModal();
        if (this.credVerification) {
            this.allCredsVerified = true;
        } else {
           
             let customerID = _event.detail.custid

             let bid = _event.detail.id;
             this.verifiedBusinessIds.push({custid:customerID,id:bid});
             this.businessVerified = true;
        }
        this.handleNextEvent();
    }

    credSuccess(event) {
        var credId = event.detail;
        this.mainDataObj.credsList.forEach(element => {
            if(element.eLicense_Credential_ID === credId) {
                element.isCredIdVerified = true;
                element.isEmailVerified = true;
                var temp = {
                    customerID: element.Cust_ID,
                    email: element.Cust_Email,
                    id: ''
                }
                this.credpreverfied.push(temp);
            }
            if(element.eLicense_Dupcred_ID === credId) {
                element.isCredIdVerified = true;
                element.isEmailVerified = true;
            }
        });
    }

    handleNextEvent(event) {
        if(!this.manualSearch) {
            this.showSkipNow = false;
        }
        this.comingFromParent = false;
        if (this.findyourbiz) {
            this.addAnotherBiz = null;
            var element = this.template.querySelector(this.currentObj.compName);
            if (element) {
                let screenValidationPassed = element.validateScreen();
                if (screenValidationPassed) {
                    if (!this.businessVerified) {
                    checkforBusinessVerification({
                        accountID: this.singleBusiness.id,
                        isEmailOnly: false,
                        preVerified: JSON.stringify(this.userDetails)
                    })
                    .then(result => {
                        if (!result) {
                            let targetText = this.credVerification ? "Link Credential" : "Link Business";
                            let eventType = (targetText == "Link Credential") ? " Credential Verification Start" : " Business Verification Start";
                            this.insertAnalyticsEvent(eventType,"Verification start", "", targetText);
                        

                            this.showModal();
                        } else {
                            let targetText = this.credVerification ? "Link Credential" : "Link Business";
                            let eventType = (targetText == "Link Credential") ? "Successful Credential Verifications" : "Successful Business Verifications";
                            this.insertAnalyticsEvent(eventType,"Already Verified", "", targetText);
                            this.isCredFlow = false;
                            this.updateFlow();
                        }
                    })
                } else {
                        this.isCredFlow = false;
                        this.closeModal();
                        this.updateFlow();
                    }
                } else {
                    this.searchEmptyError = true;
                    this.errorMessage = element.validationMessage();
                }
            }
        } else if (this.findyourcred || this.credsearch || this.credmore) {
            this.credsList = [];
            if (!this.allCredsVerified) {
                this.credVerification = true;
                var tempMainDataObj = [];
                var tempVerifiedCreds = [];
                this.mainDataObj.credsList.forEach(element => {
                        if (!element.isEmailVerified || !element.isCredIdVerified) {
                            tempMainDataObj.push(element);
                        } else {
                            let targetText = this.credVerification ? "Link Credential" : "Link Business";
                            let eventType = (targetText == "Link Credential") ? "Successful Credential Verifications" : "Successful Business Verifications";
                            this.insertAnalyticsEvent(eventType,"Already Verified", "", targetText);
                           
                            tempVerifiedCreds.push(element);
                        }
                });
                if(tempMainDataObj.length) {
                    checkCredentialVerificationSwitch({
                        credentials: JSON.stringify(tempMainDataObj)
                    })
                    .then(resultdata => {
                        if(this.credpreverfied && this.credpreverfied.length) {
                            this.credpreverfied = JSON.stringify(this.credpreverfied)
                        } else {
                            this.credpreverfied = null;
                        }
                    
                        verifyPreVeriedCredentials({
                                credentials: resultdata,
                                preVerified: this.credpreverfied
                        })
                        .then(result => {
                            if (result) {
                                result = JSON.parse(result);
                                tempVerifiedCreds.forEach(el => {
                                    result.push(el);
                                });
                                
                                updateCredCounter({
                                    credList: JSON.stringify(result)
                                })
                                .then((res) => {
                                    var newcredsList = JSON.parse(res);

                                    newcredsList.forEach(ele => {
                                        if(ele.isEmailVerified && ele.isCredIdVerified) {
                                            if(ele.eLicense_Dupcred_ID) {
                                                this.mainDataObj.credsList.forEach(elem => {
                                                    if(elem.eLicense_Credential_ID === ele.eLicense_Dupcred_ID) {
                                                        elem.isEmailVerified = true;
                                                        elem.isCredIdVerified = true;
                                                        elem.eLicense_Dupcred_ID = ele.eLicense_Credential_ID;
                                                    }
                                                })
                                            } else {
                                                this.mainDataObj.credsList.forEach(elem => {
                                                    if (elem.eLicense_Credential_ID === ele.eLicense_Credential_ID) {
                                                        elem.isEmailVerified = true;
                                                        elem.isCredIdVerified = true;
                                                    }
                                                })
                                            }
                                        } else {
                                            if(ele.eLicense_Dupcred_ID) {
                                                this.mainDataObj.credsList.forEach(elem => {
                                                    if(elem.eLicense_Credential_ID === ele.eLicense_Credential_ID) {
                                                        elem.eLicense_Dupcred_ID = ele.eLicense_Dupcred_ID;
                                                    }
                                                })
                                            }
                                        }
                                    });
                                    
                                    this.mainDataObj.credsList.forEach(element => {
                                        if(!element.eLicense_Dupcred_ID) {
                                            if (!element.isEmailVerified || !element.isCredIdVerified) {
                                                if (!this.containsObject(element, this.credsList)) {
                                                    this.credsList.push(element);
                                                }
                                            }
                                        }
                                    });
                                    if (this.credsList.length && IsVerificationRequired.toLowerCase() !== 'false') {
                                        this.showModal();
                                    } else if(IsVerificationRequired.toLowerCase() === 'false') {
                                        this.mainDataObj.credsList = newcredsList;
                                        let targetText = this.credVerification ? "Link Credential" : "Link Business";
                                        let eventType = (targetText == "Link Credential") ? "Successful Credential Verifications" : "Successful Business Verifications";
                                        this.insertAnalyticsEvent(eventType,"Already Verified", "", targetText);
                                    
                                        this.checkSecondRecoms();
                                    } else {
                                        this.checkSecondRecoms();
                                    }
                                })
                                .catch((error) => {
                                    ComponentErrorLoging(this.compName, 'handleBackEvent', '', '', 'High', error.message);
                                });
                            }
                        })
                        .catch(error => {
                            ComponentErrorLoging(this.compName, 'verifyPreVeriedCredentials', '', '', 'High', error.message);
                        })
                    })
                    .catch(error => {
                        ComponentErrorLoging(this.compName, 'checkCredentialVerificationSwitch', '', '', 'High', error.message);
                    })
                } else {
                    this.checkSecondRecoms();
                }
            } else {
                this.checkSecondRecoms();
            }
            this.allCredsVerified = false;
        } else {
            var currObj = JSON.parse(JSON.stringify(this.currentObj));
            var element = this.template.querySelector(currObj.compName);
            
            this.isCredFlow = false;
            if (this.bizrole) {
                this.comingFromParent = true;
                this.flowObj['bizconfirm'].previous = 'bizrole';
                if(this.selectedBusinessList.indexOf(this.singleBusiness.id) === -1) {
                    this.selectedBusinessList.push(this.singleBusiness.id);
                }
                this.singleBusiness = JSON.parse(JSON.stringify(this.singleBusiness));
                if (this.selectedPrincipal || this.selectedPrincipal == null) {
                    this.singleBusiness.principalDetails = this.selectedPrincipal;
                }
                if (this.selectedAgent || this.selectedAgent == null) {
                    this.singleBusiness.listedAgent = this.selectedAgent;
                }
                var bizListArray = this.bizList;
                if (bizListArray && bizListArray.length !== 0) {
                    var addBiz = true;
                    addBiz = bizListArray.every(business => this.singleBusiness.id !== business.id);
                    if (addBiz) {
                        this.bizList.push(this.singleBusiness);
                    } else {
                        let temp = [];
                        this.bizList.forEach(element => {

                            if (element.id === this.singleBusiness.id) {
                                element = this.singleBusiness;
                                temp.push(this.singleBusiness);
                            } else {
                                temp.push(element);
                            }
                        })
                        this.bizList = temp;
                    }
                } else {
                    this.bizList.push(this.singleBusiness);
                }
                this.mainDataObj.bizList = this.bizList;
            }
            
            if (element) {
                let screenValidationPassed = element.validateScreen();
                if (screenValidationPassed) {
                    this.searchEmptyError = false;
                    if (this.summary) {
                        sessionStorage.removeItem("businessid");
                        var finalBizList;
                        if ((window.location.href.indexOf('linkcredentials') > -1)) {
                            finalBizList = null;
                        } else {
                            finalBizList = JSON.stringify(this.mainDataObj.bizList);
                        }
                        // var finalBizListtoFR=null;
                        // if (this.verifiedBusinessIds!=null && this.verifiedBusinessIds.length >0) {
                        //     finalBizListtoFR = JSON.stringify(this.verifiedBusinessIds);
                        // } 
                       
                        this.doBusinessUpdate(finalBizList);
                       
                       /* doupdateIdsInForgerock({
                            businessData: finalBizListtoFR,credentialData:JSON.stringify(this.mainDataObj.credsList)
                        })
                        .then(result => {
                            
                        })
                        .catch(error => {
                            this.doBusinessUpdate(finalBizList);
                            ComponentErrorLoging(
                                this.compName,
                                "fetchResources",
                                "",
                                "",
                                "Medium",
                                error.message
                            );
                        });*/
                    }

                    if (this.linkcred === true && this.linkCredOption.includes('Yes')) {
                        this.checkFirstRecoms();
                    } else if (this.credsearch === true || this.findyourcred === true) {
                        this.checkSecondRecoms();
                    } else {
                        this.updateFlow();
                    }
                } else {
                    this.searchEmptyError = true;
                    this.errorMessage = element.validationMessage();
                }
            }
        }
    }


doBusinessUpdate(finalBizList){
    updateBusinessDetail({
        businessData: finalBizList,
        credentialData: JSON.stringify(this.mainDataObj.credsList)
    })
    .then(_result => {
        //CTBOS-4897 | Show toast message
        this.disableUnload = true;
        localStorage.setItem('showToast', true);
        window.location.href = bizDashboard_redirectUrl;
        setTimeout(function () {
            this.showSuccessMsg = true;
        }, 3000);
    })
    .catch(error => {
        ComponentErrorLoging(
            this.compName,
            "fetchResources",
            "",
            "",
            "Medium",
            error.message
        );
    });
}

    noErrorDispatch() {
        this.searchEmptyError = false;
    }

    containsObject(obj, list) {
        var i;
        for (i = 0; i < list.length; i++) {
            if (list[i].eLicense_Credential_ID === obj.eLicense_Credential_ID) {
                return true;
            }
        }
        return false;
    }


    updateFlow() {
        var currObj = JSON.parse(JSON.stringify(this.currentObj));
        var flowObj = JSON.parse(JSON.stringify(this.flowObj));
        this.showCancel = true;
        currObj.prevStatus = currObj.status;
        currObj.status = "completed";
        flowObj[currObj.compRef] = currObj;
        this.flowObj = flowObj;
        this.updateSideNavStatus(currObj.compRef, currObj.status, currObj.prevStatus);
        if (this.manualSearch) {
            currObj = flowObj['credsearch'];
            this.manualSearch = false;
            if (this.isCredFlow) {
                this.isCredFlow = false;
            }
        } else if (this.linkcred === true && this.linkCredOption.includes('No')) {
            this.linkBusinessComplete = true;
            currObj = flowObj['summary'];
            currObj.previous = 'linkcred';
        } else if ((this.linkcred === true && this.linkCredOption.includes('Yes')) || this.backToCreds === true) {
            this.linkBusinessComplete = false;
            if (this.showFirstRecoms) {
                currObj = flowObj['findyourcred'];
                flowObj['credconfirm'].previous = 'findyourcred';
            } else {
                currObj = flowObj['credsearch'];
                flowObj['credconfirm'].previous = 'credsearch';
            }
            this.backToCreds = false;
        } else if (this.credsearch === true || this.findyourcred === true) {
            this.isCredFlow = false;
            if (this.showSecondRecoms) {
                currObj = flowObj['credmore'];
            } else {
                currObj = flowObj['credconfirm'];
            }
        } else if (this.bizconfirm === true && this.addAnotherBiz === 'Yes') {
            this.showCancel = true;
            this.bizAdd = true;
            currObj = flowObj['findyourbiz'];
        } else if (this.bizconfirm === true && this.addAnotherBiz === '') {
            this.showCancel = true;
            this.bizAdd = true;
            currObj = flowObj['findyourbiz'];
        } else if (this.findyourbiz === true && this.addAnotherBiz === 'No') {
            currObj = flowObj['bizconfirm'];
        } else {
            currObj = flowObj[currObj.next];
        }
        currObj.prevStatus = currObj.status;
        currObj.status = "active";
        this.currentObj = currObj;
        this.updateScreen(this.currentObj.compRef);
        this.updateSideNavStatus(this.currentObj.compRef, this.currentObj.status, this.currentObj.prevStatus);
        this.calculateProgress();
    }
    checkSecondRecoms() {
        var credsList = this.mainDataObj.credsList;
        credsList = JSON.parse(JSON.stringify(credsList));
        doCredentialContactSearch({
            credentialDetail: JSON.stringify(credsList)
        })
        .then(result => {
            if (result === 'limitexceeded') {
                this.morecredrecom = [];
                this.showSecondRecoms = true;
                this.flowObj['credmore'].status = 'active';
            } else {
                result = JSON.parse(result);
                this.morecredrecom = result.credentials;
                if (this.morecredrecom[0].eLicense_Credential_ID) {
                    this.showSecondRecoms = true;
                } else {
                    this.showSecondRecoms = false;
                }
            }
            this.updateFlow();
        })
        .catch(error => {
            ComponentErrorLoging(this.compName, 'doCredentialContactSearch', '', '', 'High', error.message);
        });
    }
    checkFirstRecoms() {
        var bizList = JSON.parse(JSON.stringify(this.mainDataObj.bizList));
        doCredentialAutoSearch({
            businessDetail: JSON.stringify(bizList)
        })
            .then(result => {
                if (result) {
                    //result = 'limitexceeded';
                    if (result === 'limitexceeded') {
                        this.credrecommends = [];
                        this.findyourcred = true;
                        this.showFirstRecoms = true;
                        this.flowObj['findyourcred'].status = 'active';
                    } else {
                        result = JSON.parse(result);
                        this.credrecommends = result.credentials;
            
                        if (this.credrecommends[0].eLicense_Credential_ID) {
                            if (!this.linkcredentials) {
                                this.showFirstRecoms = true;
                            } else {
                                this.isCredFlow = true;
                                this.findyourcred = true;
                                this.flowObj['findyourcred'].status = 'active';
                                this.flowObj['findyourcred'].previous = null;
                                this.currentObj = this.flowObj.findyourcred;
                            }
                            this.flowObj['credconfirm'].previous = 'findyourcred';
                            this.flowObj['credmore'].previous = 'findyourcred';
                        } else {
                            if (!this.linkcredentials) {
                                this.showFirstRecoms = false;
                                this.flowObj['credsearch'].previous = 'linkcred';
                            } else {
                                this.isCredFlow = true;
                                this.credsearch = true;
                                this.flowObj['credsearch'].status = 'active';
                                this.flowObj['credsearch'].previous = null;
                                this.currentObj = this.flowObj.credsearch;
                            }
                            this.flowObj['credconfirm'].previous = 'credsearch';
                            this.flowObj['credmore'].previous = 'credsearch';                
                        }
                    }
                } else {
                    if (!this.linkcredentials) {
                        this.showFirstRecoms = false;
                        this.flowObj['credsearch'].previous = 'linkcred';
                    } else {
                        this.credsearch = true;
                        this.flowObj['credsearch'].status = 'active';
                    }
                }
                this.getCurrentObj();
                if (!this.linkcredentials) {
                    this.updateFlow();
                }
            })
            .catch(error => {
                ComponentErrorLoging(this.compName, 'doCredentialAutoSearch', '', '', 'High', error.message);
            });
    }

    updateBusinessList() {
        this.bizList.push(this.singleBusiness);
        this.mainDataObj.bizList = this.bizList;
    }
    updateScreen(nextPage) {
        window.scrollTo({ top: 0, behavior: "smooth" });
        this.findyourbiz = false;
        this.bizconfirm = false;
        this.linkcred = false;
        this.findyourcred = false;
        this.credconfirm = false;
        this.matchcred = false;
        this.bizrole = false;
        this.summary = false;
        this.credmore = false;
        this.credsearch = false;

        if (nextPage === "findyourbiz") {
            this.credVerification = false;
            this.findyourbiz = true;
            this.bizRoleId = null;
            this.isCredFlow = true;
            this.currentObj = this.flowObj.findyourbiz;
        } else if (nextPage === "bizconfirm") {
            this.findyourbiz = false;
            this.bizconfirm = true;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "bizrole") {
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = true;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "linkcred") {
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = true;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "findyourcred") {
            this.credVerification = true;
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = true;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "credconfirm") {
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = true;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
            this.validateCreds();
        } else if (nextPage === "matchcred") {
            this.credVerification = true;
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = true;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "summary") {
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = true;
            this.validateCreds();
        } else if (nextPage === "credmore") {
            this.credVerification = true;
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = true;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = false;
            this.summary = false;
        } else if (nextPage === "credsearch") {
            this.findyourbiz = false;
            this.bizconfirm = false;
            this.bizrole = false;
            this.linkcred = false;
            this.findyourcred = false;
            this.credmore = false;
            this.credconfirm = false;
            this.matchcred = false;
            this.credsearch = true;
            this.summary = false;
        } else {
            this.findyourbiz = true;
        }
        window.scrollTo(0, 0);
    }

    validateCreds() {
        var temp = [];
        this.mainDataObj.credsList.forEach(element => {
            if(element.isCredIdVerified && element.isEmailVerified) {
                temp.push(element);
            }
        });
        this.mainDataObj.credsList = temp;
    }

    handleFindEvent(event) {
        this.businessVerified = false;
        this.singleBusiness = event.detail.value;
        this.previousAddedBiz = {
            bizid: this.singleBusiness.id,
            searchtext: event.detail.searchtext
        };
    }

    errorCallback(error) {
        ComponentErrorLoging('link_business', 'errorCallback', '', '', 'Low', error.message);
    }

    handleFindLinkEvent(event) {
        this.linkCredOption = event.detail.value;
    }
    addBusiness(event) {
        this.addAnotherBiz = event.detail.value;
    }
    updateBizList(event) {
        const index = this.selectedBusinessList.indexOf(event.detail.removedId);
        if (index > -1) {
            this.selectedBusinessList.splice(index, 1);
        }
        this.flowObj['bizconfirm'].previous = 'findyourbiz';
        this.selectedBusinessList = JSON.parse(JSON.stringify(this.selectedBusinessList));
        this.bizList = event.detail.bizList;
        this.mainDataObj = event.detail;
        if (this.mainDataObj.bizList.length == 0) {
            this.updateScreen('findyourbiz');
            //var currObj = this.flowObj.findyourbiz;
            this.bizAdd = true;
        }
    }
    handlePrincipalSelection(event) {
        this.selectedPrincipal = event.detail.value;
    }
    handleprincipalcheckbox(event) {
        let selectionOption = [];
        selectionOption = event.detail;
        this.selectedPrincipal = [];
        if(selectionOption[0] === 'noPrincipal') {
            this.noPrincipal = true;
            if (this.mainDataObj.bizList) {
                if (this.mainDataObj.bizList.length) {
                    this.mainDataObj.bizList.forEach(element => {
                        if (element.id === this.singleBusiness.id) {
                            element.principalDetails = [];
                        }
                    });
                }
            }
        } else {
            let array = selectionOption;
            const result = [];
            const map = new Map();
            //filtering unique values in the array
            for (const val of array) {
                if (!map.has(val.value)) {
                    map.set(val.value, true); // set any value to Map
                    result.push(val);
                }
            }
            this.selectedPrincipal = result;
            this.selectedPrincipal = JSON.parse(JSON.stringify(this.selectedPrincipal));
        
            if (this.mainDataObj.bizList) {
                if (this.mainDataObj.bizList.length) {
                    this.mainDataObj.bizList.forEach(element => {
                        if (element.id === this.singleBusiness.id) {
                            element.principalDetails = this.selectedPrincipal
                        }
                    });
                }
            }
        }
    }
    handleAgentSelection(event) {
        this.selectedAgent = event.detail.value;
    }
    
    afterCredMatch(event) {
        let credList = JSON.parse(JSON.stringify(event.detail));
        this.mainDataObj.credsList = credList;
    }
    
    handleCredRemove(event) {
        let credList = JSON.parse(JSON.stringify(event.detail));
        this.mainDataObj.credsList = credList;
    }
    
    updateSideNavStatus(compRef, status, prevStatus) {
        var tempCompRef = compRef;
        if (tempCompRef === "findyourcred" || tempCompRef === "credsearch" || tempCompRef === "credmore") {
            compRef = "findyourcred";
        }
        var sideNavElem = this.template.querySelector("c-bos_side-nav");
        var sideNavObj = JSON.parse(JSON.stringify(this.sidenavobj));
        var sideNavObjSections = sideNavObj.sections;
        if (sideNavObjSections) {
            for (let i = 0; i < sideNavObjSections.length; i++) {
                if (sideNavObjSections[i].subSection.length === 0) {
                    if (sideNavObjSections[i].pageNameRef === compRef) {
                        sideNavObjSections[i].status = status;
                        break;
                    }
                } else {
                    if (sideNavObjSections[i].pageNameRef) {
                        if (sideNavObjSections[i].pageNameRef === compRef) {
                            sideNavObjSections[i].status = status;
                        }
                    }
                    var subSections = sideNavObjSections[i].subSection;
                    if (subSections) {
                        for (let j = 0; j < subSections.length; j++) {
                            if (subSections[j].pageNameRef === compRef) {
                                subSections[j].status = status;
                                break;
                            }
                        }
                    }
                }
            }
            sideNavObj.sections = sideNavObjSections;
            this.sidenavobj = sideNavObj;
            if (sideNavElem) {
                sideNavElem.updatestatus(compRef, status, prevStatus);
            }

        }
    }

    calculateProgress() {
        const total = Object.keys(this.flowObj).length;
        let selected = 0;
        for (let key in this.flowObj) {
            if (key) {
                if (this.flowObj[key]) {
                    if (this.flowObj[key].status === 'active' || this.flowObj[key].status === 'completed') {
                        selected = selected + 1;
                    }
                }
            }
        }
        let completed = selected / total;
        completed = completed * 100;
        if (completed > 0 && completed <= 100) {
            this.flowPercentage = completed;
        }
    }

    beforeUnloadHandler(event) {
        if (!this.disableUnload && window.pageName !== 'bizdashboard') {
			let targetText = this.credVerification ? "Link Credential" : "Link Business";
            let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
            this.insertAnalyticsEvent(eventType,"Left the page", "", targetText);
            var message = "Are you sure you want to leave the page?";
            event.preventDefault();
            event.returnValue = message || "";
            return message || "";
        }
    }
	insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
        insertRecord(null, sectiontitle, sectiontitle, "", sectiontitle, 
        eventType, targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}