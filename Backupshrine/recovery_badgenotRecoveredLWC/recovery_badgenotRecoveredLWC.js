/**********************************************************************************************
 * NAME:  BadgeNotRecovered.js
 * DESCRIPTION: Covid-19 Badge Not Recovered 
 *
 * @AUTHOR: Mohan Mullapudi
 * @DATE: 6/11/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Mohan Mullapudi               16/11/2020                         Created the first version
 *
*********************************************************************************************/
import { LightningElement,api,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//custom lables import statements
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
import label_badgenotrecovered_msg from '@salesforce/label/c.Recovery_badgenotrecovered_msg';
import label_badgenotrecovered_msg1 from '@salesforce/label/c.Recovery_badgenotrecovered_msg1';
import label_badgenotrecovered_button from '@salesforce/label/c.Recovery_badgenotrecovered_Button';
import label_badgenotrecovered_button1 from '@salesforce/label/c.Recovery_badgenotrecovered_Button1';
import label_badgenotrecovered_msg2 from '@salesforce/label/c.Recovery_badgenotrecovered_msg2';



export default class Navtab extends NavigationMixin(LightningElement) {
    @api
    businessowneremail;
    @track
    gohome;

    //setting labels to be used in HTML
    label = {
        label_badgenotrecovered_msg,
        label_badgenotrecovered_msg1,
        label_badgenotrecovered_button,
        label_badgenotrecovered_button1,
        label_badgenotrecovered_msg2
    };

    submit(event){
        location.href = HOME_PAGE;
    }
    
    home(event){
        this.gohome=true;
    }

}