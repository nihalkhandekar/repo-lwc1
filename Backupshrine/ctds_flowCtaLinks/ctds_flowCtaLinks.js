import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import BRS_UCC_LANDINGPAGEURL from "@salesforce/label/c.BRS_UCC_LANDINGPAGEURL";
import go_to_summary from "@salesforce/label/c.go_to_summary";
import BRS_landingpage from "@salesforce/label/c.BRS_landingpage";

import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import {
    fireEvent,
    registerListener,
    unregisterAllListeners
  } from "c/commonPubSub";

export default class ctds_flowCtaLinks extends NavigationMixin(LightningElement) {
    @api
    availableActions = [];

    @api showGoToSummaryButton = false;

    @api nextLabel;
    @api prevLabel;
    @api customLabel;
    @api exitLabel;
    @api customButtonClass;
    @api nextButtonClass;
    @api isCustomNavigation;
    @api sideNavObj;
    @api currObj;
    @api goToBrsLanding = false;
    @api goToSummary = false;
    @api isCancel = false;
    @api goToDashBoardPage = false;
    @api isReviewScreen = false;
    @track hideBack = false;
    @track label = {
        go_to_summary,
		brs_FIlingLandingPage
    }
    @api landingPageUrl;

    @api get canNext() {
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            return true;
        }
        if (this.availableActions.find(action => action === 'FINISH')) {
            // navigate to the next screen
            return true;
        }
        return false;
    }
    @api get canPrev() {
        if (this.availableActions.find(action => action === 'BACK') || this.goToDashBoardPage) {
            // navigate to the next screen
            return true;
        }
        // UCC lien type page cancel button
        if (this.isCancel) {
            return true;
        }
        return false;
    }
    @api get canCustom() {
        if (this.customLabel != undefined) {
            // navigate to the next screen
            return true;
        }
        return false;
    }

	connectedCallback() {
         const isComeFromReview = sessionStorage.getItem("isComeFromReview");
         if((isComeFromReview && this.isReviewScreen && !this.goToDashBoardPage) || (isComeFromReview && !this.isReviewScreen)){
            this.hideBack = true;
         }
		 if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
          }
        registerListener("flowvalidation", this.handleNotification, this);
	}
    handleContinue() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('isCustomNavigation', false);
        this.dispatchEvent(attributeChangeEvent);
        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        if (this.availableActions.find(action => action === 'FINISH')) {
            // navigate to the next screen
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }


    handleBack() {
        //isCancel is for redirect user to ucc landing page
        if (!this.isCancel) {
            const attributeChangeEvent = new FlowAttributeChangeEvent('isCustomNavigation', false);
            this.dispatchEvent(attributeChangeEvent);
            // check if NEXT is allowed on this screen
            // navigate to the next screen
            if (this.goToDashBoardPage) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: this.label.brs_FIlingLandingPage
                    },
                });
            } else {
                this.goToDashBoardPage = false;
                this.goToSummary = false;
                const navigateBackEvent = new FlowNavigationBackEvent();
                this.dispatchEvent(navigateBackEvent);
                fireEvent(this.pageRef, "flowvalidation", {
                    detail: {
                        isValid: true
                    }
                    });

            }
        } else {
            this.handleCancelClick();
        }
    }
    handleCustom() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('isCustomNavigation', true);
        this.dispatchEvent(attributeChangeEvent);

        // check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    //Redirect user to ucc or brs landing page
    handleCancelClick() {
        let pageName = this.goToBrsLanding ? this.landingPageUrl : BRS_UCC_LANDINGPAGEURL;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName
            },
        });
    }

    handleGoToSummary() {
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: An additional feature for BRS-930,1101,1141 and 1107
        * Change(s)/Modification(s) Description : For adding the condition to go to summary if this variable is true.
        */
        this.goToSummary = true;
        const navigateNextEvent = new FlowNavigationNextEvent("goToSummary", this.goToSummary);
        this.dispatchEvent(navigateNextEvent);
    }
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true)
          return;
      }
}