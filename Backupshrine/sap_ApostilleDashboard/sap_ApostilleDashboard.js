import { LightningElement, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import apostileCssDashboard from '@salesforce/resourceUrl/sap_ApostileDashboard';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import sapSOTSAppUrl from '@salesforce/label/c.sap_SOTSAppUrl';
import sap_ApostilleUserSetting from '@salesforce/label/c.sap_ApostilleUserSetting';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleDashboard extends LightningElement {
  staticResourceLoaded = false;
  sapSOTSAppUrl = sapSOTSAppUrl;

  //labels
  labels = {};
  JsonLanguageData;

  //labels
  @wire(MessageContext)
  messageContext;

  dashboardItems = [];

  connectedCallback() {
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
            this.dashboardItems = [
              {
                id: 'submittedRequests',
                icon: 'standard:approval',
                title: `${this.labels.SubmittedRequests}`,
                description: `${this.labels.TrackSubmittedRequests}`,
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/submittedrequests`;
                },
                target: '_self'
              },
              {
                id: 'drafts',
                icon: 'standard:account',
                title: `${this.labels.Drafts}`,
                description: String(this.labels.AccessDrafts),
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/draft`;
                },
                target: '_self'
              },
              {
                id: 'lettersCertificates',
                icon: 'standard:asset_action_source',
                title: this.labels.CompletedOrders,
                description: this.labels.ManageLetters,
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/letterandcertificate`;
                },
                target: '_self'
              },
              {
                id: 'paymentHistory',
                icon: 'custom:custom17',
                title: this.labels.PaymentHistory,
                description: this.labels.TrackPayments,
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/paymenthistory`;
                },
                target: '_self'
              },
              {
                id: 'guidelinesResources',
                icon: 'standard:article',
                title: this.labels.GuidelinesAndResources,
                description: this.labels.AccessResources,
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/guidelinesResources`;
                },
                target: '_self'
              },
              {
                id: 'userProfileSettings',
                icon: 'standard:avatar',
                title: this.labels.UserProfile,
                description: this.labels.ManageAccount,
                link: sap_ApostilleUserSetting,
                target: '_self'
              },
              {
                id: 'cancelledOrders',
                icon: 'action:reject',
                title: this.labels.MyCancelledOrders,
                description: this.labels.ViewCancelledOrders,
                get link() {
                    const pathSegments = window.location.pathname.split('/');
                    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
                    return `${sitePath}/dashboard/cancelled`;
                },
                target: '_self'
              }
            ];
          })
          .catch((error) => {
            console.error(error);
          });
      })
      .catch((error) => console.error('error is there', error));

    // Load the CSS file
    loadStyle(this, apostileCssDashboard)
      .then(() => console.log('CSS file loaded successfully'))
      .catch((error) => console.error('Error loading CSS file:', error));

    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }

  // Handle language change
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;
    } else {
      language = message;
    }

    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));

    this.dashboardItems = [
      {
        id: 'submittedRequests',
        icon: 'standard:approval',
        title: `${this.labels.SubmittedRequests}`,
        description: `${this.labels.TrackSubmittedRequests}`,
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/submittedrequests`;
        },
        target: '_self'
      },
      {
        id: 'drafts',
        icon: 'standard:account',
        title: `${this.labels.Drafts}`,
        description: String(this.labels.AccessDrafts),
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/draft`;
        },
        target: '_self'
      },
      {
        id: 'lettersCertificates',
        icon: 'standard:asset_action_source',
        title: this.labels.CompletedOrders,
        description: this.labels.ManageLetters,
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/letterandcertificate`;
        },
        target: '_self'
      },
      {
        id: 'paymentHistory',
        icon: 'custom:custom17',
        title: this.labels.PaymentHistory,
        description: this.labels.TrackPayments,
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/paymenthistory`;
        },
        target: '_self'
      },
      {
        id: 'guidelinesResources',
        icon: 'standard:article',
        title: this.labels.GuidelinesAndResources,
        description: this.labels.AccessResources,
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/guidelinesResources`;
        },
        target: '_self'
      },
      {
        id: 'userProfileSettings',
        icon: 'standard:avatar',
        title: this.labels.UserProfile,
        description: this.labels.ManageAccount,
        link: 'https://dev.login.ct.gov/ctidentity/profile?spEntityID=https://${sapSOTSAppUrl}/idp/eApostille&RelayState=https://${sapSOTSAppUrl}/eApostillevforcesite/login',
        target: '_self'
      },
      {
        id: 'cancelledOrders',
        icon: 'action:reject',
        title: this.labels.MyCancelledOrders,
        description: this.labels.ViewCancelledOrders,
        get link() {
            const pathSegments = window.location.pathname.split('/');
            const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
            return `${sitePath}/dashboard/cancelled`;
        },
        target: '_self'
      }
    ];
  }

  navigateToForm() {
    const pathSegments = window.location.pathname.split('/');
    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
    window.location.href = `${sitePath}/eApostilleform`;
  }
}