/**
 * @File Name          : bosAccountDashboardHeader
 * @Description        : Displays Header in Account Dashboard
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 21.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    21.05.2020        Rahul Bussa             Initial Version
**/
import { LightningElement, track } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
// Import Custom Labels
import accountDashboard_manageSettings from "@salesforce/label/c.accountDashboard_manageSettings";
import bizDashboard_giveChecklistFeedback from "@salesforce/label/c.bizDashboard_giveChecklistFeedback";
import surveyLink from "@salesforce/label/c.surveyLink";
import accountDashboard_logout from "@salesforce/label/c.accountDashboard_logout";
import fr_LogoutURL from "@salesforce/label/c.FR_LogoutURL";
import forgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
export default class BosAccountDashboardHeader extends LightningElement {
    
    settingIcon = assetFolder + "/icons/settings-outline-blue.svg#settingoutlineblue";
    megaphoneIcon = assetFolder + "/icons/megaphone-outline-blue.svg#megaphoenoutlineblue";
    optionsIcon = assetFolder + "/icons/options-outline-blue.svg#optionoutlineblue";
    
    @track mobileNavOpen = false;
    
    label ={
        accountDashboard_manageSettings,
        fr_LogoutURL,
        accountDashboard_logout,forgeRockDashboard, surveyLink,
        bizDashboard_giveChecklistFeedback
    }

    get getMobileNav(){
        if(this.mobileNavOpen){
            return 'slds-section slds-is-open'
        }else {
            return 'slds-section';
        }
    }

    toggleNav(){
        this.mobileNavOpen = !this.mobileNavOpen;
    }

    handleLogout(event){
        event.preventDefault();
        // window.location.replace("../secur/logout.jsp");
        window.location.href = this.label.fr_LogoutURL;
    }
    handleAccountSetting(){
        window.location.href = this.label.forgeRockDashboard;

    }
}