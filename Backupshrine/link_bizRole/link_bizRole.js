import {
    LightningElement,
    track,
    api
} from 'lwc';
import getAgentsAndPrincipals from "@salesforce/apex/AccountDashboard.getAgentsAndPrincipals";

import linkFindBiz_IdentifyBusinesss from '@salesforce/label/c.linkFindBiz_IdentifyBusinesss';
import Principal from '@salesforce/label/c.Principal';
import linkFindBiz_PrincipalMsg from '@salesforce/label/c.linkFindBiz_PrincipalMsg';
import Agent from '@salesforce/label/c.Agent';
import linkFindBiz_AgentMsg from '@salesforce/label/c.linkFindBiz_AgentMsg';
import linkFindBiz_YesAgent from '@salesforce/label/c.linkFindBiz_YesAgent';
import linkFindBiz_NoAgent from '@salesforce/label/c.linkFindBiz_NoAgent';
import linkFindBiz_NoneAbove from '@salesforce/label/c.linkFindBiz_NoneAbove';
import linkFindBiz_NotPrincipal from '@salesforce/label/c.linkFindBiz_NotPrincipal';
import linkFindBiz_NoPrincipal from '@salesforce/label/c.linkFindBiz_NoPrincipal';
import linkFindBiz_NoPrincipalMsg from '@salesforce/label/c.linkFindBiz_NoPrincipalMsg';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Role';
import linkFindBiz_Helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import linkFindBiz_RoleHelpText from '@salesforce/label/c.linkFindBiz_RoleHelpText';
import linkBiz_selectRole from '@salesforce/label/c.linkBiz_selectRole';
import linkFindBiz_AgentDetailMsg from '@salesforce/label/c.linkFindBiz_AgentDetailMsg';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Link_bizRole extends LightningElement {
    @track noPrincipalIcon = assetFolder + "/icons/employee-active.svg";
    @track helptexheader = linkFindBiz_Helptexheader;
    @track helptextbody = linkFindBiz_RoleHelpText;
    @track accountId;
    @track resultArray = [];
    @track principalErrorMssg = false;
    @track agentErrorMssg = false;
    @track principalData = [];
    @track agentData = [];
    @track agentOpts = [{
            label: linkFindBiz_YesAgent,
            value: linkFindBiz_YesAgent,
            id: linkFindBiz_YesAgent
        },
        {
            label: linkFindBiz_NoAgent,
            value: linkFindBiz_NoAgent,
            id: linkFindBiz_NoAgent
        }
    ];
    @track principalOptsDefault = [{
        boldLabel: linkFindBiz_NoneAbove,
        subtext: linkFindBiz_NotPrincipal,
        // eLicense_Credential_ID: linkFindBiz_NoneAbove,
        value: linkFindBiz_NoneAbove,
        id: linkFindBiz_NoneAbove
    }]
    @track selectedValue;
    @track agentSelectedValue;
    @track AgentBusinessId;
    @track AgentAddress;
    @track AgentValue;
    @track AgentName;
    @track checkDisabled = false;
    @api maindataobj;
    @api bizid;
    @track preSelectedValues = [];
    @track selectedPrincipals = [];
    @api noPrincipal;
    @api //Code Review SP4
    get currentobj() {
        return this._currentobj;
    }

    set currentobj(value) {
        this._currentobj = value;
    }
    @api //Code Review SP4
    get comingFromParent() {
        return this._comingFromParent;
    }

    set comingFromParent(value) {
        this._comingFromParent = value;
        if (this.comingFromParent) {
            this.validateScreen();
        }
    }

    label = {
        linkFindBiz_IdentifyBusinesss,
        Principal,
        linkFindBiz_PrincipalMsg,
        Agent,
        linkFindBiz_AgentMsg,
        linkFindBiz_NoPrincipal,
        linkFindBiz_NoPrincipalMsg,
        linkBiz_selectRole,
		linkFindBiz_AgentDetailMsg,
    };

    connectedCallback() {
        if (this.bizid) {
            this.currentobj = this.bizid;
            this.accountId = this.currentobj.id;
        } else {
            this.accountId = this.currentobj.id;
        }
        
        if(this.maindataobj.bizList) {
            if(this.maindataobj.bizList.length) {
                this.maindataobj.bizList.forEach(element => {
                    if(element.id === this.currentobj.id) {
                    this.selectedPrincipals = element.principalDetails;
                    if (element.listedAgent) {
                        this.agentSelectedValue = element.listedAgent;
                        if (this.agentSelectedValue.value) {
                            this.agentSelectedAnswer = linkFindBiz_YesAgent;
                            this.agentSelectedValue = linkFindBiz_YesAgent;
                        }
                    } else if(element.listedAgent === null) {
                        this.agentSelectedValue = linkFindBiz_NoAgent;
                        this.agentSelectedAnswer = linkFindBiz_NoAgent;
                    }
                    if (element.principalDetails) {
                        if (element.principalDetails.length) {
                            element.principalDetails.forEach(el => {
                                this.checkDisabled = false;
                                this.preSelectedValues.push(el.id);
                            });
                        } else {
                            if (this.noPrincipal) {
                                this.selectedPrincipals = this.principalOptsDefault;
                                this.checkDisabled = true;
                                this.preSelectedValues.push(linkFindBiz_NoneAbove);
                                }
                            }
                        }
                    }
                });
            }
        }
        
        // let temp = JSON.parse(JSON.stringify(this.currentobj));
        getAgentsAndPrincipals({
                accId: this.accountId
            })
            .then(result => {
                this.resultArray = result;
                
                result.forEach(element => {
                    if (element.contactType === this.label.Principal) {
                        element.businessId = element.title;
                        element.boldLabel = element.name;
                        element.address = element.mailingAddress1 + element.mailingAddress2;
                        element.value = element.id;
                        this.principalData.push(element);
                    } else if (element.contactType === this.label.Agent) {
                        this.agentData.push({
                            businessId: element.type,
                            label: element.name,
                            address: element.mailingAddress1 + element.mailingAddress2,
                            value: element.id
                        })
                        this.AgentBusinessId = element.type;
                        this.AgentAddress = element.mailingAddress1 + element.mailingAddress2;
                        this.AgentValue = element.id;
                        this.AgentName = element.name;
                    }
                });
                if (this.principalData.length === 0) {
                    let emptyArray = [];
                    const nextClickEvent = new CustomEvent('principalresponse', {
                        detail: {
                            value: emptyArray
                        },
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(nextClickEvent);
                }
                if (this.agentData.length === 0) {
                    const nextClickEventAgent = new CustomEvent('agentresponse', {
                        detail: {
                            value: null
                        },
                        bubbles: true,
                        composed: true
                    });
                    this.dispatchEvent(nextClickEventAgent);
                }
            });
    }

    handleAgentSelection(event) {
        var value = event.detail.value;
        this.agentSelectedValue = value;
        let shortValue;
        let tempAgent = this.agentOpts;
        this.agentErrorMssg = false;
        if (this.agentSelectedValue === linkFindBiz_YesAgent) {
            tempAgent.forEach(element => {
                element = JSON.parse(JSON.stringify(element));
                if (element.value === this.agentSelectedValue) {
                    element.businessId = this.AgentBusinessId
                    element.address = this.AgentAddress;
                    element.value = this.AgentValue;
                    element.label = this.AgentName;
                    shortValue = element;
                }
            });
        } else {
            shortValue = null;
        }
        const nextClickEventAgent = new CustomEvent('agentresponse', {
            detail: {
                value: shortValue,
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(nextClickEventAgent);
        this.validateScreen();
    }
    handleSelect(event) {
        var options = event.detail.result;
        
        this.selectedPrincipals = this.selectedPrincipals.concat(options);
        if (this.selectedPrincipals.length) {
            this.principalErrorMssg = false;
        }

        // this.handleRadioClick(event);
        const selectedEvent = new CustomEvent("selectval", {
            bubbles: true,
            composed: true,
            detail: this.selectedPrincipals
        });
        this.dispatchEvent(selectedEvent);
        this.validateScreen();
    }
    handleNoneSelect(event) {
        //this.selectedPrincipals = [];
        this.preSelectedValues = [];
        this.checkDisabled = true;
        var options = event.detail.result;
        this.selectedPrincipals = options;
        options.forEach(element => {
            element.value = null;
        });
        if (this.selectedPrincipals.length) {
            this.principalErrorMssg = false;
        }

        // options.value = null;
        const selectedEvent = new CustomEvent("selectval", {
            bubbles: true,
            composed: true,
            detail: ['noPrincipal']
        });
        this.dispatchEvent(selectedEvent);
        this.validateScreen();
    }
    handleNoneDeSelect(event) {
        this.checkDisabled = false;
        var id = event.detail.result;
        let temp = [];
        this.selectedPrincipals.forEach((element, i) => {
            if (element.id != id) {
                temp.push(element);
            }
        });
        this.selectedPrincipals = temp;
    }
    handleDeSelect(event) {
        var id = event.detail.result;
        let temp = [];
        this.selectedPrincipals.forEach((element, i) => {
            if (element.id != id) {
                temp.push(element);
            }
        });
        this.selectedPrincipals = temp;
        const deSelectedEvent = new CustomEvent("deselectval", {
            bubbles: true,
            composed: true,
            detail: id
        });
        this.dispatchEvent(deSelectedEvent);
    }
    /**
     * @function validateScreen - method written to handle validation particular to this component
     * @param none
     */
    @api
    validateScreen() {
        if (this.principalData.length == 0 && this.agentData.length == 0) {
            this.noErrorDispatch();
            return true;
        } else if (this.selectedPrincipals != null && this.selectedPrincipals.length > 0) {
            if (this.agentData.length == 0) {
                this.noErrorDispatch();
                return true;
            } else if (this.agentData.length != 0 && this.agentSelectedValue && this.agentSelectedValue.length > 0) {
                this.noErrorDispatch();
                return true;
            } else {
                if (this.comingFromParent) {
                this.agentErrorMssg = true;
                }
                return false;
            }
        } else if (this.agentData.length == 0 || (this.agentData.length != 0 && this.agentSelectedValue && this.agentSelectedValue.length > 0)) {
            if (this.principalData.length == 0) {
                this.noErrorDispatch();
                return true;
            } else if (this.principalData.length != 0 && this.selectedPrincipals && this.selectedPrincipals.length > 0) {
                this.noErrorDispatch();
                return true;
            } else {
                if (this.comingFromParent) {
                this.principalErrorMssg = true;
                }
                return false;
            }
        } else {
            if (this.comingFromParent) {
            this.agentErrorMssg = true;
            this.principalErrorMssg = true;
            }
            return false;
        }
    }

    @api
    validationMessage() {
        return validationMsg;
    }

    /**
     * @function noErrorDispatch - method written to dispatch an event to parent inorder to remove the error tooltip on selection
     * @param none
     */
    noErrorDispatch() {
        const noErrorEvent = new CustomEvent('noerror');
        this.dispatchEvent(noErrorEvent);
    }
}