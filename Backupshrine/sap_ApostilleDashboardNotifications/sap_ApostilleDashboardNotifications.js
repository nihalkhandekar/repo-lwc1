import { LightningElement ,track,wire} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader'; 
import sap_ApostilleDashboardNotifiacations from '@salesforce/resourceUrl/apostilleDashboardNotifiacations'; // Import the CSS file
import notificationsLoad from "@salesforce/apex/SAP_ApostilleNotificationFetchController.Notifications";
// import redirectToMoreDetails from "@salesforce/apex/SAP_ApostilleSubmittedRequestController.getApplicationsFromNotification";
import notificationsMoveToAllRead from "@salesforce/apex/SAP_ApostilleNotificationFetchController.notificationsMoveToAllRead";
import { MessageContext,subscribe } from 'lightning/messageService';
// import individualApplicationMessageChannel from '@salesforce/messageChannel/notificationTypeSubmission__c';
import { NavigationMixin } from "lightning/navigation";


import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class ApostilleDashboardNotifications extends NavigationMixin(LightningElement) {


    @track id;
    @track describtion; // description__c
    @track iconName;    // iconName__c
    @track isRead;      // isRead__c
    @track title;       // title__c
    @track type;        // Type__c
    @track createdDate; // CreatedDate
    @track userId;      // Contact__c
    @track object_Id_For_Notification__c    //object_Id_For_Notification__c
    @track object_Name_For_Notification__c // object_Name_For_Notification__c
    notifications;
    LoadCounter=0;
    isLoading = true;
    isDashboardLoading=true;
    howOldNotificationIs=0;
    unitForTime='days';
    bluetick=true;

    dashboardItems=this.EmptyDashboardItems;
    submissionDetail=[];
    paymentsDetail=[];
    AlertsDetail=[];
    AllReadDetail=[];
    submissionClicked=false;
    paymentsClicked=false;
    AlertsClicked=false;
    typeOfNotification
    list

//labels
 //@track language = 'English'; 
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;


    redirectToMoreDetailsMethodCalled(event){
        let idFound=event.currentTarget.dataset.id;
        let type=event.currentTarget.dataset.value;
        console.log('type',type);
        console.log('idFound',idFound.toString());
        //console.log(Object.prototype.toString.call(idFound));
        let SendUrl='';

        if(type=='Submission' || type=='Alert'){
             SendUrl=`/eApostille/dashboard/submittedrequests?recordId=${idFound}`;
        }

        else if(type=='Draft'){
            SendUrl=`/eApostille/dashboard/draft?recordId=${idFound}`;
       }

        else if(type=='Payment'){
             SendUrl=`/eApostille/dashboard/paymenthistory?recordId=${idFound}`;

        }

        

        // const IndividualApplicationId={recordId:idFound};

        // publish(this.messageContext,individualApplicationMessageChannel,IndividualApplicationId);

        const config = {
            type: 'standard__webPage',
            attributes: {
                url: SendUrl
            }
        };
        this[NavigationMixin.Navigate](config);
        
        const customEvent= new CustomEvent('closenotification',{
            detail:{data:false}
        });
        this.dispatchEvent(customEvent);



        //console.log('id of individual Applications',idFound);
        // redirectToMoreDetails({i:idFound}).then(result=>{
        //     console.log(result);
        // }).catch(error=>{
        //     console.log(error);
        // })
    }

    // async notificationLoad(){
    //     try{
    //         this.notifications=await notificationsLoad();
    //         console.log(this.notifications);
    //         this.processNotification();
    //         this.SubmissionsButtonController();
    //         this.isLoading=false;
    //         console.log('notifications');
    //     }catch(error){
    //         if(!this.notifications){
    //             console.log('Contact is not there'+ error);
    //         }
    //     }
    // }

    @wire(notificationsLoad)
    wiredNotificationsLoad({ error, data }) {
        if (data) {
            this.notifications = data;
            this.processNotification();
            this.SubmissionsButtonController();
            
            this.isLoading = false;
            console.log('notifications', this.notifications);
        } else if (error) {
            console.error('Error fetching notifications: ', error);
        }
    }


processNotification() {
    this.notifications = this.notifications.map(notification => {
        let createdDate = new Date(notification.CreatedDate);
        let currentDate = new Date();
        let differenceInMilliseconds = currentDate - createdDate;

        // Convert the difference into meaningful units
        let differenceInSeconds = Math.floor(differenceInMilliseconds / 1000);
        let differenceInMinutes = Math.floor(differenceInSeconds / 60);
        let differenceInHours = Math.floor(differenceInMinutes / 60);
        let differenceInDays = Math.floor(differenceInHours / 24);

        // Determine how old the notification is
        let howOldNotificationIs;
        let unitForTime;
        let BlueCheck;

        // for timming
        if (differenceInDays >= 1) {
            howOldNotificationIs = differenceInDays;
            unitForTime = differenceInDays === 1 ? 'day' : 'days';
        } else if (differenceInHours >= 1) {
            howOldNotificationIs = differenceInHours;
            unitForTime = differenceInHours === 1 ? 'hour' : 'hours';
        } else if (differenceInMinutes >= 1) {
            howOldNotificationIs = differenceInMinutes;
            unitForTime = differenceInMinutes === 1 ? 'minute' : 'minutes';
        } else {
            howOldNotificationIs = differenceInSeconds;
            unitForTime = differenceInSeconds === 1 ? 'second' : 'seconds';
        }

        //for bluetick visibility
        if(notification.isRead__c==true){
            BlueCheck=false;
        }
        else if(notification.isRead__c==false){
            BlueCheck=true;
        // Create a new object with the timming property
        }

        //add link in notification
        //change here for adding or removing any status of notification
        let setLink;
        if(notification.Type__c=='Submission'){
            setLink='/eApostille/dashboard/submittedrequests';
        }
        else if(notification.Type__c=='Draft'){
            setLink='/eApostille/dashboard/Draftrequests';
        }
        else if(notification.Type__c=='Payment'){
            setLink='/eApostille/dashboard/paymenthistory';
        }
        else if(notification.Type__c=='Alert'){
            setLink='/eApostille/dashboard/submittedrequests';
        }

            return {
                ...notification,
                timming: `${howOldNotificationIs} ${unitForTime} ago`,
                bluetick : BlueCheck,
                link:setLink
            };      
    });

    //change here for adding or removing any status of notification
    // Segregate notifications into different types
    this.AllReadDetail = this.notifications.filter(notification => notification.isRead__c);
    this.paymentsDetail = this.notifications.filter(notification => notification.Type__c === 'Payment' && notification.isRead__c==false);
    this.submissionDetail = this.notifications.filter(notification => (notification.Type__c === 'Submission' || notification.Type__c === 'Draft') && notification.isRead__c==false);
    this.AlertsDetail = this.notifications.filter(notification => notification.Type__c === 'Alert' && notification.isRead__c==false);

    this.isLoading=false;
    this.isDashboardLoading=false;
    console.log('AllReadDetail', this.AllReadDetail);
    console.log('paymentsDetail', this.paymentsDetail);
    console.log('submissionDetail', this.submissionDetail);
    console.log('AlertsDetail', this.AlertsDetail);
}

    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
        }).catch(error => console.error('error is there', error));

        // fetch(labelsResourceForLocal)
        // .then((response) => {
        //     if (response.ok) {
        //         return response.json(); // Parse JSON data
        //     }
        //     throw new Error("Failed to load JSON");
        // })
        // .then((data) => {
        //     this.JsonLanguageData = data;
        //     this.labels = this.JsonLanguageData["English"];

        //     // Check if in community context and fetch cached language preference
        //     if (this.isCommunityContext()) {
        //         getCacheValue({ key: LANGUAGE_TEXT })
        //             .then((result) => {
        //                 this.handleLanguageChange(result);
        //             })
        //             .catch((error) => {
        //                 console.error("Error fetching cached language:", error);
        //             });
        //     }
        // })
        // .catch((error) => {
        //     console.error("Error fetching labels:", error);
        // });


        // Load the CSS file
        // Promise.all([
            loadStyle(this, sap_ApostilleDashboardNotifiacations) // Load the CSS file
        // ]).then(() => {
        //     this.staticResourceLoaded = true;
        //     console.log('CSS file loaded successfully');
        // }).catch(error => {
        //     console.error('Error loading CSS file:', error);
        // });     
         
        // this.notificationLoad(); 
    
        
    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
        this.handleLanguageChange(message);
      });
    }

    renderedCallback(){
        //first time submission button should be highlighted
        if(this.LoadCounter==0){
        //this.template.host.style.setProperty('--slds-c-button-color-background', '#0C7CCE');
        this.template.host.style.setProperty('--trialBackgroundColor', '#0C7CCE');
        this.template.host.style.setProperty('--trialTextColor','#FFFFFF');
         this.LoadCounter++;
         console.log('this.LoadCounter',this.LoadCounter);
        }
    }

    // change the status from unread to read
    notificationsMoveToAllReadFunctionCall1(typeOfNotification,list){
        notificationsMoveToAllRead({type:typeOfNotification,notificationFetchBack:list})
        .then(result=>{
            //this.submissionDetail=result;

            console.log('result',result);

            if(this.typeOfNotification=='Payment'){
                this.notifications=result;
            }
            else if(this.typeOfNotification=='Submission'){
                this.notifications=result;
            }
            else if(this.typeOfNotification=='Alert'){
                this.notifications=result;
            }    

            this.processNotification();

        }).catch(error =>{
            console.log(error);
        })
        
    }



    // @wire(notificationsMoveToAllRead, { type: '$this.typeOfNotification', notificationFetchBack: '$this.list' })
    // notificationsMoveToAllReadFunctionCall ({ error, data }) {
    //     if (data) {
    //         console.log('hear we are','$typeOfNotification','$list');
    //         this.notifications = data;
    //         this.processNotification();
    //     } else if (error) {
    //         console.error('Error moving notifications to read: ', error);
    //     }
    // }

    handleButtonClick() {
        console.log('in handle click');
        // to change the status that perticular button is clicked or not
        if (this.paymentsClicked==true) {
            console.log('in clicked paymentsClicked')
            this.typeOfNotification='Payment';
            this.list=this.paymentsDetail;
            this.notificationsMoveToAllReadFunctionCall1(this.typeOfNotification,this.list);
        }
        if (this.submissionClicked==true) {
            console.log('in clicked submissionClicked')
            this.typeOfNotification='Submission';
            this.list=this.submissionDetail;
            this.notificationsMoveToAllReadFunctionCall1(this.typeOfNotification,this.list);
        }
        if (this.AlertsClicked==true) {
            console.log('in clicked AlertsClicked')
            this.typeOfNotification='Alert';
            this.list=this.AlertsDetail;
            this.notificationsMoveToAllReadFunctionCall1(this.typeOfNotification,this.list);
        }
    }    
    SubmissionsButtonController(){

        // transfer data to all read
        this.submissionClicked=true;
        this.handleButtonClick();

        // if(this.paymentsDetailClicked){ this.notificationsMoveToAllReadFunctionCall('Payment',this.paymentsDetail);}
        // if(this.AlertsClicked){this.notificationsMoveToAllReadFunctionCall('Alert',this.AlertsDetail);}

        // for data load on html
        if(this.submissionDetail.length==0){
            this.bluetick=false;
            this.dashboardItems=this.EmptyDashboardItems;
        }
        else{
            this.bluetick=true;
            this.dashboardItems=this.submissionDetail;
        }
    }
    PaymentsButtonController(){
         if(this.LoadCounter==1){
            this.template.host.style.setProperty('--trialBackgroundColor', '#FFFFFF');
            this.template.host.style.setProperty('--trialTextColor','#0C7CCE');
            this.template.host.style.setProperty('--slds-c-button-color-border','#747474');
            this.LoadCounter++;
            }

        // transfer data to all read
        this.paymentsClicked=true;
        this.handleButtonClick();

        // if(this.submissionClicked){ this.notificationsMoveToAllReadFunctionCall('Submission',this.submissionDetail);}
        // if(this.AlertsClicked){this.notificationsMoveToAllReadFunctionCall('Alert',this.AlertsDetail);} 


        // load data on html    

        if(this.paymentsDetail.length==0){
            this.bluetick=false;
            this.dashboardItems=this.EmptyDashboardItems;
        }
        else{
            this.bluetick=true;
            this.dashboardItems=this.paymentsDetail;
        }

        

    }
    AlertsButtonController(){
        //change color of submission button 
        if(this.LoadCounter==1){
            this.template.host.style.setProperty('--trialBackgroundColor', '#FFFFFF');
            this.template.host.style.setProperty('--trialTextColor','#0C7CCE');
            this.template.host.style.setProperty('--slds-c-button-color-border','#747474');
            this.LoadCounter++;
            }
        
           // transfer data to all read tab 
            this.AlertsClicked=true;
            this.handleButtonClick();

            // if(this.submissionClicked){ this.notificationsMoveToAllReadFunctionCall('Submission',this.submissionDetail);}
            // if(this.paymentsClicked){ this.notificationsMoveToAllReadFunctionCall('Payment',this.paymentsDetail);}
    
    
            // load data on html     
        if(this.AlertsDetail.length==0  ){
            this.bluetick=false;
            this.dashboardItems=this.EmptyDashboardItems;
            console.log('this.AlertsDetail.length',this.AlertsDetail.length);
        }
        else{
            console.log('this.AlertsDetail.length',this.AlertsDetail.length);
            this.bluetick=true;
            this.dashboardItems=this.AlertsDetail;
        }

        
    }
    AllReadButtonController(){
        if(this.LoadCounter==1){
            this.template.host.style.setProperty('--trialBackgroundColor', '#FFFFFF');
            this.template.host.style.setProperty('--trialTextColor','#0C7CCE');
            this.template.host.style.setProperty('--slds-c-button-color-border','#747474');
            this.LoadCounter++;
            }

            this.handleButtonClick();
            // if(this.submissionClicked){ this.notificationsMoveToAllReadFunctionCall('Submission',this.submissionDetail);}
            // if(this.paymentsClicked){ this.notificationsMoveToAllReadFunctionCall('Payment',this.paymentsDetail);}
            // if(this.AlertsClicked){this.notificationsMoveToAllReadFunctionCall('Alert',this.AlertsDetail);} 
       

        
        if(this.AllReadDetail.length==0){
            this.bluetick=false;

            this.dashboardItems=this.EmptyDashboardItems;
        }
        else{
            console.log('AlertsDetail',this.AlertsDetail.length);
            console.log('submissionDetail',this.submissionDetail.length);
            console.log('paymentsDetail',this.paymentsDetail.length);
            this.bluetick=false;
            this.dashboardItems=this.AllReadDetail;
        }

         
    }

    EmptyDashboardItems=[{
        id: 'cancelledOrders',
        iconName__c: 'utility:error',
        title__c: 'No notification is there.',
        description__c: '',
                 link: '',
                 timming:''
    }];

    outSideOfComponentClicked(){
           const a=new CustomEvent('closenotificationpopup',{});
           this.dispatchEvent(a);
    }

        // Handle language change
        handleLanguageChange(message) {
            let language;
            if (message.language) {
                language = message.language;
            }else{
                language = message;
            }
      this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
        }

    
}